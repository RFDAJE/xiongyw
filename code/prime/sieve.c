/*
 * noted(bruin, 2013-06-10): updated to support SMP and getopt
 * noted(bruin, 2013-06-13): added mmap() for saving primes
 * noted(bruin, 2013-06-14): set the max sieve size according to physical ram size
 */
#define _GNU_SOURCE
#define _LARGEFILE64_SOURCE
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <getopt.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define PRIME_DEBUG

/*##############################################################
  # debug definition
  #############################################################*/

#ifdef PRIME_DEBUG
#define STMT(stuff)   do { stuff } while (0)
#define PRIME_debug(a) STMT(                             \
        printf("[%s(%04d)] ", __FILE__[0] == '/'?   \
        ((strrchr(__FILE__,'/')==NULL)?__FILE__:(strrchr(__FILE__,'/')+1)):   \
        ((strrchr(__FILE__,'\\')==NULL)?__FILE__:(strrchr(__FILE__,'\\')+1)), \
             __LINE__);                                     \
    printf a;)
#else
#define PRIME_debug(a)
#endif

/*##############################################################
  # other defines
  #############################################################*/
/*
 * the bigger the sieve size, the faster the sieving process, for the same number of primes.
 * however,  when sieve size grows, more memory is needed and the speed-up margin decreases.
 */
//#define MAX_SIEVE_SIZE                   (100 * 1000 * 1000)

#define handle_error_en(en, msg) do { errno = en; perror(msg); exit(EXIT_FAILURE); } while (0)
#define handle_error(msg)  do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define PRIME_DB_FILE_NAME "prime.db"
#define LINE_COUNT  10          /* print 10 primes for each line */

#define K (1000)
#define M (1000 * K)
#define G (1000 * M)
#define T (M * M)

/*##############################################################
  # typedefs
  #############################################################*/
/* this allows 2^64 integer value on 32-bit platforms */
typedef unsigned long long int prime_t;

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
prime_t *g_prime = NULL;
prime_t *g_sieve = NULL;
prime_t g_max_sieve_size = 0;
/*##############################################################
  # static variables definition
  #############################################################*/
static char s_optstring[] = "hvpms";

static struct option const s_long_options[] = {
    {"help", no_argument, 0, 'h'},
    {"verbose", no_argument, 0, 'v'},
    {"print", no_argument, 0, 'p'},
    {"mmap", no_argument, 0, 'm'},
    {"smp", no_argument, 0, 's'},

    {0, 0, 0, 0}
};

/* flags to be determined by options */
static int s_show_help = 0;
static int s_verbose = 0;
static int s_print = 0;
static int s_smp = 0;
static int s_mmap = 0;          /* using mmap() for accessing prime db */
static prime_t s_num_primes = 0;
static char s_unit[10];

/* system physical memory info: page size and num of physical pages */
static int s_pagesize = 0;
static int s_phys_pages = 0;
/*##############################################################
  # local function forward declarations
  #############################################################*/
static void *thread_start(void *arg);
static int set_affinity(int core_idx);
static prime_t sieve_prime(prime_t next_index, prime_t * known_primes, int smp);
static void *thread_start(void *arg);
static int save_prime_db(prime_t next_index);
static int print_prime_db(prime_t prime_count);
static void process_args(int argc, char *argv[]);
static void show_help(void);

/*##############################################################
  # global function implementations
  #############################################################*/
