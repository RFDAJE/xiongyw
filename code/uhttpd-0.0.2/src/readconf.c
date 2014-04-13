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
#include <string.h>
#include <netinet/in.h>
#include <netdb.h>

#include "uhttpd.h"
#include "readconf.h"


void read_config(const char *conf_file, 
	 	 uint32_t *inaddr,
                 short *nport, 
                 unsigned int *maxsessions, 
                 unsigned int *maxidle, 
                 unsigned int *minidle, 
                 char *workdir, 
                 char *lockfile,
                 unsigned int *nvhosts,
		 VHOST    **vhosts){


	FILE *fp;
	char line[1024];
	char buf[1024];
	char ip_or_domain[256];

	int  ip_ok = 0;
	int  port_ok = 0;
	int  maxidle_ok = 0;
	int  minidle_ok = 0;
	int  maxsessions_ok = 0;
	int  workdir_ok = 0; 
	int  lockfile_ok = 0; 
	int  vhost_ok = 0;

	*nvhosts = 0;
	*vhosts = NULL;

	if(!(fp = fopen(conf_file, "rt"))){
		fprintf(stderr, "can not find configuration file: %s\n", conf_file);
		exit(1);
	}

	while(fgets(line, 1023, fp)){
		if(line[0] == '#' || line[0] == ' ' || line[0] == '\t' || line[0] == '\n' || line[0] == '\r')
			continue; 	

		if(strncmp(line, "listen_ip", 9) == 0){
			struct hostent* ent;
			sscanf(line, "%s %s", buf, ip_or_domain);
			if(strncmp(ip_or_domain, "0", 1) == 0){
				*inaddr = htonl(INADDR_ANY);
				ip_ok = 1;
				continue;
			}
			if(!(ent = (struct hostent*)gethostbyname(ip_or_domain))){
				fprintf(stderr, "ip or domain name error: %s.\n", ip_or_domain);
				exit(1);
			}
			*inaddr = *((uint32_t*)(ent->h_addr));
			ip_ok = 1;
		}
		if(strncmp(line, "listen_port", 11) == 0){
			sscanf(line, "%s %hd", buf, nport);
			port_ok = 1;
		}
		else if(strncmp(line, "max_idle", 8) == 0){
			sscanf(line, "%s %d", buf, maxidle);
			maxidle_ok = 1;
		}
		else if(strncmp(line, "min_idle", 8) == 0){
			sscanf(line, "%s %d", buf, minidle);
			minidle_ok = 1;
		}
		else if(strncmp(line, "max_sessions", 12) == 0){
			sscanf(line, "%s %d", buf, maxsessions);
			maxsessions_ok = 1;
		}
		else if(strncmp(line, "work_dir", 8) == 0){
			sscanf(line, "%s %s", buf, workdir);
			workdir_ok = 1;
		}
		else if(strncmp(line, "lock_file", 9) == 0){
			sscanf(line, "%s %s", buf, lockfile);
			lockfile_ok = 1;
		}
		else if(strncmp(line, "vhost", 5) == 0){
			*nvhosts += 1;
			*vhosts = (VHOST*)realloc(*vhosts, (*nvhosts) * sizeof(VHOST));	
			sscanf(line, "%s %s %s %s %s", buf, 
				(*vhosts)[*nvhosts - 1].domain,
				(*vhosts)[*nvhosts - 1].root_dir,
				(*vhosts)[*nvhosts - 1].default_file,
				(*vhosts)[*nvhosts - 1].log_file);
			
			(*vhosts)[*nvhosts - 1].domain[MAX_DOMAIN_NAME_SIZE] = '\0';
			(*vhosts)[*nvhosts - 1].root_dir[MAX_PATH_NAME_SIZE] = '\0';
			(*vhosts)[*nvhosts - 1].default_file[MAX_FILE_NAME_SIZE] = '\0';
			(*vhosts)[*nvhosts - 1].log_file[MAX_PATH_NAME_SIZE] = '\0';

			/* make sure the rootdir does not end with slash / */
			if((*vhosts)[*nvhosts - 1].root_dir[strlen((*vhosts)[*nvhosts - 1].root_dir) - 1] == '/')
				(*vhosts)[*nvhosts - 1].root_dir[strlen((*vhosts)[*nvhosts - 1].root_dir) - 1] = '\0';

			vhost_ok = 1;
		}
#if(0)
		else if(strncmp(line, "root_dir", 8) == 0){
			sscanf(line, "%s %s", buf, rootdir);
			/* make sure the rootdir does not end with slash / */
			if(rootdir[strlen(rootdir) - 1] == '/')
				rootdir[strlen(rootdir) - 1] = '\0';
			rootdir_ok = 1;
		}
		else if(strncmp(line, "default_file", 12) == 0){
			sscanf(line, "%s %s", buf, defaultfile);
			defaultfile_ok = 1;
		}
		else if(strncmp(line, "log_file", 8) == 0){
			sscanf(line, "%s %s", buf, logfile);
			logfile_ok = 1;
		}
#endif
	}
	
	if(!ip_ok){
		fprintf(stderr, "missing ip address in the configuration file.\n");
		exit(1);
	}
	if(!port_ok){
		fprintf(stderr, "missing port number in the configuration file.\n");
		exit(1);
	}
        if(!maxidle_ok){
		fprintf(stderr, "missing maxidle in the configuration file.\n");
		exit(1);
	}
	if(!minidle_ok){
		fprintf(stderr, "missing minidle in the configuration file.\n");
		exit(1);
	}
        if(!maxsessions_ok){
		fprintf(stderr, "missing maxsessions in the configuration file.\n");
		exit(1);
	}
        if(!workdir_ok){
		fprintf(stderr, "missing workdir in the configuration file.\n");
		exit(1);
	}
        if(!lockfile_ok){
		fprintf(stderr, "missing lock file in the configuration file.\n");
		exit(1);
	}
	if(!vhost_ok){
		fprintf(stderr, "missing virtual host entry in the configuration file.\n");
		exit(1);
	}

	fclose(fp);
}
