/*
** Copyright (C) 2015 Yuwu (Bruin) Xiong <xiongyw@hotmail.com>
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software 
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "proc.h"   

#define CMD_SIZE (1024+1)

int tmp_proc_add(char* path, /* relative path to TMP_PROC_ROOT */
                 char* mode, /* "d" for directory, "f" for file */
                 char* content){ /* if mode=="f", this is the ascii content of the file */

    char cmd[CMD_SIZE];
    
    if (path == 0 || mode == 0) {
        return - 1;
    }

    if (mode[0] == 'd') {
        /* fixme: check return values */
        snprintf(cmd, CMD_SIZE, "mkdir -p %s%s", TMP_PROC_ROOT, path);
        system(cmd);
        return 0;
    } else if (mode[0] == 'f') {
        if (content != 0) {
            snprintf(cmd, CMD_SIZE, "echo %s > %s%s", content, TMP_PROC_ROOT, path);
            system(cmd);
            return 0;
        }
    }

    return -1;
}


int tmp_proc_rm(char* path){ /* relative path to TMP_PROC_ROOT */
    char cmd[CMD_SIZE];

    if (path != 0) {
        snprintf(cmd, CMD_SIZE, "rm -rf %s%s", TMP_PROC_ROOT, path);
        system(cmd);
        return 0;
    }
    return -1;
}

