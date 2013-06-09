#define _GNU_SOURCE
#include <unistd.h>
#include <sched.h>
#include <pthread.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

typedef unsigned long long int prime_t;
#define TOTAL_PRIME_NUMBER (10 * 1000 * 1000)
#define MAX_SIEVE_SIZE (2000 * 1000)
#define handle_error_en(en, msg) do { errno = en; perror(msg); exit(EXIT_FAILURE); } while (0)
#define handle_error(msg)  do { perror(msg); exit(EXIT_FAILURE); } while (0)

prime_t* g_prime = NULL;

/* used as argument to thread_start() */
struct thread_info {            
    pthread_t thread_id;        /* id returned by pthread_create() */
    int core_idx;               /* the idx of the core this thread setaffinity to */

    prime_t* known_primes;      /* array of the known primes */
    prime_t start_idx;          /* the idx of the first prime used for sieving */
    prime_t last_idx;           /* the idx of the last prime used for sieving */
    prime_t step;               /* the step size of choosing the next prime to sieve */

    prime_t* sieve;             /* the sieve: an array of continuous numbers to be sieved */
    prime_t sieve_size;         /* the size of the sieve */
    prime_t sieve_start;        /* sieve[0] */
};

static void *thread_start(void *arg);

/* 
 * core_idx range: [0, num_cores-1] i
 * return: 0 for success, otherwise failure
 */
int stick_this_thread_to_core(int core_idx)
{
    int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
    if (core_idx < 0 || core_idx >= num_cores)
        return EINVAL;

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(core_idx, &cpuset);

    return pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
}

/*
 * next_index [in]: the index of the next prime number to be determined. 
 * known_primes [in/out]: the array of the known primes, starting from 
 * the 1st one (2) to the one before "next_index", the function will add primes into the array.
 *
 * return: the index of the next un-determined prime number 
 *         return 0 for errors.
 */
