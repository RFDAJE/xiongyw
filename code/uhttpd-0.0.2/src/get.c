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
#include <sys/mman.h>
#include <sys/stat.h>
#include <syslog.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <dirent.h>

#include "uhttpd.h"
#include "util.h"
#include "get.h"

#ifndef HAVE_SCANDIR
/* This function is only required for SunOS, all other supported OS
   have this function in their system library */

int scandir(const char *dir, struct dirent ***namelist,
            int (*select)(const struct dirent *),
            int (*compar)(const struct dirent **, const struct dirent **))
{
  DIR *d;
  struct dirent *entry;
  register int i=0;
  size_t entrysize;

  if ((d=opendir(dir)) == NULL)
     return(-1);

  *namelist=NULL;
  while ((entry=readdir(d)) != NULL)
  {
    if (select == NULL || (select != NULL && (*select)(entry)))
    {
      *namelist=(struct dirent **)realloc((void *)(*namelist),
                 (size_t)((i+1)*sizeof(struct dirent *)));
	if (*namelist == NULL) return(-1);
	entrysize=sizeof(struct dirent)-sizeof(entry->d_name)+strlen(entry->d_name)+1;
	(*namelist)[i]=(struct dirent *)malloc(entrysize);
	if ((*namelist)[i] == NULL) return(-1);
	memcpy((*namelist)[i], entry, entrysize);
	i++;
    }
  }
  if (closedir(d)) return(-1);
  if (i == 0) return(-1);
  if (compar != NULL)
    qsort((void *)(*namelist), (size_t)i, sizeof(struct dirent *), compar);
    
  return(i);
}
#endif


#ifndef HAVE_ALPHASORT

int alphasort(const struct dirent **a, const struct dirent **b)
{
  return(strcmp((*a)->d_name, (*b)->d_name));
}

#endif


