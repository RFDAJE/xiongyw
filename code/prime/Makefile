all:
	-indent -linux -l132 -nut -i4 prime.c
	-indent -linux -l132 -nut -i4 prime-smp.c
	gcc -g prime.c -lm -o prime
	gcc -g prime-smp.c -lm -lpthread -o sieve
clean:
	-rm prime smp
cleandb:
	-rm prime.db
