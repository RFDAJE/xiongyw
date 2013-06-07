/* created(bruin, 2006-07-14): generating prime number by "Sieve of Eratosthenes" from ancient greek */

/* noted(bruin, 2013-06-07): prime number on the web, https://oeis.org/A000040 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* this could be as large as 2^64 on 64-bit machines */
typedef unsigned long long int prime_t;

/* use this file to save known prime numbers already calculated.
    the first sizeof(prime_t) bytes of the file is the total number of primes stored in the db,
    following by an array of primes. each element is a prime_t, and the index of the array is the
    index of the prime number. e.g., the first bunch of prime number should be:

    index: prime
    -----  -----
    0:       2 
    1:       3
    2:       5
    3:       7
    4:      11
    ......
    
  */
#define PRIME_DB_FILE_NAME "prime.db"

/* how many prime numbers to be stored in the db, starting from the first prime number "2" */
#define TOTAL_PRIME_NUMBER (300 * 1000 * 1000)   

/* the maximum sieve size */
#define MAX_SIEVE_SIZE       2000000 

struct factor_node;
typedef struct{
	prime_t prime_index;
	prime_t exponent;
	struct factor_node* next;
}factor_node;

prime_t *g_prime;
prime_t g_sieve[MAX_SIEVE_SIZE];





prime_t sieve_prime(prime_t next_index);
int save_prime_db(prime_t next_index);
int print_prime_db(prime_t next_index);
int free_factor_list(factor_node* root);
factor_node* factorize(prime_t num);
prime_t get_gcd_2(int a, int b, int* x0, int* y0, int* steps); /* added(bruin, 2006-07-24) */
prime_t get_gcd_n(int n, int a[]); /* added(bruin, 2006-07-25) */

/* return 1 if "index" found in list "root" */
int s_is_index_found(factor_node* root, int index)
{
	while(root){
		if(root->prime_index == index)
			return 1;
		root=(factor_node*)(root->next);
	}
	return 0;
}

int main()
{

	prime_t i, j, next_prime_index = 0;
	FILE* fp;

	g_prime = (prime_t*)malloc(sizeof(prime_t) * TOTAL_PRIME_NUMBER);
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
		next_prime_index = sieve_prime(next_prime_index);
	}while(next_prime_index < TOTAL_PRIME_NUMBER) ;

	save_prime_db(next_prime_index);

	if(next_prime_index > TOTAL_PRIME_NUMBER)
		next_prime_index = TOTAL_PRIME_NUMBER;

#if (0)
	/* print the primes to STDOUT */
	print_prime_db(next_prime_index);
#endif

#if (0)
	/* test: cubic sum and factorization */
	for(i = 0; i < 100; i ++){
		factor_node *tmp, *root;
		prime_t sum = g_prime[i] * g_prime[i] * g_prime[i] + g_prime[i + 1] * g_prime[i + 1] * g_prime[i + 1];
		prime_t num_primes = 0;  /* how many different prime factors */
		prime_t exp_sum = 0;     /* sum of exponent of each prime factor */
		prime_t num_factors = 1; /* number of factors */
			
		printf("%4d(%d)^3 + %4d(%d)^3 = %d = ", g_prime[i], i, g_prime[i + 1], i + 1, sum);

		tmp = root =	factorize(sum);

		/* print the factorized result */
		while(tmp){
			num_primes ++;
			exp_sum += tmp->exponent;
			num_factors *= (tmp->exponent + 1);
			printf("%4d(%d)^%d ", g_prime[tmp->prime_index], tmp->prime_index, tmp->exponent);
			tmp = tmp->next;
		}
		printf(" => %3d, %2d, %3d\n", num_primes, exp_sum, num_factors);
		
		free_factor_list(root);
	}
#endif

#if (0)
	/* test: number of prime factors and any different factors */
	for(i = 20000; i < 100000; i ++){
		factor_node *tmp, *root;
		prime_t num_primes = 0;  /* how many different prime factors */
		prime_t exp_sum = 0;     /* sum of exponent of each prime factor */
		prime_t num_factors = 1; /* number of factors */
		double loglog;
		
		printf("%5d =  ", i);

		tmp = root =	factorize(i);

		/* print the factorized result */
		while(tmp){
			num_primes ++;
			exp_sum += tmp->exponent;
			num_factors *= (tmp->exponent + 1);
			/* printf("%4d(%d)^%d ", g_prime[tmp->prime_index], tmp->prime_index, tmp->exponent); */
			tmp = tmp->next;
		}
		/* printf(" => prime=%d loglog(%d)=%f, factor=%3d, log(f)=%f\n", num_primes, i, log(log(i)), num_factors, log(num_factors)); */
		loglog = log(log(i));
		printf(" => prime=%lld loglog(%d)=%f, delta=%f\n", num_primes, i, loglog, num_primes - loglog); 
		
		free_factor_list(root);
	}

