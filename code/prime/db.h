#ifndef __DB_H__
#define __DB_H__

#include "prime.h"

/*
 * max_size: max num of primes to be stored in db
 * is_mmap: using mmap for db implementation or not
 * current_size* [out]: the current db size
 * 
 * return the prime db array, NULL for error
 */
prime_t *db_init(prime_t max_size, prime_t * current_size, int is_mmap);

/*
 * db_size: the number of primes should be stored in db
 *
 * return 0 for success, otherwise failure
 */
int db_fini(prime_t db_size);

#endif                          /* __DB_H__ */