prime_t sieve_prime_smp(prime_t next_index, prime_t* known_primes)
{
    static prime_t s_sieve[MAX_SIEVE_SIZE];
    
    prime_t last_prime, last_index; /* the last known prime and its index */
    prime_t sieve_start, sieve_stop, sieve_size; /* sieve range: [sieve_start, sieve_stop] */
        prime_t *sieve; /* the sieve array */
        
	prime_t i,  next_index_return = next_index;
	
	if(!known_primes)
		return 0;

	if(next_index == 0){
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

		printf("INFO: sieve session starts: next_prime_index=%lld\n", next_index);
		return 9;
	}

	/* calcuate the sieve size and populate the sieve with nature numbers */
	last_index = next_index - 1;
	last_prime = known_primes[last_index];

	sieve_start = last_prime + 1;
	sieve_stop = last_prime * last_prime; /* this is the up-bound that the current known primes can sieve */
	sieve_size = sieve_stop - sieve_start + 1;

	
	if(sieve_size > MAX_SIEVE_SIZE){
		sieve_size = MAX_SIEVE_SIZE;
		sieve_stop = sieve_start + sieve_size - 1;
	}

	printf("INFO: sieve session starts: next_prime_index=%lld. ", next_index);
	printf("sieve_range: [%lld, %lld]; sieve_size:%lld\n", sieve_start, sieve_stop, sieve_size);
	for(i = 0; i < sieve_size; i ++)
		s_sieve[i] = sieve_start + i;

#if (0) /* UP version */
	/* this loop is the heart of the algo: sieve by all known primes...... */
	for(i = 0; i <= last_index; i ++){
            prime_t the_prime = known_primes[i];
            prime_t smallest, sieve_index;

		/* find the first/smallest multiple of "the_prime" in the sieve */
		smallest = sieve_start / the_prime * the_prime;
		if(smallest < sieve_start)
			smallest += the_prime;
		sieve_index = smallest - sieve_start;
		if(sieve_index >= MAX_SIEVE_SIZE)
			continue;
		
		/* printf("INFO: prime[%d]=%d. smallest=%d, sieve_index=%d\n", i, the_prime, smallest, sieve_index); */

		do{
			s_sieve[sieve_index] = 0;
			sieve_index += the_prime;
		}while(sieve_index < sieve_size);

	}
#else  /* SMP version */

        {
                struct thread_info *tinfo;
    pthread_attr_t attr;
    int res;
    int s, tnum;

    int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
    printf("num_cores=%d\n", num_cores);

    /* initialize thread creation attributes */

    s = pthread_attr_init(&attr);
    if (s != 0)
        handle_error_en(s, "pthread_attr_init");

    /* allocate memory for pthread_create() arguments */

    tinfo = calloc(num_cores, sizeof(struct thread_info));
    if (tinfo == NULL)
        handle_error("calloc");

    /* create one thread for each core */

    for (tnum = 0; tnum < num_cores; tnum++) {
        tinfo[tnum].core_idx = tnum;
        tinfo[tnum].known_primes = known_primes;
        tinfo[tnum].start_idx = tinfo[tnum].core_idx;
        tinfo[tnum].last_idx = last_index;
        tinfo[tnum].step = num_cores;
        tinfo[tnum].sieve = s_sieve;
        tinfo[tnum].sieve_size = sieve_size;
        tinfo[tnum].sieve_start = sieve_start;

        s = pthread_create(&tinfo[tnum].thread_id, &attr, &thread_start, &tinfo[tnum]);
        if (s != 0)
            handle_error_en(s, "pthread_create");
    }

    /* destroy the thread attributes object, since it is no longer needed */
    s = pthread_attr_destroy(&attr);
    if (s != 0)
        handle_error_en(s, "pthread_attr_destroy");

    /* now join with each thread, and display its returned value */
    for (tnum = 0; tnum < num_cores; tnum++) {
        s = pthread_join(tinfo[tnum].thread_id, (void *)(&res));
        if (s != 0)
            handle_error_en(s, "pthread_join");

        printf("Joined with thread %d; returned value was %d\n", tinfo[tnum].thread_id, (int)res);
    }

    free(tinfo);

        }
#endif
        
	/* collect primes remain in the sieve */
	for(i = 0; i < sieve_size; i ++){
		if(s_sieve[i] != 0){
			/* printf("INFO: found new prime: %d -> %d\n", next_index_return, g_sieve[i]); */
			known_primes[next_index_return] = s_sieve[i];
			next_index_return ++;
			if(next_index_return >= TOTAL_PRIME_NUMBER)
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

    printf("tid=%d, core_idx=%d, start_idx=%lld, last_idx=%lld, step=%lld, sieve_size=%lld, sieve_start=%lld\n",
           tinfo->thread_id,
           tinfo->core_idx,
           tinfo->start_idx,
           tinfo->last_idx,
           tinfo->step,
           tinfo->sieve_size,
           tinfo->sieve_start);

    /* sanity check */
    if(!tinfo->known_primes || !tinfo->sieve){
        printf("either known_primes[] or sieve[] is invalid. quit...\n");
        exit(1);
    }
    
    stick_this_thread_to_core(tinfo->core_idx);

    /* start sieving */
	for(i = tinfo->start_idx; i <= tinfo->last_idx; i += tinfo->step){
            prime_t the_prime = tinfo->known_primes[i];
            prime_t smallest, sieve_index;

		/* find the first/smallest multiple of "the_prime" in the sieve */
		smallest = tinfo->sieve_start / the_prime * the_prime;
		if(smallest < tinfo->sieve_start)
			smallest += the_prime;
		sieve_index = smallest - tinfo->sieve_start;
		if(sieve_index >= tinfo->sieve_size)
			continue;
		
		do{
			tinfo->sieve[sieve_index] = 0;
			sieve_index += the_prime;
		}while(sieve_index < tinfo->sieve_size);

	}
    

    return 0;
}

#define PRIME_DB_FILE_NAME "prime2.db"
int save_prime_db(prime_t next_index)
{
	FILE* fp;
	
	fp = fopen(PRIME_DB_FILE_NAME, "wb");
	if(fp == NULL){
		printf("ERROR: can not open file %s for writting...\n", PRIME_DB_FILE_NAME);
		return -1;
	}
	else{
		fwrite(&next_index, sizeof(prime_t), 1, fp);
		fwrite(g_prime, sizeof(prime_t), next_index, fp);
		fclose(fp);
	}

	return 0;
}


int main(int argc, char *argv[])
{
	prime_t i, j, next_prime_index = 0;
	FILE* fp;

	/* a value 0 means the prime number at that index is not yet determined */
	g_prime = (prime_t*)calloc(TOTAL_PRIME_NUMBER, sizeof(prime_t));
	if(!g_prime){
		printf("ERROR: can not malloc array to store prime numbers, abort!\n");
		return - 1;
	}
	
	/* try to read the db into ram first */
	fp = fopen(PRIME_DB_FILE_NAME, "r");
	if(fp == NULL){
		printf("INFO: %s does not exist.\n", PRIME_DB_FILE_NAME);
	}
	else{
		if(1 != fread(&next_prime_index, sizeof(prime_t), 1, fp)){
			printf("ERROR: can not read prime count %lld in %s\n", next_prime_index, PRIME_DB_FILE_NAME);
			next_prime_index = 0;
		}
		else{
			printf("INFO: %lld of prime numbers are stored in '%s'. reading it...\n", next_prime_index, PRIME_DB_FILE_NAME);
			if(next_prime_index >= TOTAL_PRIME_NUMBER)
				next_prime_index = TOTAL_PRIME_NUMBER;
			if(next_prime_index != fread(g_prime, sizeof(prime_t), next_prime_index, fp)){
				printf("ERROR: reading db file '%s' failed. ignore the db content.", PRIME_DB_FILE_NAME);
				next_prime_index = 0;
			}
		}
		fclose(fp);
	}

	printf("INFO: this session starts to find the prime number with index %lld...\n", next_prime_index);

	do{
		next_prime_index = sieve_prime_smp(next_prime_index, g_prime);
	}while(next_prime_index < TOTAL_PRIME_NUMBER) ;

	save_prime_db(next_prime_index);

        return 0;
}
