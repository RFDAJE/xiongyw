#include <stdio.h>
#include <string.h>
#include <math.h>

#include "prime.h"
#include "sieve.h"
#include "db.h"
#include "gcd.h"
#include "fact.h"

#include "tests.h"

#define TESTS_DEBUG

/*##############################################################
  # debug definition
  #############################################################*/

#ifdef TESTS_DEBUG
#define STMT(stuff)   do { stuff } while (0)
#define TESTS_debug(a) STMT(                             \
        printf("[%s(%04d)] ", __FILE__[0] == '/'?   \
        ((strrchr(__FILE__,'/')==NULL)?__FILE__:(strrchr(__FILE__,'/')+1)):   \
        ((strrchr(__FILE__,'\\')==NULL)?__FILE__:(strrchr(__FILE__,'\\')+1)), \
             __LINE__);                                     \
    printf a;)
#else
#define TESTS_debug(a)
#endif

/*##############################################################
  # global function implementations
  #############################################################*/

/*
 * db: the prime db
 * max_db_idx: search boundary
 *
 * return: number of pairs; < 0 for error
 */
int print_twin_primes(prime_t * db, prime_t max_db_idx)
{
    prime_t i, ret = -1;

    if (!db)
        return ret;

    ret = 0;
    for (i = 0; i < max_db_idx; i++) {
        if ((db[i] + 2) == db[i + 1]) {
            ret += 1;
            TESTS_debug(("(i, i+1)=(%llu, %lld), (db[i], db[i+1])=(%llu, %llu)\n", i, i + 1, db[i], db[i + 1]));
        }
    }

    return ret;
}

int print_prime_of_prime(prime_t * db, prime_t max_db_idx)
{
    prime_t i, j = 0;

    for (i = 0; i <= max_db_idx; i++, j++) {
        if (db[i] > max_db_idx)
            break;
        TESTS_debug(("db2[%llu]=%llu\n", j, db[db[i]]));
    }

    return 0;
}

int output_asy_primes(prime_t * db, prime_t max_db_idx)
{
    prime_t i;
    float scale = 100.;

    printf("import fontsize;\n"
           "unitsize(4);\n"
           "real dot_radius = 10;\n"
           "pen border_pen = linewidth(0.8) + black;\n"
           "pen grid_pen = linewidth(0.01) + /* dashed + */ gray(0.1);\n" "pen dot_pen = linewidth(dot_radius * 2) + red;\n");

    /* draw dots */
    for (i = 0; i <= max_db_idx; i++){
        printf("dot((%llu,%llu), dot_pen);\n", i, (prime_t)log2(db[i]));
        //printf("dot((%llu,%llu), dot_pen);\n", i, db[i] / scale);
    }

    for(i = 0; db[i] <= max_db_idx; i ++){
        printf("dot((%llu,%llu), dot_pen);\n", i, (prime_t)log2(db[db[i]]));
        //printf("dot((%llu,%llu), dot_pen);\n", i, db[db[i]] / scale);
    }
        
    for(i = 0; db[db[i]] <= max_db_idx; i ++){
        printf("dot((%llu,%llu), dot_pen);\n", i, (prime_t)log2(db[db[db[i]]]));
        //printf("dot((%llu,%llu), dot_pen);\n", i, db[db[db[i]]] / scale);
    }
    
    for(i = 0; db[db[db[i]]] <= max_db_idx; i ++){
        printf("dot((%llu,%llu), dot_pen);\n", i, (prime_t)log2(db[db[db[db[i]]]]));
        //printf("dot((%llu,%llu), dot_pen);\n", i, db[db[db[db[i]]]] / scale);
    }

#if (0)
    /* grid */
    for (i = 1; i < max_db_idx; i++)
        printf("draw((%llu,0)--(%llu,%llu),grid_pen); \n", i, i, db[max_db_idx]);       /* vertical */
    for (i = 1; i < db[max_db_idx]; i++)
        printf("draw((0,%llu)--(%llu,%llu),grid_pen); \n", i, max_db_idx, i);    /* horizontal */
#endif
    
    /* border */
    printf("draw(box((0,0),(%llu,%llu)),border_pen);\n", max_db_idx, (prime_t)log2(db[max_db_idx]));
    //printf("draw(box((0,0),(%llu,%llu)),border_pen);\n", max_db_idx, db[max_db_idx] /scale);

    return 0;
}
