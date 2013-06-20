all:
	-indent -linux -l132 -nut -i4  main.c sieve.h sieve.c db.h db.c
	gcc -Wall -g main.c sieve.c db.c -lm -lpthread -o sieve
clean:
	-rm sieve
cleandb:
	-rm prime.db
