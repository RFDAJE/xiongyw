#ifndef __SIEVE_H__
#define __SIEVE_H__

#define K (1000)
#define M (1000 * K)
#define G (1000 * M)
#define T (M * M)

/* this allows 2^64 integer value on 32-bit platforms */
typedef unsigned long long int prime_t;

prime_t sieve_init(void);
void sieve_fini(void);
prime_t sieve_prime(prime_t * known_primes, prime_t start_idx, prime_t stop_idx, int smp);

#endif                          /* __SIEVE_H__ */
