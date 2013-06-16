all:
	-indent -linux -l132 -nut -i4 prime.c
	-indent -linux -l132 -nut -i4 main.c
	-indent -linux -l132 -nut -i4 sieve.h
	-indent -linux -l132 -nut -i4 sieve.c
	gcc -Wall -g prime.c -lm -o prime
	gcc -Wall -g main.c sieve.c -lm -lpthread -o sieve
clean:
	-rm prime smp
cleandb:
	-rm prime.db
