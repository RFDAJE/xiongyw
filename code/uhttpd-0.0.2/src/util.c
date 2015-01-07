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
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <time.h>
#include <syslog.h>
#include <errno.h>

extern int errno;


#include "util.h"

/*
char *dsprintf(const char *fmt, ...){

#define INITCHUNK 128
#define CHUNK     256

    va_list v;
    int     l = strlen(fmt) + INITCHUNK, i;
    char    *r = malloc(l);

    while(r){
	va_start(v, fmt);
	i = vsnprintf(r, l, fmt, v);
	va_end(v);
	if(i < 0)
	    l += CHUNK;
	else if(i >= l)
	    i = l + 1;
	else
	    break;
	r = realloc(r, i);
    }
    return r;
}
*/
	
	
char* get_mime_type(const char* filename){

	char* dot;
	dot = strrchr(filename, '.');
	
/*
	if(!dot)
		return "application/octet-stream";
*/

	if(strcasecmp(dot, ".html") == 0 || 
           strcasecmp(dot, ".htm")  == 0)
		return "text/html";

	if(strcasecmp(dot, ".xml") == 0)
		return "text/xml";

	if(strcasecmp(dot, ".js") == 0)
		return "text/javascript";

	if(strcasecmp(dot, ".svg") == 0)
		return "text/svg";

	if(strcasecmp(dot, ".txt") == 0 || 
           strcasecmp(dot, ".c")   == 0 || 
           strcasecmp(dot, ".h")   == 0 ||
           strcasecmp(dot, ".cfg") == 0 ||
           strcasecmp(dot, ".el")  == 0 ||
	   strcasecmp(dot, ".cpp") == 0)
		return "text/plain";

	if(strcasecmp(dot, ".pdf") == 0 || 
           strcasecmp(dot, ".dat") == 0 || 
           strcasecmp(dot, ".exe") == 0 ||
           strcasecmp(dot, ".bin") == 0 ||
           strcasecmp(dot, ".swf") == 0 ||
           strcasecmp(dot, ".ppt") == 0 ||
           strcasecmp(dot, ".doc") == 0 ||
           strcasecmp(dot, ".rtf") == 0 ||
           strcasecmp(dot, ".zip") == 0 ||
           strcasecmp(dot, ".tgz") == 0 ||
	   strcasecmp(dot, ".tar") == 0)
		return "application/octet-stream";

	if(strcasecmp(dot, ".css") == 0)
		return "text/css";

	if(strcasecmp(dot, ".jpg")  == 0 || 
           strcasecmp(dot, ".jpeg") == 0)
		return "image/jpeg";

	if(strcasecmp(dot, ".gif") == 0)
		return "image/gif";

	if(strcasecmp(dot, ".png") == 0)
		return "image/png";

	if(strcasecmp(dot, ".ico") == 0)
		return "image/vnd.microsoft.icon";

	if(strcasecmp(dot, ".au") == 0)
		return "audio/basic";

	if(strcasecmp(dot, ".wav") == 0)
		return "audio/wav";

	if(strcasecmp(dot, ".mp3") == 0)
		return "audio/mpeg";

	if(strcasecmp(dot, ".mid")  == 0 || 
           strcasecmp(dot, ".midi") == 0)
		return "audio/midi";

	if(strcasecmp(dot, ".avi") == 0)
		return "video/x-msvideo";

	if(strcasecmp(dot, ".mp4") == 0)
		return "video/mp4";
         
	return "text/plain";
}

int write_status_line(int sd, int status_code, const char* reason_phrase){

	/* RFC 2616 section 6.1: status-line = HTTP-version SP status-code SP reason-phrase CRLF */

	int  msg_size;
	char status_line[1024];

	msg_size = snprintf(status_line, 1023, "%s %3d %s%s", HTTP_VERSION, status_code, reason_phrase, CRLF);
	write(sd, status_line, msg_size);
	return 0;
}

int write_general_header(int sd){

	/* RFC 2616 section 4.5:
		general-header = cache-control | connection | data | pragma | trailer | transfer-encoding | upgrade | via | warning
         */

	/* only write connection and date fields */
	time_t now;
	char timebuf[128];
	char buf[256];
	int  len;

	now = time(NULL);
	strftime(timebuf, sizeof(timebuf), RFC1123FMT, gmtime(&now));
	len = snprintf(buf, 255, "Connection: close\nDate: %s%s", timebuf, CRLF);
	write(sd, buf, len);
	
	return 0;
}
	
int write_response_header(int sd, const char* location){
	/* RFC 2616 section 6.2:
		response-header = accept-range | age | etag | location | proxy-authentication | retry-after | server | vary | www-authenticate
      */
      
	char buf[1024];
	int  len;
	len = snprintf(buf, 1023, "Accept-Ranges: bytes%s", CRLF);

        // CORS: allow all: http://www.w3.org/TR/cors/
        len += snprintf(buf + len, 1023 - len, "Access-Control-Allow-Origin: *%s", CRLF);

	if (location) {
		len += snprintf(buf + len, 1023 - len, "Location: %s%s", location, CRLF);
	}
	write(sd, buf, len);
	return 0;
}

