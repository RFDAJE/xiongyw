#ifndef __FACT_H__
#define __FACT_H__

#include "prime.h"

struct factor_node;
typedef struct {
    prime_t prime_index;
    prime_t exponent;
    struct factor_node *next;
} factor_node;

factor_node *factorize(prime_t num, prime_t * db, prime_t db_size);
int free_factor_list(factor_node * root);

#endif