#endif


#if (0)
	/* test: get gcd */
	for(i = 1000; i < 2000; i ++){
		prime_t b = 210;
		int steps = 0;
		prime_t gcd = get_gcd_2(i, b, NULL, NULL, &steps);
		/* printf("<==(%4d, %4d)=%4d, step=%2d (%f)\n", i, b, gcd, steps, 2*log(b/2.));  */
	}

	for(i = 0; i < 10; i ++){
		prime_t gcd = get_gcd_n(i, g_prime);
		printf("get_gcd_n(%d..)=%d\n", i, gcd);
	}
#endif

#if (0)
	/* test: factorization for numbers in one modulus */
	for(i = 1; i < 100; i ++){
		int mod = 12; /* modulus */
		int res = 1;  /* residue */
		prime_t num_primes = 0;  /* how many different prime factors */
		prime_t exp_sum = 0;     /* sum of exponent of each prime factor */
		prime_t prime_index_sum = 0; /* index sum of prime factors */ 
		prime_t num_factors = 1;

		printf("\n%3d*%d+%d=%5d=", i, mod, res, mod*i+res);
		factor_node *tmp = factorize(mod * i + res);
		while(tmp){
			num_primes ++;
			exp_sum += tmp->exponent;
			prime_index_sum += tmp->prime_index;
			num_factors *= (tmp->exponent + 1);
			printf("%d^%d ", g_prime[tmp->prime_index], tmp->exponent);
			tmp = tmp->next;
		}
		printf("num_prime=%d exp_sum=%d, idx_sum=%d num_fac=%d", num_primes, exp_sum, prime_index_sum, num_factors);
		free_factor_list(tmp);
	}
	printf("\n");
#endif	


#if (0)
	/* test: n1+n2=? */

	for(i = 2; i < 10000; i ++){
		for(j = 2; j < 1000; j ++){
			if(i == j) 
				continue;
			factor_node *n1=factorize(i);
			factor_node *n2=factorize(j);
			factor_node *tmp;
			printf("\ni=%d, j=%d { ", i, j);
			tmp=n1;
			while(tmp){
				printf("%d,", tmp->prime_index);
				tmp = tmp->next;
			}
			printf("|");
			tmp=n2;
			while(tmp){
				printf("%d", tmp->prime_index);
				if(s_is_index_found(n1, tmp->prime_index)) printf("$"); 
				printf(",");
				tmp = tmp->next;
			}
			printf("}={");

			
			
			factor_node *n3 = factorize(i+j);
			tmp=n3;
			while(tmp){
				printf("%d", tmp->prime_index);
				if(s_is_index_found(n1, tmp->prime_index)) printf("#");
				if(s_is_index_found(n2, tmp->prime_index)) printf("@");
				printf(",");
				tmp = tmp->next;
			}
			printf("}");
			
			free_factor_list(n1);
			free_factor_list(n2);			
			free_factor_list(n3);

		}
	}
#endif

#if (0)
	/* test cesaro's theorem: prob(a_|_b)=6/(pi^2) */

	for(i = 1, j = 0; i < 100000; i ++){
		int a, b, gcd;

		a = random();
		b = random();
		gcd = get_gcd_2(a, b, NULL, NULL, NULL);
		if(gcd == 1){
			j ++;
			printf("%d (a=%12d, b=%12d)=1: %f\n", i, a, b, j * 1.0 / i);
		}
		else{
			printf("%d (a=%12d, b=%12d)#1: %f\n", i, a, b, j * 1.0 / i);
		}


	}
#endif

#if (0)
	/* test: prob(a_|_b_|_c)=0.28519.. */

	for(i = 1, j = 0; i < 100000; i ++){
		int a, b, c, ab, ac, bc;

		a = random();
		b = random();
		c = random();
		ab = get_gcd_2(a, b, NULL, NULL, NULL);
		bc = get_gcd_2(b, c, NULL, NULL, NULL);
		ac = get_gcd_2(a, c, NULL, NULL, NULL);
		if(ab == 1 && ac == 1 && bc == 1){
			j ++;
			printf("%d (%12d, %12d, %12d)=1: %f\n", i, a, b, c, j * 1.0 / i);
		}
		else{
			printf("%d (%12d, %12d, %12d)#1: %f\n", i, a, b, c, j * 1.0 / i);
		}
	}
