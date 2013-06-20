/* http://en.wikipedia.org/wiki/Generating_primes */

#define _GNU_SOURCE             /* for CPU_ZERO() etc, and pthread_setaffinity_np()  */
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/types.h>

#include "sieve.h"

#define SIEVE_DEBUG

/*##############################################################
  # debug definition
  #############################################################*/

#ifdef SIEVE_DEBUG
#define STMT(stuff)   do { stuff } while (0)
#define SIEVE_debug(a) STMT(                             \
        printf("[%s(%04d)] ", __FILE__[0] == '/'?   \
        ((strrchr(__FILE__,'/')==NULL)?__FILE__:(strrchr(__FILE__,'/')+1)):   \
        ((strrchr(__FILE__,'\\')==NULL)?__FILE__:(strrchr(__FILE__,'\\')+1)), \
             __LINE__);                                     \
    printf a;)
#else
#define SIEVE_debug(a)
#endif

#define handle_error_en(en, msg) do { errno = en; perror(msg); exit(EXIT_FAILURE); } while (0)
#define handle_error(msg)  do { perror(msg); exit(EXIT_FAILURE); } while (0)

/*##############################################################
  # typedefs
  #############################################################*/
/* used as argument to thread_start() */
struct thread_info {
    pthread_t tid;              /* id returned by pthread_create() */
    int core_idx;               /* the idx of the core this thread setaffinity to */

    prime_t *known_primes;      /* array of the known primes */
    prime_t start_idx;          /* the idx of the first prime used for sieving */
    prime_t last_idx;           /* the idx of the last prime used for sieving */
    prime_t step;               /* the step size of choosing the next prime to sieve */

    prime_t *sieve;             /* the sieve: an array of continuous numbers to be sieved */
    prime_t sieve_size;         /* the size of the sieve */
    prime_t sieve_start;        /* sieve[0] */
};

/*##############################################################
  # globle variables definition
  #############################################################*/

/*##############################################################
  # static variables definition
  #############################################################*/
static prime_t *s_sieve = NULL;
static prime_t s_max_sieve_size = 0;

/* system physical memory info: page size and num of physical pages */
static int s_pagesize = 0;
static int s_phys_pages = 0;

/*##############################################################
  # local function forward declarations
  #############################################################*/
static void do_sieve(prime_t * known_primes, prime_t start_idx, prime_t stop_idx, prime_t idx_step, prime_t * sieve,
                     prime_t sieve_start, prime_t sieve_size);
static void smp_sieve(prime_t * known_primes, prime_t start_idx, prime_t stop_idx, prime_t idx_step, prime_t * sieve,
                      prime_t sieve_start, prime_t sieve_size);
static void *thread_start(void *arg);
static int set_affinity(int core_idx);

/*##############################################################
  # global function implementations
  #############################################################*/

    /*
     * determine the sieve size and allocate it
     *
     * return the max sieve size (num of elements)
     */
prime_t sieve_init(void)
{

    if (s_sieve)
        return s_max_sieve_size;

    s_pagesize = sysconf(_SC_PAGESIZE);
    s_phys_pages = sysconf(_SC_PHYS_PAGES);

    /* maximumly use half of the physical RAM for the sieve */
    s_max_sieve_size = (prime_t) s_pagesize *s_phys_pages / sizeof(prime_t) / 2;
    //s_max_sieve_size = (prime_t) s_pagesize *s_phys_pages / 2;  /* one byte flag for each element in the sieve */

    SIEVE_debug(("pagesize=%d, phys_pages=%d=>total_ram=%llu(MiB); max_sieve_size=%.1f (M)\n",
                 s_pagesize, s_phys_pages, (prime_t) s_pagesize * s_phys_pages / 1024 / 1024, (float)s_max_sieve_size / M));

    /* malloc the global sieve */
    s_sieve = (prime_t *) malloc(s_max_sieve_size * sizeof(prime_t));
    if (!s_sieve) {
        SIEVE_debug(("malloc() for sieve failed.\n"));
        exit(1);
    }

    return s_max_sieve_size;
}

void sieve_fini(void)
{
    if (s_sieve)
        free(s_sieve);
    s_sieve = NULL;
}

/*
 * known_primes [in/out]: the array of the known primes, starting from
 *                 the 1st one (2) to the one before "start_idx",
 *                 the function will add primes into the array.
 * start_idx: the index of the next prime number to be determined.
 * stop_idx: stop if we reach to this index 
 * smp: bool, 1 for multi-threads.
 *
 * return: the index of the next un-determined prime number 
 *         return 0 for errors.
 */
