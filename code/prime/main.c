/*
 * noted(bruin, 2013-06-10): updated to support SMP and getopt
 * noted(bruin, 2013-06-13): added mmap() for saving primes
 * noted(bruin, 2013-06-14): set the max sieve size according to physical ram size
 * noted(bruin, 2013-06-15): not sieving even numbers added; tested using byte as
 *    flag in sieve, the performance drops too much...idea dropped; optimizing
 *    the second loop of the sieving process: may not applicable in smp scenario;
 *    compress the db? to be investigated...
 * noted(bruin, 2013-06-20): split the code for adding db.[ch]
 *    todo: add gcd/factore, and test modules
 */
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <getopt.h>
#include <sys/types.h>

#include "prime.h"
#include "sieve.h"
#include "db.h"
#include "gcd.h"
#include "fact.h"

#include "tests.h"

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

#define LINE_COUNT  10          /* print 10 primes for each line */

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
static int print_prime_db(prime_t prime_count, prime_t * db);
static void process_args(int argc, char *argv[]);
static void show_help(void);

/*##############################################################
  # global function implementations
  #############################################################*/
int main(int argc, char *argv[])
{
    prime_t num_primes_in_db = 0, next_prime_index = 0;
    prime_t *db = NULL;

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

    /* init db */
    db = db_init(s_num_primes, &num_primes_in_db, s_mmap);
    if (!db) {
        PRIME_debug(("db_init() failed. abort...\n"));
        exit(1);
    }
    PRIME_debug(("num_primes_in_db=%llu\n", num_primes_in_db));

    if (num_primes_in_db >= s_num_primes) {
        next_prime_index = s_num_primes;
    } else {
        next_prime_index = num_primes_in_db;
    }

    /* init sieve */
    sieve_init();

    /* do sieve */
    while (next_prime_index < s_num_primes) {
        //PRIME_debug(("INFO: this session starts to find the prime number with index %llu...\n", next_prime_index));
        next_prime_index = sieve_prime(db, next_prime_index, s_num_primes, s_smp);
    }

    if (s_print)
        print_prime_db(s_num_primes, db);

    /*
     * do some tests
     */
    //print_twin_primes(db, s_num_primes - 1);
    //print_prime_of_prime(db, s_num_primes - 1);

    /* we are done */
    sieve_fini();
    db_fini(s_num_primes);

    return 0;
}

/*##############################################################
  # local function implementations
  #############################################################*/

static int print_prime_db(prime_t prime_count, prime_t * db)
{
    prime_t i, line_index;

    for (i = 0, line_index = 0; i < prime_count; i++) {
        if (i % LINE_COUNT == 0) {
            printf("\n%04lld: ", line_index);
            line_index++;
        }
        printf("%5lld ", db[i]);
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