#endif

#if (0)
	/* test: prob((a,b,c)=1)=0.83247=1/zeta(3)
	         i.e.: prob(3)=1/zeta(3)
	 */

	for(i = 1, j = 0; i < 100000; i ++){
		int a[3], gcd;

		a[0] = random();
		a[1] = random();
		a[2] = random();
		gcd = get_gcd_n(3, a);
		if(gcd == 1){
			j ++;
			printf("%d (%12d, %12d, %12d)=1: %f\n", i, a[0], a[1], a[2], j * 1.0 / i);
		}
		else{
			printf("%d (%12d, %12d, %12d)#1\n", i, a[0], a[1], a[2]);
		}
	}
#endif

#if (0)
	/* test: prob(4)=1/zeta(4)=90/pi^4=0.9239
      generally we have prob(n)=1/zeta(n), n>1	 */

	for(i = 1, j = 0; i < 100000; i ++){
		int a[4], gcd;

		a[0] = random();
		a[1] = random();
		a[2] = random();
		a[3] = random();
		gcd = get_gcd_n(4, a);
		if(gcd == 1){
			j ++;
			printf("%d (%12d, %12d, %12d, %12d)=1: %f\n", i, a[0], a[1], a[2], a[3], j * 1.0 / i);
		}
		else{
			printf("%d (%12d, %12d, %12d, %12d)#1\n", i, a[0], a[1], a[2], a[3]);
		}
	}
#endif

#if (0)
	/* test: prob(5)=1/zeta(5)=1/1.0369277	 */

	for(i = 1, j = 0; i < 100000; i ++){
		int a[5], gcd;

		a[0] = random();
		a[1] = random();
		a[2] = random();
		a[3] = random();
		a[4] = random();
		gcd = get_gcd_n(5, a);
		if(gcd == 1){
			j ++;
			printf("%d (%12d, %12d, %12d, %12d...)=1: %f\n", i, a[0], a[1], a[2], a[3], j * 1.0 / i);
		}
		else{
			printf("%d (%12d, %12d, %12d, %12d...)#1\n", i, a[0], a[1], a[2], a[3]);
		}
	}
#endif

#if (0)
	/* test: FP(n) denotes the total number of primes appeared in the factorization 
	      of the first n members of the fibonacci series.
	      we define F(1)=2 and F(2)=3. 
	      thus FP(1)=1, FP(2)=2, FP(3)=3 (2,3,5), FP(4)=3 (2,3,5)...
	   this is to see if there are any patterns in FP(n).
	 */
	{
		int p_idx[100000];       /* store index of primes found */
		int i, j, n=2, fpn=2;    /* n and number of FP(n) */
		int f1=2 ,f2=3, f3;      /* f1+f2=f3 */
		factor_node* root = NULL;

		p_idx[0] = 0;
		p_idx[1] = 1;

		/* let's start the iteration */
		for(i = 3; i < 50000; i ++){
			
			f3=f1+f2;
			f1=f2;
			f2=f3; /* for next loop */

			if(root){
				free_factor_list(root);
				root = NULL;
			}
				
			root = factorize(f3);
			if(!root){
				printf("ERROR: factorize(%d) failed.\n", f3);
				return (1);
			}

			while(root){

				int prime_index = root->prime_index;
				int is_exist=0; 

				for(j = 0; j < fpn; j ++){
					if(p_idx[j] == prime_index){
						is_exist =1;
						break;
					}
				}
				if(!is_exist){
					p_idx[fpn] = prime_index;
					fpn ++;
				}
				
				root = (factor_node*)(root->next);
			}

			printf("f(%d)=%d, FP(%d)=%d, %f\n", i, f3, i, fpn, fpn * 1.0 / i);
				
		}

		if(root)
			free_factor_list(root);
	}
	
#endif

	free(g_prime);

	return 0;
}