static int s_write_dir_page(int sd, char *p_dirpath,  const char *root_dir, int *status_code, int *bytes_sent);
	
	
/* "url" is the original url sent from the client */
int handle_get_request(int sd, const char *url,     /* input  */
						int host_index,             /* input */
						int *status_code,           /* output */
						int *bytes_sent,            /* output, excluding http headers */
						int is_head){               /* input, 0 for "GET", others for HEAD request */

	char url_cp[MAX_FILE_NAME_SIZE + 2];  /* local copy of the url */
	char fullpath[MAX_PATH_NAME_SIZE + 1]; 

	struct stat st;
	FILE* fp = NULL;
	unsigned char *pf = NULL;
	int   file_size = 0;

	log_debug_msg(LOG_INFO, "entering handle_get_request(), url=%s", url);
	*bytes_sent = 0;
	

	if(strlen(url) == 1 && url[0] == '/')
		snprintf(url_cp, MAX_FILE_NAME_SIZE, "/%s", g_vhosts[host_index].default_file);
	else
		snprintf(url_cp, MAX_FILE_NAME_SIZE, "%s", url);


	log_debug_msg(LOG_INFO, "url after copy and default check=%s", url_cp);

	/* decode %  hex characters in the url */
	decode_hex_chars(url_cp);

	log_debug_msg(LOG_INFO, "url after decode=%s", url_cp);

	/* forbidden dir climbing */
	if(strstr(url_cp, "/..") || strstr(url_cp, "../") || strstr(url_cp, "/../")){
		log_debug_msg(LOG_INFO, "bad request: dir climbing");
		*status_code = 400;
		write_status_line(sd, *status_code, "Bad Request");
		write(sd, CRLF, 2);
		return 0;
	}
			
	/* get the full path name */
	snprintf(fullpath, MAX_PATH_NAME_SIZE, "%s%s", g_vhosts[host_index].root_dir, url_cp);
	log_debug_msg(LOG_INFO, "fullpath size=%d:%s", strlen(fullpath), fullpath);


	/* get file status */
	if(stat(fullpath, &st) < 0){
		*status_code = 404;
		write_status_line(sd, *status_code, "Not Found");
		write(sd, CRLF" ", 3);
		return 0;
	}

	/* check if is a dir */
	if(S_ISDIR(st.st_mode)){
		if(is_head){
			*status_code = 404;
			write_status_line(sd, *status_code, "Not Found");
			write_general_header(sd);
			write(sd, CRLF, 2);
			return 0;
		}

		if(fullpath[strlen(fullpath) - 1] != '/'){
			strcat(url_cp, "/");
			*status_code = 302;
			write_status_line(sd, *status_code, "Found");
			write_general_header(sd);
			write_response_header(sd, url_cp); 
			write(sd, CRLF, 2);
			return 0;
		}


		/* list the directory */
		s_write_dir_page(sd, fullpath, g_vhosts[host_index].root_dir, status_code, bytes_sent);
		return 0;
	}
			
	file_size = st.st_size;

	if(is_head){
		*status_code = 200;
		write_status_line(sd, *status_code, "");
		write_general_header(sd);
		write_response_header(sd, NULL);
		write_entity_header(sd, file_size, get_mime_type(fullpath));
		write(sd, CRLF, 2);
		return 0;
	}

	log_debug_msg(LOG_INFO, "a get request");

	/* open the requested file */
	fp = fopen(fullpath, "r");
	if(!fp){
		log_debug_msg(LOG_INFO, "fopen(%s, \"r\") fail.", fullpath);
		*status_code = 404;
		write_status_line(sd, *status_code, "Not Found");
		write(sd, CRLF, 2);
		return 0;
	}
			
	log_debug_msg(LOG_INFO, "file opened");
	if(file_size > 0){
		/* mmap it */
		pf = (unsigned char*)mmap(0, file_size, PROT_READ, MAP_PRIVATE, fileno(fp), 0);
		if(!pf){
			log_debug_msg(LOG_INFO, "mmap fail");
			*status_code = 500;
			write_status_line(sd, *status_code, "server internal error");
			write(sd, CRLF, 2);
			return 0;
		}
	}

	
	log_debug_msg(LOG_INFO, "ready to write responose");
	/* everything is ready, response to the request */
	*status_code = 200;
	write_status_line(sd, *status_code, "");
	log_debug_msg(LOG_INFO, "status line done");
	write_general_header(sd);
	log_debug_msg(LOG_INFO, "general header done");
	write_response_header(sd, NULL);
	log_debug_msg(LOG_INFO, "response header done");
	write_entity_header(sd, file_size, get_mime_type(fullpath));
	log_debug_msg(LOG_INFO, "entity header done");

	/* entity-body */
	write(sd, CRLF, 2);
	log_debug_msg(LOG_INFO, "CRLF done");
	*bytes_sent = write(sd, pf, file_size);
	log_debug_msg(LOG_INFO, "entity done");

	if(pf)
		munmap(pf, file_size);	
	if(fp)
		fclose(fp);

	return 0;
}


