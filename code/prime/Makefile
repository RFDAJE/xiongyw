all:
	-indent -linux -l132 -nut -i4 prime.c
	-indent -linux -l132 -nut -i4 sieve.c
	gcc -Wall -g prime.c -lm -o prime
	gcc -Wall -g sieve.c -lm -lpthread -o sieve
clean:
	-rm prime smp
cleandb:
	-rm prime.db
