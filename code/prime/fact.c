#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "fact.h"

#define FACT_DEBUG

/*##############################################################
  # debug definition
  #############################################################*/

#ifdef FACT_DEBUG
#define STMT(stuff)   do { stuff } while (0)
#define FACT_debug(a) STMT(                             \
        printf("[%s(%04d)] ", __FILE__[0] == '/'?   \
        ((strrchr(__FILE__,'/')==NULL)?__FILE__:(strrchr(__FILE__,'/')+1)):   \
        ((strrchr(__FILE__,'\\')==NULL)?__FILE__:(strrchr(__FILE__,'\\')+1)), \
             __LINE__);                                     \
    printf a;)
#else
#define FACT_debug(a)
#endif

/*##############################################################
  # global function implementations
  #############################################################*/

factor_node *factorize(prime_t num, prime_t * db, prime_t db_size)
{
    prime_t i, quotient, up_bound, the_prime;
    factor_node *root = NULL, *last_node = NULL;

    /* FACT_debug(("factorize(%d)...\n", num)); */

    if (num < 2) {
        return root;            /* 0 and 1 is not considered */
    }

    quotient = num;
    up_bound = num;
    for (i = 0; i < up_bound; i++) {
        int node_created = 0;
        if (i < db_size) {
            the_prime = db[i];
        } else {
            FACT_debug(("the number of prime numbers is too small for factorizing %lld. quitting...\n", num));
            return NULL;
        }

        //FACT_debug(("%dth prime=%d, quotient=%d, up_bound=%d.\n", i, the_prime, quotient, up_bound));

        while ((quotient % the_prime) == 0) {

            // FACT_debug(("factor found: %d\n", the_prime)); 

            if (!node_created) {

                /* create the node */
                factor_node *tmp = (factor_node *) malloc(sizeof(factor_node));
                if (!tmp) {
                    FACT_debug(("ERROR: malloc() for node failed.\n"));
                    free_factor_list(root);
                    root = NULL;
                    return root;
                }
                tmp->prime_index = i;
                tmp->exponent = 0;
                tmp->next = NULL;
                node_created = 1;

                /* maintain the list struct */
                if (root == NULL) {
                    root = tmp;
                } else {
                    last_node->next = (struct factor_node *)tmp;
                }
                last_node = tmp;

            }

            last_node->exponent++;

            quotient /= the_prime;
#if (0)
            FACT_debug(("   quotient=%d.\n", quotient));
#endif
        }
        up_bound = quotient;
    }

#if (0)
    {
        /* print the factorized result */
        factor_node *tmp = root;
        FACT_debug(("%d=", num));
        while (tmp) {
            FACT_debug(("%d(%d)^%d ", db[tmp->prime_index], tmp->prime_index, tmp->exponent));
            tmp = tmp->next;
        }
        FACT_debug(("\n"));
    }
#endif

    return root;
}

int free_factor_list(factor_node * root)
{
    factor_node *tmp = root, *tmp2 = NULL;

    while (tmp) {
        tmp2 = (factor_node *) (tmp->next);
        free(tmp);
        tmp = tmp2;
    }

    return 0;
}