/* added(bruin, 2004-07-14): the dir html can be divided into 5 parts, 3 are dynamic content, 2 are 
   static javascript (s_js1[] and s_js2[]):
    1. (dynamic): <html><head><title>Folder: /directory/name</title>
	2. (static): s_js1[]
	3. (dynamic): directory entries as 2 dimensional array in javascript
	4. (static): s_js2[]
	5. (dynamc): uhttpd version info, author info, and </body></html>

   the following is the two static js code fragment. generate this string from plain java script by 
   the following sequence:
    -  s/\\/\\\\/g
    -  s/\"/\\\"/g
    -  s/^/\"/g
    -  s/$/\\n\"/g 
*/
static char s_js1[] =
"<script launguage=\"javascript\">\n"
"function get_element(id){\n"
"	return document.all? document.all[id] : document.getElementById(id);\n"
"}\n"
"function hide_n_show(to_hide, to_show){\n"
"	get_element(to_hide).style.display = \"none\";\n"
"	get_element(to_show).style.display = \"block\";\n"
"}\n"
"\n"
"function sort_by_column(col){\n"
"	return function (a,b){\n"
" 		  var x = a[col];\n"
"		  var y = b[col];\n"
"		  return ((x < y) ? - 1 : ((x > y) ? 1 : 0));\n"
"	        }\n"
"}\n"
"\n"
"function size_with_comma(size){\n"
"	if(size < 0) return \"-\"\n"
"	var s = \"\" + size;\n"
"	var result = \"\"\n"
"	var mod = s.length % 3;\n"
"	var n = parseInt((s.length - 1) / 3);\n"
"	if(mod == 0) mod = 3\n"
"	if(mod) result += s.substring(0, mod);\n"
"	for(var i = 0; i < n; i ++){\n"
"		result += \",\" + s.substring(mod + i * 3, mod + i * 3 + 3);\n"
"	}\n"
"	return result;\n"
"}\n"
"\n"
"// col: column name, one of \"type\"/\"name\"/\"size\"/\"time\"\n"
"// asc: true/false, ascending? \n"
"function render_table_header(col, asc){\n"
"	var cur_div = \"d_\" + col + (asc? \"_a\" : \"_d\");\n"
"	var docW = \"\";\n"
"	docW += \"<tr>\";\n"
"	docW += \"<th><a href='javascript: hide_n_show(\\\"\" + cur_div + \"\\\", \\\"d_type_\" + (((col == \"type\") && asc)? \"d\\\"\" : \"a\\\"\") + \")'>Type</a>&nbsp;\" + ((col == \"type\")?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"	docW += \"<th><a href='javascript: hide_n_show(\\\"\" + cur_div + \"\\\", \\\"d_name_\" + (((col == \"name\") && asc)? \"d\\\"\" : \"a\\\"\") + \")'>Name</a>&nbsp;\" + ((col == \"name\")?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"	docW += \"<th><a href='javascript: hide_n_show(\\\"\" + cur_div + \"\\\", \\\"d_size_\" + (((col == \"size\") && asc)? \"d\\\"\" : \"a\\\"\") + \")'>Size</a>&nbsp;\" + ((col == \"size\")?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"	docW += \"<th><a href='javascript: hide_n_show(\\\"\" + cur_div + \"\\\", \\\"d_time_\" + (((col == \"time\") && asc)? \"d\\\"\" : \"a\\\"\") + \")'>Modified</a>&nbsp;\" + ((col == \"time\")?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"	return docW;\n"
"}\n"
"\n"
"function render_table_row(i){\n"
"	if(ENTRIES[i].type === 'd')  // bold directories\n"
"		return \"<tr><td>\" + ENTRIES[i].type + \"</td><td><b><a href='\" + ENTRIES[i].href + \"'>\" + ENTRIES[i].name + \"</a></b></td><td align=right>\" + size_with_comma(ENTRIES[i].size) + \"</td><td>\" + ENTRIES[i].time + \"</td>\";\n"
"	else\n"
"		return \"<tr><td>\" + ENTRIES[i].type + \"</td><td>   <a href='\" + ENTRIES[i].href + \"'>\" + ENTRIES[i].name + \"</a>    </td><td align=right>\" + size_with_comma(ENTRIES[i].size) + \"</td><td>\" + ENTRIES[i].time + \"</td>\";\n"
"}\n"
"\n"
"</script>\n";




/* 
"</head><body tyle=\"background-color:#f0f0f0\"<b>Folder: /gist/images/</b><br><br>\n"
"<script language='javascript'>\n"
"\n"
"var i;\n"
"\n"
"// two dimensional array\n";
*/





