/*
** Copyright (C) 2004 Yuwu (Bruin) Xiong <xiongyw@hotmail.com>
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

#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <netinet/in.h>

#include "uhttpd.h"
#include "readconf.h"
#include "tcpserver.h"   
#include "response.h"


#define LOG_FACILITY    LOG_USER
#define LOG_PRIORITY    LOG_INFO

const char usage[] = "Usage: httpd [-c configfile]\n\n";
const char conf_file[] = "/etc/uhttpd.conf";

/* global variables */
unsigned int g_nvhosts = 0;
VHOST*       g_vhosts = NULL;

int post_daemonize(void);
int clean_up(void);

int main(int argc, char *argv[]){

	uint32_t inaddr;
	short   nport = LISTENPORT;  
	int	maxsessions = MAXSESSIONS;
	int     maxidle = MAXIDLE;
	int     minidle = MINIDLE;
	char    workdir[128];
	char    lockfile[128]; 

	/*** command line arguments dealing */
	switch(argc){
		case 1:
			read_config(conf_file, &inaddr, &nport, &maxsessions, &maxidle,
                                   &minidle, workdir, lockfile, &g_nvhosts, &g_vhosts);
			break;
			
		case 3:
			read_config(argv[2], &inaddr, &nport, &maxsessions, &maxidle,
                                   &minidle, workdir, lockfile, &g_nvhosts, &g_vhosts);
			break;
		default:
			fprintf(stderr, usage);
			exit(1);
	}
#ifdef DEBUG

	{
		int i;
		printf("number of vhosts:%d\n", g_nvhosts);
		for(i = 0; i < g_nvhosts; i ++)
			printf("%s %s %s %s\n", g_vhosts[i].domain, 
                                                g_vhosts[i].root_dir, 
                                                g_vhosts[i].default_file, 
                                                g_vhosts[i].log_file);
	}
#endif

	return server_run(inaddr,
                          nport, 
                          maxidle, 
                          minidle, 
                          maxsessions, 
                          argv[0], 
                          workdir,
                          lockfile,
			  LOG_FACILITY,
			  LOG_PRIORITY,
			  post_daemonize,
		          doresponse,
			  clean_up);

}

int post_daemonize(void){

	int i;
	for(i = 0; i < g_nvhosts; i ++){
		g_vhosts[i].log_fd = open(g_vhosts[i].log_file, O_WRONLY | O_CREAT | O_APPEND);
		if(g_vhosts[i].log_fd == -1){
			return 1;
		}

	}

	return 0;
}

int clean_up(void){
	int i;

	for(i = 0; i < g_nvhosts; i ++)
		close(g_vhosts[i].log_fd);

	if(g_vhosts)
		free(g_vhosts);

	return 0;
}