/* return the next_prime_index */
prime_t sieve_prime(prime_t next_index)
{
	prime_t last_prime, sieve_start, sieve_stop, sieve_size;
	prime_t i, last_index, next_index_return = next_index;
	
	if(next_index == 0){
		/* populate the first bunch of known primes */
		g_prime[0] = 2;
		g_prime[1] = 3;
		g_prime[2] = 5;
		g_prime[3] = 7;
		g_prime[4] = 11;
		g_prime[5] = 13;
		g_prime[6] = 17;
		g_prime[7] = 19;
		g_prime[8] = 23;	

		printf("INFO: sieve session starts: next_prime_index=%lld\n", next_index);
		return 9;
	}

	/* calcuate the sieve size and populate the sieve with nature numbers */
	last_index = next_index - 1;
	last_prime = g_prime[last_index];

	sieve_start = last_prime + 1;
	sieve_stop = last_prime * last_prime;
	sieve_size = sieve_stop - sieve_start + 1;

	
	if(sieve_size > MAX_SIEVE_SIZE){
		sieve_size = MAX_SIEVE_SIZE;
		sieve_stop = sieve_start + sieve_size - 1;
	}

	printf("INFO: sieve session starts: next_prime_index=%lld. ", next_index);
	printf("sieve_range: [%lld, %lld]; sieve_size:%lld\n", sieve_start, sieve_stop, sieve_size);
	for(i = 0; i < sieve_size; i ++)
		g_sieve[i] = sieve_start + i;

	/* sieve by all known primes...... */
	for(i = 0; i <= last_index; i ++){
		prime_t the_prime = g_prime[i], smallest, sieve_index;

		/* find the smallest multiple of "the_prime" in the sieve */
		smallest = sieve_start / the_prime * the_prime;
		if(smallest < sieve_start)
			smallest += the_prime;
		sieve_index = smallest - sieve_start;
		if(sieve_index >= MAX_SIEVE_SIZE)
			continue;
		
		/* printf("INFO: prime[%d]=%d. smallest=%d, sieve_index=%d\n", i, the_prime, smallest, sieve_index); */

		do{
			g_sieve[sieve_index] = 0;
			sieve_index += the_prime;
		}while(sieve_index < sieve_size);

	}

	/* collect primes remain in the sieve */
	for(i = 0; i < sieve_size; i ++){
		if(g_sieve[i] != 0){
			/* printf("INFO: found new prime: %d -> %d\n", next_index_return, g_sieve[i]); */
			g_prime[next_index_return] = g_sieve[i];
			next_index_return ++;
			if(next_index_return >= TOTAL_PRIME_NUMBER)
				break;
		}
	}

	return next_index_return;
}



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

#define LINE_COUNT  10   /* 10 prime each line */
int print_prime_db(prime_t prime_count)
{
	int i, line_index;

	for(i = 0, line_index = 0; i < prime_count; i ++){
		if(i % LINE_COUNT == 0){
			printf("\n%04d: ", line_index);
			line_index ++;
		}
		printf("%5lld ", g_prime[i]);
	}
	printf("\n");
	return 0;
}


int free_factor_list(factor_node* root)
{
	factor_node *tmp = root, *tmp2 = NULL;

	while(tmp){
		tmp2 = (factor_node*)(tmp->next);
		free(tmp);
		tmp = tmp2;
	}

	return 0;	
}


factor_node* factorize(prime_t num)
{
	prime_t i, quotient, up_bound, the_prime;
	factor_node* root = NULL, *last_node = NULL;

	/* printf("factorize(%d)...\n", num); */

	if(num < 2){
		return root; /* 0 and 1 is not considered */
	}

	quotient = num;
	up_bound = num; 
	for(i = 0; i < up_bound; i ++){
		int node_created = 0;
		if(i < TOTAL_PRIME_NUMBER){
		    the_prime = g_prime[i];
		}
		else{
			printf("the number of prime numbers is too small for factorizing %lld. quitting...\n", num);
			exit(1);
		}
#if (0)		
		printf("%dth prime=%d, quotient=%d, up_bound=%d.\n", i, the_prime, quotient, up_bound);
#endif
		while((quotient % the_prime) == 0){

			/* printf("factor found: %d\n", the_prime); */
			
			if(!node_created){ 
				
				/* create the node */
				factor_node* tmp = (factor_node*)malloc(sizeof(factor_node));
				if(!tmp){
					printf("ERROR: malloc() for node failed.\n");
					free_factor_list(root);
					root = NULL;
					return root;
				}
				tmp->prime_index = i;
				tmp->exponent = 0;
				tmp->next = NULL;
				node_created = 1;

				/* maintain the list struct */
				if(root == NULL){ 
					root = tmp;
				}
				else{
					last_node->next = (struct factor_node*)tmp;
				}
				last_node = tmp;
				
			}
			
			last_node->exponent ++;
			
			quotient /= the_prime;
#if (0)			
			printf("   quotient=%d.\n", quotient);
#endif
		}
		up_bound = quotient;
	}


#if (0)
	{
		/* print the factorized result */
		factor_node *tmp = root;
		printf("%d=", num);
		while(tmp){
			printf("%d(%d)^%d ", g_prime[tmp->prime_index], tmp->prime_index, tmp->exponent);
			tmp = tmp->next;
		}
		printf("\n");
	}
#endif

	return root;
}

