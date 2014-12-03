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


#include <unistd.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <syslog.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <dirent.h>

#include "uhttpd.h"
#include "util.h"
#include "get.h"

static const char s_allow[] = "Allow: GET, HEAD";          /* methods supported */

/*** return:     0: normal termination
             other: errno each condition */
int  doresponse(int sd){

	char        client_ip[16];
	struct sockaddr_in  cliaddr;   
	socklen_t           clilen = sizeof(cliaddr);
	char        request[MAX_REQUEST_SIZE + 1];
	uint16_t    req_size;   /* request packet size */
	char        url[MAX_PATH_NAME_SIZE + 1];
	char        host[MAX_DOMAIN_NAME_SIZE + 7]; /* count ":port_number" */
	int         index;
	char        *p1, *p2;

	int         status_code;
	long long int    bytes_sent = 0;

	int         ret = 0;


	index = - 1;

	/* get client ip address */
	getpeername(sd, (struct sockaddr *)&cliaddr, &clilen);	
	snprintf(client_ip, 15, "%s", inet_ntoa(cliaddr.sin_addr));

	
	req_size = read(sd, request, MAX_REQUEST_SIZE);
	if(req_size <= 0){
		ret = -1;
		goto done;
	}

	/* limit the request size */
	if(req_size == MAX_REQUEST_SIZE){
		status_code = 400;
		log_debug_msg(LOG_INFO, "request too long.");
		write_status_line(sd, status_code, "Bad Request: request too long");
		write(sd, CRLF, 2);
		goto done;
	}
	request[req_size] = '\0';

	log_debug_msg(LOG_INFO, "request size=%d>%s", req_size, request);

	/* parse the request */
	if(strncmp(request, "GET", 3) == 0 || strncmp(request, "HEAD", 4) == 0){


		/* determing the url requested */
		if(!(p1 = strchr(request, '/')) || !(p2 = strchr(p1, ' ')) || (p2 - p1) > MAX_PATH_NAME_SIZE){
			status_code = 400;
			write_status_line(sd, status_code, "Bad Request: bad url");
			write(sd, CRLF, 2);
			goto done;
		}
		memcpy(url, p1, p2 - p1);
		url[p2 - p1] = '\0';
		
		/* determine the "Host:" in the request */
		if(!(p1 = strstr(request, "Host: ")) || !(p2 = strstr(p1 + 6, CRLF)) || (p2 - p1 - 6) > sizeof(host)){
			status_code = 400;
			write_status_line(sd, status_code, "Bad Request: bad host");
			write(sd, CRLF, 2);
			goto done;
		}
		p1 += 6;
		memcpy(host, p1, p2 - p1);
		host[p2 - p1] = '\0';
		for(index = 0; index < g_nvhosts; index ++){
			if(strncasecmp(host, g_vhosts[index].domain, strlen(g_vhosts[index].domain)) == 0)
				break;
		}
		if(index == g_nvhosts){
			index = - 1;
			status_code = 400;
			write_status_line(sd, status_code, "Bad Request: host not supported");
			write(sd, CRLF, 2);
			goto done;
		}

		handle_get_request(sd, url, index, &status_code, &bytes_sent, strncmp(request, "GET", 3));
	}
	else{ /* OPTIONS | POST | PUT | DELETE | TRACE | CONNECT */
		status_code = 405;
		log_debug_msg(LOG_INFO, "unsupported request");
		write_status_line(sd, status_code, s_allow);
		write_general_header(sd);
		write_response_header(sd, NULL);
		write_entity_header(sd, 0, NULL);
		write(sd, CRLF, 2);
	}

done:
	close(sd);

	if(index == - 1)
		return ret;
	
	/* log the session in Combinded Log Format */
	log_session_clf(g_vhosts[index].log_fd, client_ip, request, status_code, bytes_sent);

	return ret;
}