prime_t sieve_prime(prime_t * known_primes, prime_t start_idx, prime_t stop_idx, int smp)
{
    prime_t last_prime, last_index;     /* the last known prime and its index */

    /* the seive does not contain any even number bigger than 2 */
    prime_t sieve_start;        /* the smallest & first number in the sieve */
    prime_t sieve_stop;         /* the lagest & last number in the sieve */
    prime_t sieve_size;         /* number of numbers in the sieve */

    prime_t i, next_index_return = start_idx;

    if (!known_primes)
        return 0;

    if (start_idx == 0) {
        /* populate the first bunch of known primes, don't need a sieve */
        known_primes[0] = 2;
        known_primes[1] = 3;
        known_primes[2] = 5;
        known_primes[3] = 7;
        known_primes[4] = 11;
        known_primes[5] = 13;
        known_primes[6] = 17;
        known_primes[7] = 19;
        known_primes[8] = 23;

        SIEVE_debug(("INFO: sieve session starts: next_prime_index=%llu\n", start_idx));
        return 9;
    }

    /* calcuate the biggest number can be sieved with the known prime db */
    last_index = start_idx - 1;
    last_prime = known_primes[last_index];

    sieve_start = last_prime + 2;       /* skip the first even number bigger than 'last_prime' */
    sieve_stop = last_prime * last_prime;       /* this has to be an odd number */

    /* don't waste time in sieving even numbers */
    sieve_size = (sieve_stop - sieve_start) / 2 + 1;

    /* we may not have enough space for accomendating the 'sieve_size'. shrink it then */
    if (sieve_size > s_max_sieve_size) {
        sieve_size = s_max_sieve_size;
        sieve_stop = sieve_start + (sieve_size - 1) * 2;
    }

    SIEVE_debug(("INFO: session starts: next_prime_index=%llu, sieve_range: [%llu, %llu], sieve_size:%llu\n",
                 start_idx, sieve_start, sieve_stop, sieve_size));

    /* populate the sieve */
    for (i = 0; i < sieve_size; i++)
        s_sieve[i] = sieve_start + i * 2;

    if (!smp) {
        do_sieve(known_primes, 1, last_index, 1, s_sieve, sieve_start, sieve_size);
    } else {
        smp_sieve(known_primes, 1, last_index, 1, s_sieve, sieve_start, sieve_size);
    }

    /* reap primes remain in the sieve */
    for (i = 0; i < sieve_size; i++) {
        if (s_sieve[i] != 0) {
            known_primes[next_index_return] = s_sieve[i];
            //SIEVE_debug(("INFO: found new prime: %llu -> %llu\n", next_index_return, s_sieve[i]));
            next_index_return++;
            if (next_index_return >= stop_idx)
                break;
        }
    }

    return next_index_return;
}

static void do_sieve(prime_t * known_primes,    /* [in]: prime db */
                     prime_t start_idx, /* start_idx of the prime used to sieve */
                     prime_t stop_idx,  /* stop_idx... */
                     prime_t idx_step,  /* step of prime idx */
                     prime_t * sieve,   /* [in/out]: the sieve w/o even numbers */
                     prime_t sieve_start,       /* the number represented by sieve[0] */
                     prime_t sieve_size)
{                               /* sieve array size */
    int i;
    prime_t p, dp;
    prime_t smallest, sieve_index;
    prime_t sieve_stop = sieve_start + (sieve_size - 1) * 2;

    for (i = start_idx; i <= stop_idx; i += idx_step) {
        p = known_primes[i];
        dp = p * 2;

        /* find the smallest & odd multiple of "p" within the sieve */
        smallest = sieve_start / p;
        if (!(smallest % 2))
            smallest += 1;
        smallest *= p;

        if (smallest < sieve_start)
            smallest += dp;
        if (smallest > sieve_stop)
            continue;

        /* sieve now */
        sieve_index = (smallest - sieve_start) / 2;
        do {
            sieve[sieve_index] = 0;
            sieve_index += p;
        }
        while (sieve_index < sieve_size);
    }
}

static void smp_sieve(prime_t * known_primes,
                      prime_t start_idx,
                      prime_t stop_idx, prime_t idx_step, prime_t * sieve, prime_t sieve_start, prime_t sieve_size)
{
    struct thread_info *tinfo;
    pthread_attr_t attr;
    int s;
    void *res;
    int tidx;                   /* thread index */

    int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
    //SIEVE_debug(("num_cores=%d\n", num_cores));

    /* initialize thread creation attributes */
    s = pthread_attr_init(&attr);
    if (s != 0)
        handle_error_en(s, "pthread_attr_init");

    /* allocate memory for pthread_create() arguments */

    tinfo = calloc(num_cores, sizeof(struct thread_info));
    if (tinfo == NULL)
        handle_error("calloc");

    /* create one thread for each core */
    for (tidx = 0; tidx < num_cores; tidx++) {
        tinfo[tidx].core_idx = tidx;
        tinfo[tidx].known_primes = known_primes;
        tinfo[tidx].start_idx = tinfo[tidx].core_idx + start_idx;
        tinfo[tidx].last_idx = stop_idx;
        tinfo[tidx].step = num_cores;
        tinfo[tidx].sieve = s_sieve;
        tinfo[tidx].sieve_size = sieve_size;
        tinfo[tidx].sieve_start = sieve_start;

        s = pthread_create(&(tinfo[tidx].tid), &attr, &thread_start, &tinfo[tidx]);
        if (s != 0)
            handle_error_en(s, "pthread_create");
    }

    /* destroy the thread attributes object, since it is no longer needed */
    s = pthread_attr_destroy(&attr);
    if (s != 0)
        handle_error_en(s, "pthread_attr_destroy");

    /* now join with each thread */
    for (tidx = 0; tidx < num_cores; tidx++) {
        s = pthread_join(tinfo[tidx].tid, &res);
        if (s != 0)
            handle_error_en(s, "pthread_join");
    }

    free(tinfo);
}

/* sieving function for each thread */
static void *thread_start(void *arg)
{
    struct thread_info *tinfo = (struct thread_info *)arg;

    /* sanity check */
    if (!tinfo->known_primes || !tinfo->sieve) {
        SIEVE_debug(("either known_primes[] or sieve[] is invalid. quit...\n"));
        exit(1);
    }

    set_affinity(tinfo->core_idx);

    do_sieve(tinfo->known_primes,
             tinfo->start_idx, tinfo->last_idx, tinfo->step, tinfo->sieve, tinfo->sieve_start, tinfo->sieve_size);

    return 0;
}

/* 
 * core_idx range: [0, num_cores-1];
 * return: 0 for success, otherwise failure
 */
static int set_affinity(int core_idx)
{
    if (core_idx < 0 || core_idx >= sysconf(_SC_NPROCESSORS_ONLN))
        return EINVAL;

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(core_idx, &cpuset);

    return pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
}