/* added(bruin, 2006-07-24): return 0 means no gcd (i.e., infinity).
    a * x0 + b * y0 = gcd(a, b)
 */
prime_t get_gcd_2(int a, int b, int* x0, int* y0, int* steps)
{

	prime_t aa, bb, gcd, r, q; 
	int _steps, _x0, _y0, x_1, y_1, x_2, y_2; /* _x0 is x(n), x_1 is x(n-1), x_2 is x(n-2) */
	
	int swapped = 0; /* |a| < |b| ? */
	
	/* abs: make them all positive, since (a, b) = (|a|, |b|) */
	if(a < 0)
		aa = - a;
	else 
		aa = a;
	if(b < 0)
		bb = - b;
	else
		bb = b;

	/* swap: make sure aa >= bb */
	if(aa < bb){
		prime_t tmp = aa;
		aa = bb;
		bb = tmp;
		swapped = 1;
	}

	_steps = 0;
	
	/* handle trivial cases */
	if(aa == 0 && bb == 0){
		gcd = 0; 
		_x0 = _y0 = 0;
		goto RET;
	}

	if(aa == 0){
		gcd = bb; 
		_x0 = 0;
		_y0 = 1;
		goto RET;
	}

	if(bb == 0){
		gcd = aa; 
		_x0 = 1;
		_y0 = 0;
		goto RET;
	}

	/* main loop for normalized pair (aa, bb) */
	gcd = bb;
	_x0 = 0;
	_y0 = 1;
	while(r = aa % bb){
		
		q = aa / bb;
		
		/* steps:
		   0:     a=bq1+r1   => r1=a-bq1    => (x1,y1)=(1,     -q1) 
		   1:     b=r1q2+r2  => r2=b-r1q2   => (x2,y2)=(-q2x1, -q2y1) + ( 0,  1)
		   2:     r1=r2q3+r3 => r3=r1-r2q3  => (x3,y3)=(-q3x2, -q3y2) + (x1, y1)
		   3:     r2=r3q4+r4 => r4=r2-r3q4  => (x4,y4)=(-q4x3, -q4y3) + (x2, y2)
		   ...
		 */
		if(_steps == 0){
			_x0 = 1;
			_y0 = - q;
			
		}
		else if(_steps == 1){
			/* save the previous (x, y) */
			x_1 = _x0;
			y_1 = _y0;
			/* calcuate the new (x, y) */
			_x0 = - q * _x0;
			_y0 = - q * _y0 + 1;
		}
		else{
			/* save two previous (x, y) */
			x_2 = x_1;
			y_2 = y_1;
			x_1 = _x0;
			y_1 = _y0;
			/* calcuate the new (x, y) */
			_x0 = - q * _x0 + x_2;
			_y0 = - q * _y0 + y_2;
		}

		/* printf("\nstep=%2d, (%4d, %4d), r=%4d", *steps, aa, bb, r); */

		/* prepare for the next step */
		aa = bb;
		bb = r;
		gcd = r;

		_steps += 1;
	}


RET:
	
	/* handle the "swap" & "abs" cases for (x0, y0) */
	if(swapped){
		int tmp = _x0;
		_x0 = _y0;
		_y0 = tmp;
	}
	_x0 *= (a < 0)? - 1 : 1;
	_y0 *= (b < 0)? - 1 : 1;

	/* assign return values */	
	if(steps)
		*steps = _steps;
	if(x0)
		*x0 = _x0;
	if(y0)
		*y0 = _y0;

#if (0)
	/* verify the value */
	if((a * _x0 + b * _y0) != gcd){
		printf("ERROR: %d * %d + %d * %d != %d\n", a, _x0, b, _y0, gcd);
	}
	else{
		printf("OK: %d * %d + %d * %d = %d ", a, _x0, b, _y0, gcd);
	}
#endif

	/* printf(" ==> gcd(%d, %d)=%d\n", a, b, gcd); */
	
	return gcd;
}

/* added(bruin, 2006-07-25) */
prime_t get_gcd_n(int n, int a[])
{
	int i, gcd;
	
	if(n < 2){
		printf("ERROR: get_gcd_n(n=%d<2), return 0.\n", n);
		return 0;
	}

	gcd = get_gcd_2(a[0], a[1], NULL, NULL, NULL);
	
	for(i = 2; i < n; i ++){
		gcd = get_gcd_2(gcd, a[i], NULL, NULL, NULL);
	}

	return gcd;
}

