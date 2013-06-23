#ifndef __TESTS_H__
#define __TESTS_H__

#include "prime.h"

/*
 * db: the prime db
 * max_db_idx: search boundary
 *
 * return: number of pairs; < 0 for error
 */
int print_twin_primes(prime_t * db, prime_t max_db_idx);

int print_prime_of_prime(prime_t * db, prime_t max_db_idx);


int output_asy_primes(prime_t * db, prime_t max_db_idx);

#endif                          /* __TESTS_H__  */
