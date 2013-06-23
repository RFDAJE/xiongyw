all:
	gcc -Wall -g main.c sieve.c db.c gcd.c fact.c tests.c -lm -lpthread -o sieve
clean:
	-rm sieve
cleandb:
	-rm prime.db

indent:
	-indent -linux -l132 -nut -i4  main.c sieve.h sieve.c db.h db.c gcd.h gcd.c fact.h fact.c tests.h tests.c

