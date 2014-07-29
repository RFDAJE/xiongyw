
#ifndef __UTIL_H__
#define __UTIL_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#define MAX_REQUEST_SIZE     2048

#define HTTP_VERSION         "HTTP/1.1"
#define CRLF                 "\xd\xa"
#define RFC1123FMT           "%a, %d %b %Y %H:%M:%S GMT"



char* get_mime_type(const char* filename);
int   decode_hex_chars(char *url);
int   write_status_line(int sd, int status_code, const char* reason_phrase);
int   write_general_header(int sd);
int   write_response_header(int sd, const char* location);
int   write_entity_header(int sd, int content_size, const char* content_type);
void  log_session_clf(int fd, const char *client_ip, const char *request, int status_code, int bytes_sent);
void  itoa_k(char *buf, int buf_size, int num);


int   log_debug_msg(int priority, char *fmt, ...);


//#define DEBUG

/*
char *dsprintf(const char *fmt, ...);
*/
#endif /* __UTIL_H__ */
	



