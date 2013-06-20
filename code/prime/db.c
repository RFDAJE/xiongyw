#define _GNU_SOURCE             /* for O_NOATIME in open() */
#define _LARGEFILE64_SOURCE     /* for lseek64() */
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "db.h"

#define DB_DEBUG

/*##############################################################
  # debug definition
  #############################################################*/

#ifdef DB_DEBUG
#define STMT(stuff)   do { stuff } while (0)
#define DB_debug(a) STMT(                             \
        printf("[%s(%04d)] ", __FILE__[0] == '/'?   \
        ((strrchr(__FILE__,'/')==NULL)?__FILE__:(strrchr(__FILE__,'/')+1)):   \
        ((strrchr(__FILE__,'\\')==NULL)?__FILE__:(strrchr(__FILE__,'\\')+1)), \
             __LINE__);                                     \
    printf a;)
#else
#define DB_debug(a)
#endif

/*##############################################################
  # other defines
  #############################################################*/

#define PRIME_DB_FILE_NAME "prime.db"

/*##############################################################
  # static variables definition
  #############################################################*/
static prime_t *s_prime = NULL;

static int s_mmap = 0;          /* using mmap() for accessing prime db */
static prime_t s_max_size = 0;  /* the max size required at init time */

static prime_t s_db_size = 0;   /* the number of primes already in the db */

/*##############################################################
  # globle function implementation
  #############################################################*/

/*
 * max_size: max num of primes to be stored in db
 * is_mmap: using mmap for db implementation or not
 * current_size* [out]: the current db size
 * 
 * return the prime db array, NULL for error
 */
prime_t *db_init(prime_t max_size, prime_t * current_size, int is_mmap)
{

    prime_t next_prime_index = 0;
    FILE *fp = NULL;

    struct stat fstat;
    int fd = -1;                /* file descriptor of the prime db */
    prime_t file_size = 0;
    int db_exist = 0;

    DB_debug(("db_init(mmap=%d) entering...\n", is_mmap));

    if (s_prime) {
        DB_debug(("db is already inited. ignored.\n"));
        goto EXIT;
    }

    s_mmap = is_mmap;
    s_max_size = max_size;

    if (!s_mmap) {
        s_prime = (prime_t *) calloc(s_max_size, sizeof(prime_t));
        if (!s_prime) {
            DB_debug(("ERROR: can not malloc array to store %llu prime numbers. try enable is_mmap flag?\n", s_max_size));
            goto EXIT;
        }
        /*
         * try to read the db into ram first
         */
        fp = fopen(PRIME_DB_FILE_NAME, "r");
        if (fp == NULL) {
            DB_debug(("INFO: %s does not exist.\n", PRIME_DB_FILE_NAME));
        } else {
            if (1 != fread(&s_db_size, sizeof(prime_t), 1, fp)) {
                DB_debug(("ERROR: can not read prime count in %s\n", PRIME_DB_FILE_NAME));
                s_db_size = 0;
                next_prime_index = 0;
            } else {

                DB_debug(("INFO: %llu of prime numbers are stored in '%s'. reading %llu of them...\n", s_db_size,
                          PRIME_DB_FILE_NAME, s_max_size < s_db_size ? s_max_size : s_db_size));
                if (s_db_size > s_max_size)
                    s_db_size = s_max_size;

                if (s_db_size != fread(s_prime, sizeof(prime_t), s_db_size, fp)) {
                    DB_debug(("ERROR: reading db file '%s' failed. ignore the db content.", PRIME_DB_FILE_NAME));
                    s_db_size = 0;
                    next_prime_index = 0;
                } else {
                    next_prime_index = s_db_size;
                }
            }
            fclose(fp);
        }
    } else {

        file_size = (1 + s_max_size) * sizeof(prime_t);
        DB_debug(("required file_size=%llu. max mmap() length: (size_t)(-1)=%lu\n", file_size, (size_t) (-1)));
        if (file_size > (size_t) (-1)) {
            DB_debug(("the file size is larger than 2^%lu bytes, which is the maximum size can be mmap()ed. giving up...\n",
                      sizeof(size_t) * 8));
            goto EXIT;
        }

        /* get the file stat */
        if (-1 == stat(PRIME_DB_FILE_NAME, &fstat)) {
            DB_debug(("stat(%s) failed, errno=%d, assuming file does not exist.\n", PRIME_DB_FILE_NAME, errno));
            db_exist = 0;
        } else {
            db_exist = 1;
        }
        DB_debug(("db_exist=%d, st_size=%ld\n", db_exist, fstat.st_size));

        /* get the file descriptor */
        if ((fd = open(PRIME_DB_FILE_NAME, O_CREAT | O_RDWR | O_NOATIME, 00666)) == -1) {
            DB_debug(("open(%s,...) failed. errno=%d, abort.\n", PRIME_DB_FILE_NAME, errno));
            goto EXIT;
        }

        /* make sure the file grows to desired size before mmap() */
        if (!db_exist || file_size > fstat.st_size) {
            if (-1 == lseek64(fd, file_size - 1, SEEK_SET)) {
                DB_debug(("lseek64(%llu) failed. abort\n", file_size));
                goto EXIT;
            }
            write(fd, "", 1);
        }

        /* mmap the whole file */
        s_prime = (prime_t *) mmap(NULL, file_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (s_prime == MAP_FAILED) {
            DB_debug(("mmap(...,%s,...) failed, errno=%d, abort.\n", PRIME_DB_FILE_NAME, errno));
            goto EXIT;
        }
        //DB_debug(("s_prime=%p\n", (void *)s_prime));

        if (db_exist) {
            s_db_size = s_prime[0];
            DB_debug(("s_db_size=%llu\n", s_db_size));
            next_prime_index = s_max_size < s_db_size ? s_max_size : s_db_size;
        } else {
            s_db_size = 0;
            next_prime_index = 0;
        }
        s_prime += 1;           /* skip the header: number of the primes in the db */
    }

 EXIT:

    if (fd != -1)
        close(fd);

    *current_size = s_db_size;
    return s_prime;
}

/*
 * db_size: the number of primes should be stored in db
 *
 * return 0 for success, otherwise failure
 */
int db_fini(prime_t db_size)
{
    DB_debug(("db_fini() enters...\n"));

    if (!s_prime) {
        DB_debug(("db is not inited. ignored...\n"));
        return 1;
    }

    if (!s_mmap) {
        /* save in db only if we are requested to save more */
        if (db_size > s_db_size) {
            FILE *fp;

            fp = fopen(PRIME_DB_FILE_NAME, "wb");
            if (fp == NULL) {
                DB_debug(("ERROR: can not open file %s for writting...\n", PRIME_DB_FILE_NAME));
                return -1;
            } else {
                DB_debug(("INFO: saving %llu primes into db file %s...\n", db_size, PRIME_DB_FILE_NAME));
                fwrite(&db_size, sizeof(prime_t), 1, fp);
                fwrite(s_prime, sizeof(prime_t), db_size, fp);
                fclose(fp);
            }
        }
    } else {
        if (db_size > s_db_size)
            *(s_prime - 1) = db_size;
        munmap((void *)(s_prime - 1), sizeof(prime_t) * (db_size + 1));
    }

    s_prime = NULL;

    return 0;
}