int main(int argc, char *argv[])
{
    prime_t num_primes_in_db = 0, next_prime_index = 0;
    FILE *fp = NULL;

    struct stat fstat;
    int fd = -1;                /* file descriptor of the prime db */
    prime_t file_size = 0;
    int db_exist = 0;

    /*
     * process and print the option/arguments
     */

    process_args(argc, argv);

    if (s_show_help) {
        show_help();
        return 0;
    }

    PRIME_debug(("s_smp=%d, s_verbose=%d, s_print=%d, s_mmap=%d\n", s_smp, s_verbose, s_print, s_mmap));
    PRIME_debug(("s_num_primes=%llu\n", s_num_primes));

    /*
     * determine the sieve size and allocate it
     */
    s_pagesize = sysconf(_SC_PAGESIZE);
    s_phys_pages = sysconf(_SC_PHYS_PAGES);

    /* maximumly use half of the physical RAM for the sieve */
    g_max_sieve_size = s_pagesize * s_phys_pages / sizeof(prime_t) / 2;

    PRIME_debug(("pagesize=%d, phys_pages=%d=>total_ram=%d(MiB); max_sieve_size=%.1f (M)\n",
                 s_pagesize, s_phys_pages, s_pagesize * s_phys_pages / 1024 / 1024, (float)g_max_sieve_size / M));

    /* malloc the global sieve */
    g_sieve = (prime_t *) malloc(g_max_sieve_size * sizeof(prime_t));
    if (!g_sieve) {
        PRIME_debug(("malloc() for sieve failed.\n"));
        exit(1);
    }

    /*
     * setup the prime array
     */
    if (!s_mmap) {
        g_prime = (prime_t *) calloc(s_num_primes, sizeof(prime_t));
        if (!g_prime) {
            PRIME_debug(("ERROR: can not malloc array to store %llu prime numbers. try using '-m' option?\n", s_num_primes));
            if (g_sieve)
                free(g_sieve);
            exit(1);
        }
        /*
         * try to read the db into ram first
         */
        fp = fopen(PRIME_DB_FILE_NAME, "r");
        if (fp == NULL) {
            PRIME_debug(("INFO: %s does not exist.\n", PRIME_DB_FILE_NAME));
        } else {
            if (1 != fread(&num_primes_in_db, sizeof(prime_t), 1, fp)) {
                PRIME_debug(("ERROR: can not read prime count in %s\n", PRIME_DB_FILE_NAME));
                num_primes_in_db = 0;
                next_prime_index = 0;
            } else {

                PRIME_debug(("INFO: %llu of prime numbers are stored in '%s'. reading %llu of them...\n", num_primes_in_db,
                             PRIME_DB_FILE_NAME, s_num_primes < num_primes_in_db ? s_num_primes : num_primes_in_db));
                if (num_primes_in_db > s_num_primes)
                    num_primes_in_db = s_num_primes;

                if (num_primes_in_db != fread(g_prime, sizeof(prime_t), num_primes_in_db, fp)) {
                    PRIME_debug(("ERROR: reading db file '%s' failed. ignore the db content.", PRIME_DB_FILE_NAME));
                    num_primes_in_db = 0;
                    next_prime_index = 0;
                } else {
                    next_prime_index = num_primes_in_db;
                }
            }
            fclose(fp);
        }
    } else {

        file_size = (1 + s_num_primes) * sizeof(prime_t);
        PRIME_debug(("required file_size=%llu. (size_t)(-1)=%u\n", file_size, (size_t) (-1)));
        if (file_size > (size_t) (-1)) {
            PRIME_debug(("the file size is larger than 2^%d bytes, which is the maximum size can be mmap()ed. giving up...\n",
                         sizeof(size_t) * 8));
            exit(1);
        }

        /* get the file stat */
        if (-1 == stat(PRIME_DB_FILE_NAME, &fstat)) {
            PRIME_debug(("stat(%s) failed, errno=%d, assuming file does not exist.\n", PRIME_DB_FILE_NAME, errno));
            db_exist = 0;
        } else {
            db_exist = 1;
        }
        PRIME_debug(("db_exist=%d, st_size=%ld\n", db_exist, fstat.st_size));

        /* get the file descriptor */
        if ((fd = open(PRIME_DB_FILE_NAME, O_CREAT | O_RDWR | O_NOATIME, 00666)) == -1) {
            PRIME_debug(("open(%s,...) failed. errno=%d, abort.\n", PRIME_DB_FILE_NAME, errno));
            exit(1);
        }

        /* make sure the file grows to desired size before mmap() */
        if (!db_exist || file_size > fstat.st_size) {
            if (-1 == lseek64(fd, file_size - 1, SEEK_SET)) {
                PRIME_debug(("lseek64(%llu) failed. abort\n", file_size));
                exit(1);
            }
            write(fd, "", 1);
        }

        /* mmap the whole file */
        g_prime = (prime_t *) mmap(NULL, file_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (g_prime == MAP_FAILED) {
            PRIME_debug(("mmap(...,%s,...) failed, errno=%d, abort.\n", PRIME_DB_FILE_NAME, errno));
            close(fd);
            exit(1);
        }
        //PRIME_debug(("g_prime=%p\n", (void *)g_prime));

        if (db_exist) {
            num_primes_in_db = g_prime[0];
            PRIME_debug(("num_primes_in_db=%llu\n", num_primes_in_db));
            next_prime_index = s_num_primes < num_primes_in_db ? s_num_primes : num_primes_in_db;
        } else {
            num_primes_in_db = 0;
            next_prime_index = 0;
        }
        g_prime += 1;           /* skip the header: number of the primes in the db */
    }

    /*
     * now sieve when applicable...
     */

    while (next_prime_index < s_num_primes) {
        //PRIME_debug(("INFO: this session starts to find the prime number with index %llu...\n", next_prime_index));
        next_prime_index = sieve_prime(next_prime_index, g_prime, s_smp);
    }

    /*
     * save in db only if we have more and if not using mmap()...
     */
    if (next_prime_index > num_primes_in_db && !s_mmap) {
        save_prime_db(next_prime_index);
    }

    /*
     * print the primes to console
     */
    if (s_print)
        print_prime_db(next_prime_index);

    /*
     * munmap() when applicable
     */
    if (s_mmap) {
        if (next_prime_index > num_primes_in_db)
            *(g_prime - 1) = next_prime_index;
        munmap((void *)(g_prime - 1), file_size);
        g_prime = NULL;
        close(fd);
    }

    /*
     * free the sieve
     */
    if (g_sieve)
        free(g_sieve);

    return 0;
}

/*##############################################################
  # local function implementations
  #############################################################*/

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

/*
 * next_index [in]: the index of the next prime number to be determined. 
 * known_primes [in/out]: the array of the known primes, starting from
 *                 the 1st one (2) to the one before "next_index",
 *                 the function will add primes into the array.
 * smp [in]: bool, 1 for multi-threads.
 *
 * return: the index of the next un-determined prime number 
 *         return 0 for errors.
 */
static prime_t sieve_prime(prime_t next_index, prime_t * known_primes, int smp)
{
    //    static prime_t s_sieve[MAX_SIEVE_SIZE];

    prime_t last_prime, last_index;     /* the last known prime and its index */
    prime_t sieve_start, sieve_stop, sieve_size;        /* sieve range: [sieve_start, sieve_stop] */

    prime_t i, next_index_return = next_index;

    if (!known_primes)
        return 0;

    if (next_index == 0) {
        /* populate the first bunch of known primes */
        known_primes[0] = 2;
        known_primes[1] = 3;
        known_primes[2] = 5;
        known_primes[3] = 7;
        known_primes[4] = 11;
        known_primes[5] = 13;
        known_primes[6] = 17;
        known_primes[7] = 19;
        known_primes[8] = 23;

        PRIME_debug(("INFO: sieve session starts: next_prime_index=%llu\n", next_index));
        return 9;
    }

    /* calcuate the sieve size and populate the sieve with nature numbers */
    last_index = next_index - 1;
    last_prime = known_primes[last_index];

    sieve_start = last_prime + 1;
    sieve_stop = last_prime * last_prime;       /* this is the up-bound that the current known primes can sieve */
    sieve_size = sieve_stop - sieve_start + 1;

    if (sieve_size > g_max_sieve_size) {
        sieve_size = g_max_sieve_size;
        sieve_stop = sieve_start + sieve_size - 1;
    }

    PRIME_debug(("INFO: session starts: next_prime_index=%llu, sieve_range: [%llu, %llu], sieve_size:%llu\n",
                 next_index, sieve_start, sieve_stop, sieve_size));

    for (i = 0; i < sieve_size; i++)
        g_sieve[i] = sieve_start + i;

    /* this loop is the heart of the algo: sieve by all known primes...... */

    if (!smp) {
        for (i = 0; i <= last_index; i++) {
            prime_t the_prime = known_primes[i];
            prime_t smallest, sieve_index;

            /* find the first/smallest multiple of "the_prime" in the sieve */
            smallest = sieve_start / the_prime * the_prime;
            if (smallest < sieve_start)
                smallest += the_prime;
            sieve_index = smallest - sieve_start;
            if (sieve_index >= g_max_sieve_size)
                continue;

            do {
                g_sieve[sieve_index] = 0;
                sieve_index += the_prime;
            }
            while (sieve_index < sieve_size);

        }
    } else {

        /*
         * SMP version...
         *
         * a benchmark when sieving 50M primes on Intel E3-1230V2@3.3GHz (Ubuntu13.04),
         * using the same max sieve size 2M:
         *
         * - UP:
         * real 2m38.631s
         * user 2m38.000s
         * sys  0m0.232s
         *
         * - SMP (note the SMP effect that "user + sys > real" ): 
         * real 0m42.108s
         * user 4m54.324s
         * sys  0m0.420s
         */

        struct thread_info *tinfo;
        pthread_attr_t attr;
        int s;
        void *res;
        int tidx;               /* thread index */

        int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
        //PRIME_debug(("num_cores=%d\n", num_cores));

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
            tinfo[tidx].start_idx = tinfo[tidx].core_idx;
            tinfo[tidx].last_idx = last_index;
            tinfo[tidx].step = num_cores;
            tinfo[tidx].sieve = g_sieve;
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

    /* collect primes remain in the sieve */
    for (i = 0; i < sieve_size; i++) {
        if (g_sieve[i] != 0) {
            //PRIME_debug(("INFO: found new prime: %llu -> %llu\n", next_index_return, g_sieve[i]));
            known_primes[next_index_return] = g_sieve[i];
            next_index_return++;
            if (next_index_return >= s_num_primes)
                break;
        }
    }

    return next_index_return;
}

/* sieving function for each thread */
static void *thread_start(void *arg)
{
    prime_t i;
    struct thread_info *tinfo = (struct thread_info *)arg;

#if (0)
    PRIME_debug(("tid=%lu, core_idx=%d, start_idx=%llu, last_idx=%llu, step=%llu, sieve_size=%llu, sieve_start=%llu\n",
                 tinfo->tid, tinfo->core_idx, tinfo->start_idx, tinfo->last_idx, tinfo->step, tinfo->sieve_size,
                 tinfo->sieve_start));
#endif

    /* sanity check */
    if (!tinfo->known_primes || !tinfo->sieve) {
        PRIME_debug(("either known_primes[] or sieve[] is invalid. quit...\n"));
        exit(1);
    }

    set_affinity(tinfo->core_idx);

    /* start sieving */
    for (i = tinfo->start_idx; i <= tinfo->last_idx; i += tinfo->step) {

        prime_t the_prime = tinfo->known_primes[i];
        prime_t smallest, sieve_index;

        /* find the first/smallest multiple of "the_prime" in the sieve */
        smallest = tinfo->sieve_start / the_prime * the_prime;
        if (smallest < tinfo->sieve_start)
            smallest += the_prime;
        sieve_index = smallest - tinfo->sieve_start;
        if (sieve_index >= tinfo->sieve_size)
            continue;

        do {
            tinfo->sieve[sieve_index] = 0;
            sieve_index += the_prime;
        }
        while (sieve_index < tinfo->sieve_size);

    }

    return 0;
}

static int save_prime_db(prime_t num_of_primes)
{
    FILE *fp;

    fp = fopen(PRIME_DB_FILE_NAME, "wb");
    if (fp == NULL) {
        PRIME_debug(("ERROR: can not open file %s for writting...\n", PRIME_DB_FILE_NAME));
        return -1;
    } else {
        PRIME_debug(("INFO: saving %llu primes into db file %s...\n", num_of_primes, PRIME_DB_FILE_NAME));
        fwrite(&num_of_primes, sizeof(prime_t), 1, fp);
        fwrite(g_prime, sizeof(prime_t), num_of_primes, fp);
        fclose(fp);
    }

    return 0;
}

static int print_prime_db(prime_t prime_count)
{
    prime_t i, line_index;

    for (i = 0, line_index = 0; i < prime_count; i++) {
        if (i % LINE_COUNT == 0) {
            printf("\n%04lld: ", line_index);
            line_index++;
        }
        printf("%5lld ", g_prime[i]);
    }
    printf("\n");
    return 0;
}

static void process_args(int argc, char *argv[])
{
    int c, option_index;

    if (argc == 1) {
        s_show_help = 1;
        return;
    }

    for (;;) {
        c = getopt_long(argc, argv, s_optstring, s_long_options, &option_index);
        if (c == -1)
            break;

        switch (c) {
        case 'h':
            s_show_help = 1;
            break;
        case 'v':
            s_verbose = 1;
            break;
        case 'p':
            s_print = 1;
            break;
        case 's':
            s_smp = 1;
            break;
        case 'm':
            s_mmap = 1;
            break;
        default:
            break;
        }
    }

    if (optind < argc) {
        int n = sscanf(argv[optind], "%llu%s", &s_num_primes, s_unit);

        PRIME_debug(("s_num_primes=%llu, s_unit=%s\n", s_num_primes, s_unit));

        switch (n) {
        case 1:
            break;
        case 2:
            if (1 != strlen(s_unit)) {
                s_show_help = 1;
            } else {
                switch (s_unit[0]) {
                case 'k':
                case 'K':
                    s_num_primes *= K;
                    break;
                case 'm':
                case 'M':
                    s_num_primes *= M;
                    break;
                case 'g':
                case 'G':
                    s_num_primes *= G;
                    break;
                case 't':
                case 'T':
                    s_num_primes *= M;
                    s_num_primes *= M;
                    break;
                default:
                    s_show_help = 1;
                    break;
                }
            }
            break;
        default:
            s_show_help = 1;
            break;
        }

    } else {
        s_show_help = 1;
    }
}

static void show_help(void)
{

    fprintf(stderr, "Usage: sieve [options] ... num_primes\n\n");

    fprintf(stderr,
            "Options:\n"
            "  -h, --help       print this help, then exit\n"
            "  -v, --verbose    verbosely report processing\n"
            "  -p, --print      print out primes to console when done\n"
            "  -m, --mmap       using mmap() to access (rw) the prime db\n"
            "  -s, --smp        using multiple threads (on different cores) for sieving\n" "\n");

    fprintf(stderr,
            "Argument:\n"
            "  num_primes:      the total number of primes to be determined, starting from 2.\n"
            "                   can be of unit kK/mM/gG/tT, which are 10^3, 10^6, 10^9, and 10^12 respectively.\n");
}

/*##############################################################
  # local functions for debug only
  #############################################################*/