int write_entity_header(int sd, long long int content_size, long long int start, long long int end, long long total_size, const char* content_type){
	/* RFC 2616 section 7.1:
		entity-header = allow | content-encoding | content-language | content-length | content-location | content-md5 | content-range | content-type | expires | last-modified | extension-header
         */
	
	char buf[256];
	int  len;
	if(content_size < 0)  // when content_size = 0, it's still meaningful/necessary to tell the client.
		len = snprintf(buf, 255, "Allow: GET%s", CRLF);
	else
		len = snprintf(buf, 255, "Content-Length: %lld\nContent-Range: bytes %lld-%lld/%lld\nContent-Type: %s%s", content_size, start, end, total_size, content_type, CRLF);

	write(sd, buf, len);
	
	return 0;
}

int decode_hex_chars(char *url){

	char *src,*dest;
        int val,val2;

        src = strchr(url,'%');

        if (src == NULL)
                return - 1;

        dest = src;

        while(*src != 0){
                if(*src == '%'){
                        src ++;
                        val = *src;

                        if (val > 'Z') val -= 0x20;
                        val = val - '0';
                        if (val<0) val = 0;
                        if (val>9) val -= 7;
                        if (val>15) val = 15;

                        src ++;

                        val2 = *src;

                        if (val2 > 'Z') val2 -= 0x20;
                        val2 = val2 - '0';
                        if (val2 < 0) val2 = 0;
                        if (val2 > 9) val2 -= 7;
                        if (val2 > 15) val2 = 15;

                        *dest = val * 16 + val2;
                }
		else 
			*dest = *src;
                dest ++;
                src ++;
        }
        *dest = 0;

	return 0;
}	



#ifdef DEBUG
int   log_debug_msg(int priority, char *fmt, ...){


	char buf[1024];

	va_list v;
	va_start(v, fmt);
	vsnprintf(buf, 1023, fmt, v);
	va_end(v);

	syslog(priority, buf);

	return 0;
}
#else
int log_debug_msg(int a,char* b,...){return 0;}
#endif

void itoa_k(char *buf, int buf_size, int num){

	int len;
	int i, ncomma;
	int index;

	len = snprintf(buf, buf_size, "%d", num);
	ncomma = (len - 1) / 3;

	printf("%s: len=%d, comma=%d\n", buf, len, ncomma);

	if((len + ncomma) >= buf_size)
		return;
	for(i = 0; i < ncomma; i ++){
		index = len - 3 * (i + 1);
		printf("i=%d, index=%d\n", i, index);
		memmove(buf + index + 1, buf + index, 3 * (i + 1) + i);
		buf[index] = ',';
	}
	buf[len + ncomma] = '\0';
	
}	
	

		

/* write the http log in Combined Log Format:

   %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"

   where

   %h: remote host
   %l: remote logname
   %u: remote user
   %t: time, standard english format
   %r: first line of request
   %s: status
   %b: bytes sent, excluding http headers
*/
void  log_session_clf(int fd, const char *client_ip, const char *request, int status_code, long long int bytes_sent){
	
#define REFERER             "Referer: "
#define USER_AGENT          "User-Agent: "

#define MAX_LINE_SIZE       4096

	char                buf[MAX_LINE_SIZE + 1];
	int                 len = 0;
	time_t              now;
	char                timebuf[128];
	char                *p1 = NULL, *p2 = NULL;

	
	/* %h %l %u */
	len = snprintf(buf, MAX_LINE_SIZE - len, "%s - - ", client_ip);

	/* %t */
	now = time(NULL);
	/* FIXME: %z is only available on GNU */
	strftime(timebuf, sizeof(timebuf), "%d/%m/%Y:%H:%M:%S %z", localtime(&now));
	len += snprintf(buf + len, MAX_LINE_SIZE - len, "[%s] ", timebuf);

	/* %r */
	p1 = strstr(request, CRLF);
	if(!p1)
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"\" ");
	else{
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"");
		memcpy(buf + len, request, p1 - request);
		len += p1 - request;
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "\" ");
	}

	/* %>s */	
	len += snprintf(buf + len, MAX_LINE_SIZE - len, "%3d ", status_code);

	/* %b */
	if(bytes_sent <= 0)
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "- ");
	else
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "%lld ", bytes_sent);
	
	/* \"%{Referer}i\" */
	p1 = strstr(request, REFERER);
	if(!p1){
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"-\" "); 
	}
	else{
		p1 += strlen(REFERER);
		p2 = strstr(p1, CRLF);	
		if(!p2)
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"-\" "); 
		else{
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"");
			memcpy(buf + len, p1, p2 - p1);
			len += p2 - p1;
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\" ");
		}
	}
			
	/* \"%{User-agent}i\" */
	p1 = strstr(request, USER_AGENT);
	if(!p1){
		len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"-\" "); 
	}
	else{
		p1 += strlen(USER_AGENT);
		p2 = strstr(p1, CRLF);	
		if(!p2)
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"-\" "); 
		else{
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\"");
			memcpy(buf + len, p1, p2 - p1);
			len += p2 - p1;
			len += snprintf(buf + len, MAX_LINE_SIZE - len, "\" ");
		}
	}

	buf[len] = '\n';
	len ++;

	len = write(fd, buf, len);
	if(len == -1)
		log_debug_msg(LOG_INFO, "log_session_clf: write() fail: %s", strerror(errno));
	
}

int socket_loop_write(int fd, void *buf,int len, int* written) { 
	
    int left = len; 
    char *ptr = buf; 
	*written = 0;

    while (left > 0) { 
        int _written = write(fd, ptr, left);
        if (_written <= 0) {
            if(errno == EINTR) {
                _written = 0; 
            } else {
                return (-1); 
            }
        }

        left -= _written; 
        ptr += _written;

		*written = len - left;
    } 

    return *written; 
} 

