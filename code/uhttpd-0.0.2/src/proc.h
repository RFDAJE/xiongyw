#ifndef __PROC_H__ 
#define __PROC_H__

#define TMP_PROC_ROOT "/tmp/proc/"

/*
 * writing some dynamic info of each thread into TMP_PROC_ROOT
 */

int tmp_proc_add(char* path, /* relative path to TMP_PROC_ROOT */
                 char* mode, /* "d" for directory, "f" for file */
                     char* content); /* if mode=="f", this is the ascii content of the file */

int tmp_proc_rm(char* path); /* relative path to TMP_PROC_ROOT */

#endif 