static char s_js2[] = 
"];\n"
"\n"
"\n"
"// remove the '.' directory, if exist\n"
"for(i = 0; i < ENTRIES.length; i ++){\n"
"	if(ENTRIES[i].name === '.'){\n"
"		ENTRIES.splice(i, 1);\n"
"		break;\n"
"	}\n"
"}\n"
"\n"
"// prefix '/' before directores\n"
"for(i = 0; i < ENTRIES.length; i ++){\n"
"	if(ENTRIES[i].type === 'd'){\n"
"		ENTRIES[i].name = '/' + ENTRIES[i].name;\n"
"	}\n"
"}\n"
"\n"
"////////////////////////////////////////////////////////////////////////\n"
"ENTRIES.sort(sort_by_column(\"type\"));\n"
"document.write(\"<div id='d_type_a' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"type\", true));\n"
"for(i = 0; i < ENTRIES.length; i ++) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"document.write(\"<div id='d_type_d' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"type\", false));\n"
"for(i = ENTRIES.length - 1; i >= 0; i --) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"\n"
"////////////////////////////////////////////////////////////////////////\n"
"ENTRIES.sort(sort_by_column(\"name\"));\n"
"document.write(\"<div id='d_name_a' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"name\", true));\n"
"for(i = 0; i < ENTRIES.length; i ++) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"document.write(\"<div id='d_name_d' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"name\", false));\n"
"for(i = ENTRIES.length - 1; i >= 0; i --) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"\n"
"////////////////////////////////////////////////////////////////////////\n"
"ENTRIES.sort(sort_by_column(\"size\"));\n"
"document.write(\"<div id='d_size_a' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"size\", true));\n"
"for(i = 0; i < ENTRIES.length; i ++) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"document.write(\"<div id='d_size_d' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"size\", false));\n"
"for(i = ENTRIES.length - 1; i >= 0; i --) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"\n"
"////////////////////////////////////////////////////////////////////////\n"
"ENTRIES.sort(sort_by_column(\"time\"));\n"
"document.write(\"<div id='d_time_a' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"time\", true));\n"
"for(i = 0; i < ENTRIES.length; i ++) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"document.write(\"<div id='d_time_d' style='display:none'><table border=1 cellpadding=2 cellspacing=0>\");\n"
"document.write(render_table_header(\"time\", false));\n"
"for(i = ENTRIES.length - 1; i >= 0; i --) document.write(render_table_row(i));\n"
"document.write(\"</table></div>\");\n"
"\n"
"// show one div \n"
"get_element(\"d_type_d\").style.display = \"block\";\n"
"\n"
"</script>\n";



static int s_write_dir_page(int sd, char *p_dirpath,  const char *root_dir, int *status_code, int *bytes_sent){

#define INIT_CONTENT_SIZE       2048

#define FLAG_FIELD_SIZE         5
#define NAME_FIELD_SIZE         64
#define SIZE_FIELD_SIZE         16
#define TIME_FIELD_SIZE         36 
#define MAX_ENTRY_SIZE          (FLAG_FIELD_SIZE + NAME_FIELD_SIZE + SIZE_FIELD_SIZE + TIME_FIELD_SIZE + 1024)

#define MAX_HEAD_SIZE           2048
#define MAX_TAIL_SIZE           2048


	struct dirent **list;
	int    i, n;
	struct stat   st;

	char          head[MAX_HEAD_SIZE + 1], *content = NULL, tail[MAX_TAIL_SIZE + 1]; 
	int           head_size, content_size, tail_size, content_buf_size;
	char          entry[MAX_ENTRY_SIZE + 1];
	int           entry_len;
	char          timebuf[128];
	char          fullpath[MAX_PATH_NAME_SIZE + 1];

	*bytes_sent = 0;

	log_debug_msg(LOG_INFO, "%s to be lsed", p_dirpath);
/*
	if(!(dp = opendir(p_dirpath))){
		*status_code = 500;
		write_status_line(sd, *status_code, "server internal error");
		write(sd, CRLF, 2);
		return 0;
	}
	log_debug_msg(LOG_INFO, "%s opendir()ed", p_dirpath);
*/

	n = scandir(p_dirpath, &list, 0, alphasort);
	if(n < 0){
		*status_code = 500;
		write_status_line(sd, *status_code, "server internal error");
		write(sd, CRLF, 2);
		return 0;
	}

	head_size = 0;
	content_size = 0;
	tail_size = 0;

	/* html header */
	head_size = snprintf(head, MAX_HEAD_SIZE, "<html><head><title>Folder: %s</title>\n", 
                       p_dirpath + strlen(root_dir));
	log_debug_msg(LOG_INFO, "head_size=%d>%s", head_size, head);
		

	content = malloc(INIT_CONTENT_SIZE);
	if(!content){
		log_debug_msg(LOG_INFO, "malloc(INIT_CONTENT_SIZE) fail");
		return - 1;
	}
	content_buf_size = INIT_CONTENT_SIZE;

  content_size = snprintf(content, INIT_CONTENT_SIZE, "</head><body tyle=\"background-color:#f0f0f0\"<b>Folder: %s"
                "</b><br><br>\n<script language='javascript'>\nvar i;\n// two dimensional array\n"
                "var ENTRIES = [\n",  p_dirpath + strlen(root_dir));

	for(i = 0; i < n; i ++){

		snprintf(fullpath, MAX_PATH_NAME_SIZE, "%s%s", p_dirpath, list[i]->d_name);
		log_debug_msg(LOG_INFO, "fullpath=%s", fullpath);
		if(stat(fullpath, &st)){
			*status_code = 500;
			log_debug_msg(LOG_INFO, "stat(%s) fail", fullpath);
			write_status_line(sd, *status_code, "server internal error");
			write(sd, CRLF, 2);
			return 0;
		}

		/* display format: type, name, size, time */
		strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M", localtime(&st.st_mtime));
		
		entry_len = snprintf(entry, MAX_ENTRY_SIZE, "{type: '%s', name: '%s', size: %d, time: '%s', href: '%s%s'},\n",
									S_ISDIR(st.st_mode)? "d" : "-",
									list[i]->d_name,
									S_ISDIR(st.st_mode)? - 1 : st.st_size,
									timebuf,
                                    p_dirpath + strlen(root_dir), list[i]->d_name); 

		log_debug_msg(LOG_INFO, "entry_len=%d>%s", entry_len, entry);

		if((content_buf_size - content_size) <= entry_len){
			content = realloc(content, content_buf_size + entry_len);
			if(!content){
				log_debug_msg(LOG_INFO, "realloc() fail");
				return - 1;
			}
			content_buf_size += entry_len;
		}
		memcpy(content + content_size, entry, entry_len);
		content_size += entry_len;
		log_debug_msg(LOG_INFO, "content_size=%d", content_size);

		free(list[i]);
	}
	free(list);
	content_size -= 2;  /* delete the comma (and the \n) after the last entry */

	/* html tail */
	tail_size = snprintf(tail, MAX_TAIL_SIZE, "<br><hr><address><small>Powered by <a href='http://tstool.sourceforge.net/drops/uhttpd-%s.tar.gz'>uhttpd v%s</a>, &copy;&nbsp;2002-2004&nbsp;<a href='mailto:xiongyw@hotmail.com'>Yuwu (Bruin) Xiong</a></small></address></body></html>", VERSION, VERSION);
	log_debug_msg(LOG_INFO, "tail_size=%d>%s", tail_size, tail);
	
	*status_code = 200;
	write_status_line(sd, *status_code, "");
	write_general_header(sd);
	write_response_header(sd, NULL);
	write_entity_header(sd, head_size + strlen(s_js1) + content_size + strlen(s_js2) + tail_size, "text/html");

	/* entity-body: the html page(head + content + tail) */
	write(sd, CRLF, 2);
	*bytes_sent = 0;
	*bytes_sent += write(sd, head, head_size);
	log_debug_msg(LOG_INFO, "html head done");
	*bytes_sent += write(sd, s_js1, strlen(s_js1));
	log_debug_msg(LOG_INFO, "js1 done");
	*bytes_sent += write(sd, content, content_size);
	log_debug_msg(LOG_INFO, "html content done");
	*bytes_sent += write(sd, s_js2, strlen(s_js2));
	log_debug_msg(LOG_INFO, "js2 done");
	*bytes_sent += write(sd, tail, tail_size);
	log_debug_msg(LOG_INFO, "html tail done");

	free(content);
	/*closedir(dp);	*/
		
	return 0;
}

