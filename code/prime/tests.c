#include <stdio.h>
#include <string.h>

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
