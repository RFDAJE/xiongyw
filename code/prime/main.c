/*
 * noted(bruin, 2013-06-10): updated to support SMP and getopt
 * noted(bruin, 2013-06-13): added mmap() for saving primes
 * noted(bruin, 2013-06-14): set the max sieve size according to physical ram size
 * noted(bruin, 2013-06-15): not sieving even numbers added; tested using byte as
 *    flag in sieve, the performance drops too much...idea dropped; optimizing
 *    the second loop of the sieving process: may not applicable in smp scenario;
 *    compress the db? to be investigated...
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

#include "sieve.h"

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

#define PRIME_DB_FILE_NAME "prime.db"
#define LINE_COUNT  10          /* print 10 primes for each line */

/*##############################################################
  # typedefs
  #############################################################*/

/*##############################################################
  # globle variables definition
  #############################################################*/
prime_t *g_prime = NULL;

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

/*##############################################################
  # local function forward declarations
  #############################################################*/
static int save_prime_db(prime_t next_index);
static int print_prime_db(prime_t prime_count);
static void process_args(int argc, char *argv[]);
static void show_help(void);

static int check_prime_between_n2p1_n2pn(void);
static int check_prime_between_ns_np1s(void);
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

    sieve_init();

    /*
     * setup the prime array
     */
    if (!s_mmap) {
        g_prime = (prime_t *) calloc(s_num_primes, sizeof(prime_t));
        if (!g_prime) {
            PRIME_debug(("ERROR: can not malloc array to store %llu prime numbers. try using '-m' option?\n", s_num_primes));
            sieve_fini();
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
        PRIME_debug(("required file_size=%llu. max mmap() length: (size_t)(-1)=%lu\n", file_size, (size_t) (-1)));
        if (file_size > (size_t) (-1)) {
            PRIME_debug(("the file size is larger than 2^%lu bytes, which is the maximum size can be mmap()ed. giving up...\n",
                         sizeof(size_t) * 8));
            sieve_fini();
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
        next_prime_index = sieve_prime(g_prime, next_prime_index, s_num_primes, s_smp);
    }

    /*
     * save in db only if we have more and if not using mmap()...
     */
    if (next_prime_index > num_primes_in_db && !s_mmap) {
        save_prime_db(next_prime_index);
    }
    //check_prime_between_n2p1_n2pn();
    // check_prime_between_ns_np1s();

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

 EXIT:

    sieve_fini();

    return 0;
}

/*##############################################################
  # local function implementations
  #############################################################*/

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

/*
 * check wheather or not there is at least one prime in [n^2+1, n^2+n]
 */
static int check_prime_between_n2p1_n2pn(void)
{
    prime_t n, n2p1, n2pn, idx;
    int found;
    for (n = 0;; n++) {

        n2p1 = n * n + 1;
        n2pn = n * n + n;

        if (n2pn > g_prime[s_num_primes - 1]) {
            PRIME_debug(("valid at least upto n=%lld, no enough primes in the db\n", n - 1));
            PRIME_debug(("n^2+n=%llu\n", (n - 1) * (n - 1) + n));
            PRIME_debug(("lagest prime in db: g_prime[%llu]=%llu\n", s_num_primes - 1, g_prime[s_num_primes - 1]));
            return 0;
        }

        found = 0;

        for (idx = 0; idx < s_num_primes; idx++) {
            if (g_prime[idx] >= n2p1 || g_prime[idx] <= n2pn) {
                found = 1;
                goto c1;
            }
        }
 c1:
        if (!found) {
            PRIME_debug(("not found for n=%llu\n", n));
            return 0;
        }
    }

    return 0;
}

/*
 * check wheather or not there is at least one prime in [n^2, (n+1)^2]
 * Legendre conjection
 */
static int check_prime_between_ns_np1s(void)
{
    prime_t n, ns, np1s, idx;
    int found;
    for (n = 0;; n++) {

        ns = n * n;
        np1s = (n + 1) * (n + 1);

        if (np1s > g_prime[s_num_primes - 1]) {
            PRIME_debug(("legendre conjection is valid at least upto n=%lld, no enough primes in the db\n", n - 1));
            PRIME_debug(("(n+1)^2=%llu\n", n * n));
            PRIME_debug(("lagest prime in db: g_prime[%llu]=%llu\n", s_num_primes - 1, g_prime[s_num_primes - 1]));
            return 0;
        }

        found = 0;

        for (idx = 0; idx < s_num_primes; idx++) {
            if (g_prime[idx] >= ns || g_prime[idx] <= np1s) {
                found = 1;
                goto c1;
            }
        }
 c1:
        if (!found) {
            PRIME_debug(("not found for n=%llu\n", n));
            return 0;
        }
    }

    return 0;
}

/*##############################################################
  # local functions for debug only
  #############################################################*/

/*
 * benchmarks
 *
 *
  platform: Intel E3-1230V2@3.3GHz, 8GiB RAM, 128GB SSD, Ubuntu13.04 64-bit

 * 2013-06-10: using the same max sieve size 2M, sieving 50M primes
- UP:
real 2m38.631s
user 2m38.000s
sys 0m0.232s
 
- SMP (note the SMP effect that "user + sys > real" ):
real 0m42.108s
user 4m54.324s
sys 0m0.420s

 * 2013-06-15:  not sieving even numbers:
 bruin@u1304:~/github/xiongyw/code/prime$ rm prime.db
 bruin@u1304:~/github/xiongyw/code/prime$ time { ./sieve 50m; } | grep 0m

 real0m18.001s
 user0m16.608s
 sys0m1.000s
 bruin@u1304:~/github/xiongyw/code/prime$ rm prime.db
 bruin@u1304:~/github/xiongyw/code/prime$ time { ./sieve 50m -s; } | grep 0m

 real0m10.236s
 user0m51.632s
 sys0m1.196s

 * 2013-06-15: generating 10 billion primes
 bruin@u1304:~/github/xiongyw/code/prime$ time ./sieve 10g -ms

 real202m39.121s
 user577m6.644s
 sys143m37.072s
  
 
 */
