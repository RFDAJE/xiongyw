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

	char url_cp[MAX_PATH_NAME_SIZE + 2];  /* local copy of the url */
	char fullpath[MAX_PATH_NAME_SIZE + 1]; 

	struct stat st;
	FILE* fp = NULL;
	unsigned char *pf = NULL;
	int   file_size = 0;

	log_debug_msg(LOG_INFO, "entering handle_get_request(), url=%s", url);
	*bytes_sent = 0;
	

	if(strlen(url) == 1 && url[0] == '/')
		snprintf(url_cp, MAX_PATH_NAME_SIZE, "/%s", g_vhosts[host_index].default_file);
	else
		snprintf(url_cp, MAX_PATH_NAME_SIZE, "%s", url);


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


/* modified(bruin, 2013-11-01): the html page for directories can be divided into 3 parts: 
   1. part1: <html><head><title>%s</title><style>...</style></head><body>...var table=
   2. part2: the 2-dimensiona array generated dynamically
   3. part3: the rest.

   convert html text into C string:
    -  s/\\/\\\\/g   : this is to replace \ to "\\"
    -  s/\"/\\\"/g   : this is to replace " to \"
    -  s/^/\"/g      : this is to add " at the begining of each line
    -  s/$/\\n\"/g   : this to to add \n" at the tail of each line

   batch convert: $cat test.html | sed -e 's@\\@\\\\@g' | sed -e 's@\"@\\\"@g' | sed -e 's@^@\"@g' | sed -e 's@$@\\n\"@g'
*/
static char s_part1[] =
#if (1)
"<html><head><title>%s</title>\n"
"<style>\n"
"\n"
"table {border-collapse:collapse;}\n"
"table tr:nth-child(odd)	 {background-color:#F2F2F2;}\n"
"table tr:nth-child(even) {background-color:#ffffff;}\n"
"table th{\n"
"	color:#ffffff;background-color:#555555;border:1px solid #555555;font-size:12px;padding:3px;vertical-align:top;text-align:left;\n"
"}\n"
"table td{\n"
"	border:1px solid #d4d4d4;padding:3px;padding-top:3px;padding-bottom:3px;vertical-align:top;\n"
"}\n"
"\n"
"table th a:link,table th a:visited {color:#ffffff;}\n"
"table th a:hover,table th a:active {color:#dddd33;}\n"
"\n"
"\n"
"/*\n"
" * noted(bruin, 2013-11-03): card-flipping animation\n"
" *\n"
" * ref: http://davidwalsh.name/css-flip\n"
" * \n"
"\n"
"1. the page elemens is arranged as below:\n"
"\n"
"<div id=\"flip-container\"\">\n"
"    <div id=\"flipper\">\n"
"	<div id=\"front\">\n"
"	    <!-- front content: descending tables divs -->\n"
"	</div>\n"
"	<div id=\"back\">\n"
"	    <!-- back content: ascending tables divs -->\n"
"	</div>\n"
"    </div>\n"
"</div>\n"
"\n"
"for all divs directly contains a table, one and only one of them is visible; the visibility\n"
"of them are controlled by their \"display\" property: \"none\" or \"block\".\n"
"\n"
"2. rotating of the \"flipper\" div is triggered by changing its class: \n"
"- class=\"\"     : show the front, i.e, no rotation\n"
"- class=\"edge\" : show the edge, i.e, rotate 90 degree. it's effectively invisible at this position.\n"
"- class=\"back\" : show the back, i.e., rotate 180 degree\n"
"\n"
"note that the 180 deg rotation is done in two steps, a 90 deg rotation followed by \n"
"another 90 deg. the reason is to obtain a right time to switch the table div to be shown.\n"
"below is the steps of the flipping process:\n"
"- add a hook to transitionEnd event\n"
"- trigger the 1st 90 deg rotation by changing flipper's class to \"edge\"\n"
"when the hook is called:\n"
"- remove the hook from the event\n"
"- switch the shown table div\n"
"- trigger the 2nd 90 deg rotation by changing flipper's class to either \"back\" or \"\".\n"
"\n"
"3. the width of the \"container\" div: the y-axis of the horizontal rotation needs to be \n"
"in the middle of the table width, to get the best rotation result. \n"
"to this end, we need to dynamiclly specify the correct \"width\" property of the \"container\" div.\n"
"if the div width is not set, then the y-axis is at the middle of the page body, which is not\n"
"what we wanted.\n"
"dynamically setting the div width is done at the begining of each flipping process, by checking the \n"
"width of the shown table and adding a small margin.\n"
"\n"
"*/\n"
"\n"
"/* DIVs which directly contain table are of \"table\" class, and are not displayed by default */\n"
"div.table {display: none;}\n"
"\n"
"/* the out-most container, which keeps perspective */\n"
"div#container {\n"
"	-webkit-perspective: 1000px;\n"
"           -moz-perspective: 1000px;\n"
"             -o-perspective: 1000px;\n"
"                perspective: 1000px;\n"
"}\n"
"\n"
"/* flip speed goes here */\n"
"div#flipper {\n"
"	-webkit-transition: 100ms;\n"
"	   -moz-transition: 100ms;\n"
"	     -o-transition: 100ms;\n"
"	        transition: 100ms;\n"
"   -webkit-transform-style: preserve-3d;\n"
"      -moz-transform-style: preserve-3d;\n"
"        -o-transform-style: preserve-3d;\n"
"           transform-style: preserve-3d;\n"
"}\n"
"\n"
"/* horizontally rotate 90 deg to show the edge (effectively invisible) */\n"
"div#flipper.edge{\n"
"	-webkit-transform: rotateY(90deg);\n"
"	   -moz-transform: rotateY(90deg);\n"
"	     -o-transform: rotateY(90deg);\n"
"	        transform: rotateY(90deg);\n"
"}\n"
"\n"
"/* horizontally rotate 180 deg to show the back */\n"
"div#flipper.back{\n"
"	-webkit-transform: rotateY(180deg);\n"
"	   -moz-transform: rotateY(180deg);\n"
"	     -o-transform: rotateY(180deg);\n"
"	        transform: rotateY(180deg);\n"
"}\n"
"\n"
"/* hide backface of both front and back panes */\n"
"div#front, div#back {\n"
"	-webkit-backface-visibility: hidden;\n"
"	   -moz-backface-visibility: hidden;\n"
"	     -o-backface-visibility: hidden;\n"
"	        backface-visibility: hidden;\n"
"}\n"
"\n"
"/* place the front pane above the back pane */\n"
"div#front {\n"
"	z-index: 2;\n"
"}\n"
"\n"
"/* the back pane is initially showing its back */\n"
"div#back {\n"
"	-webkit-transform: rotateY(180deg);\n"
"	   -moz-transform: rotateY(180deg);\n"
"	     -o-transform: rotateY(180deg);\n"
"	        transform: rotateY(180deg);\n"
"}\n"
"\n"
"\n"
"\n"
"</style></head><body> \n"
"<pre><b>Folder: %s</b><br>\n"
"\n"
"<script language='javascript'>\n"
"\n"
"\n"
"// a table in 2-dimensional array & its table header\n"
"var th = ['Type','Name','Size','Modified','href'];\n"
"var table = [\n";
#else
"<html><head><title>%s</title>\n"
"<style>\n"
"\n"
"table {border-collapse:collapse;}\n"
"table tr:nth-child(odd)	 {background-color:#F2F2F2;}\n"
"table tr:nth-child(even) {background-color:#ffffff;}\n"
"table th{\n"
"	color:#ffffff;background-color:#555555;border:1px solid #555555;font-size:12px;padding:3px;vertical-align:top;text-align:left;\n"
"}\n"
"table td{\n"
"	border:1px solid #d4d4d4;padding:3px;padding-top:3px;padding-bottom:3px;vertical-align:top;\n"
"}\n"
"\n"
"table th a:link,table th a:visited {color:#ffffff;}\n"
"table th a:hover,table th a:active {color:#dddd33;}\n"
"\n"
"div { display: none; }\n"
"\n"
"</style></head><body> \n"
"\n"
"<pre><b>Folder: %s</b><br>\n"
"\n"
"<script language='javascript'>\n"
"\n"
"// a table in 2-dimensional array & its table header\n"
"var th = ['Type','Name','Size','Modified','href'];\n"
"var table = [\n";
#endif




    
static char s_part3[] =
#if (0)
"];\n"
"\n"
"/**\n"
"* hide and show DIV elements\n"
"*\n"
"* @param {String} to_hide, the id of DIV to hide\n"
"* @param {String} to_show, the id of DIV to show\n"
"* @return none\n"
"*/\n"
"function hide_n_show(to_hide, to_show){\n"
"    document.getElementById(to_hide).style.display = \"none\";\n"
"    document.getElementById(to_show).style.display = \"block\";\n"
"}\n"
"\n"
"\n"
"/** \n"
"* return a compare function for sort()\n"
"*\n"
"* @param {Number} col: the index of the column to sort by\n"
"* @param {Boolean} ascending: ascending (true) or descending (false)\n"
"* @return {Function} The compare function for Array.prototype.sort()\n"
"*/\n"
"function sort_by_col(col, ascending){\n"
"    return function (a,b){\n"
"        var ord = 0;\n"
"        if(a[col] > b[col]) ord = ascending? 1 : - 1;\n"
"        if(a[col] < b[col]) ord = ascending? - 1 : 1;\n"
"        return ord;\n"
"    }\n"
"}\n"
"\n"
"/**\n"
"* convert a number into string seperated by commas\n"
"*\n"
"* @param {Number} size: the size\n"
"* @return {String} a converted string\n"
"*/\n"
"function size_with_comma(size){\n"
"    if(size < 0) return \"-\"\n"
"    var s = \"\" + size;\n"
"    var result = \"\"\n"
"    var mod = s.length % 3;\n"
"    var n = parseInt((s.length - 1) / 3);\n"
"    if(mod == 0) mod = 3\n"
"    if(mod) result += s.substring(0, mod);\n"
"    for(var i = 0; i < n; i ++){\n"
"	result += \",\" + s.substring(mod + i * 3, mod + i * 3 + 3);\n"
"    }\n"
"    return result;\n"
"}\n"
"\n"
"\n"
"/**\n"
"* return a html table row <tr> for the header\n"
"*\n"
"* @param {Number} col: the index of the column by which the table is sorted\n"
"* @param {Boolean} ascending: ascending (true) or descending (false)\n"
"* @return {String} string to be added to the document\n"
"*/\n"
"function gen_table_header(col, asc){\n"
"    var cur_div = \"d_\" + th[col] + (asc? \"_a\" : \"_d\");\n"
"    /**\n"
"    * @param {Number} column: the index of the table column\n"
"    * @return {String}: a <th> in the <tr>\n"
"    */\n"
"    var header = function(column){\n"
"        return \"<th><a href='javascript: hide_n_show(\\\"\" + \n"
"               cur_div + \"\\\", \\\"d_\" + th[column] +\"_\" + (((col === column) && asc)? \n"
"               \"d\\\"\" : \"a\\\"\") + \")'>\" + th[column] +\"</a>&nbsp;\" + \n"
"               ((col === column)?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"    }\n"
"\n"
"    return \"<tr>\" + [0,1,2,3].map(header).join(\" \") + \"</tr>\";\n"
"}\n"
"\n"
"/**\n"
"* return a content row in html\n"
"*\n"
"* @param {Array} x: an entry in the table array\n"
"* @return {String} the string to be written to the document\n"
"*/\n"
"function gen_a_table_row(x){\n"
"    var d = (x[0] === 'd');  // put text for directories <bold>, and keep type empty for files, size as '-'\n"
"    return \"<tr>\" + \n"
"           \"<td>\" + (d? x[0] : \"\") + \"</td>\" + \n"
"           \"<td>\" + (d? \"<b>\":\"\") + \"<a href='\" + x[4] + \"'>\" + x[1] + \"</a>\" + (d? \"</b>\":\"\") + \"</td>\" +\n"
"           \"<td align=right>\" + (d? \"-\": size_with_comma(x[2])) + \"</td>\" +  \n"
"           \"<td>\" + x[3] + \"</td>\" +\n"
"           \"</tr>\";\n"
"}\n"
"\n"
"\n"
"table = table.filter(function(x){return x[1] != '.'}).map(function(x){if(x[0] === 'd') x[1] = '/' + x[1]; return x});\n"
"\n"
"/*\n"
"* sort() keeps the '/..' folder at the top\n"
"*\n"
"*@param {Function} cmp: a compare function required by sort()\n"
"*@return {Array} the array is sorted in place\n"
"*/\n"
"table.sort = function (cmp){\n"
"\n"
"     var dotdot =  this.filter(function(x){return x[1] === '/..';});\n"
"     var rest = this.filter(function(x){return x[1] != '/..';}).sort(cmp);\n"
"\n"
"     this.length = 0; // empty the array\n"
"\n"
"     if(dotdot.length != 0){   \n"
"         this.push(dotdot[0]); \n"
"     }\n"
"\n"
"     for(var i = 0; i < rest.length; i ++){\n"
"         this.push(rest[i]);\n"
"     }\n"
"\n"
"     return this;\n"
"}\n"
"\n"
"\n"
"/** \n"
"* generate a div to be written to the document\n"
"* \n"
"* @param {Number} column: the index of the column by which the table is sorted\n"
"* @param {Boolean} is_asc: ascending (true) or descending (false)\n"
"* @param {String} id: the DIV element id\n"
"* @return {String} the div content\n"
"*/\n"
"function gen_a_div(column, is_asc, id){\n"
"    var div = \"\";\n"
"    table.sort(sort_by_col(column, is_asc));\n"
"//    div = div + \"<div id='\"+ id +\"' style='display:none'><table>\";\n"
"    div = div + \"<div id='\"+ id + \"'><table>\";\n"
"    div = div + gen_table_header(column, is_asc);\n"
"    div = div + table.map(gen_a_table_row).join(\" \");\n"
"    div = div + \"</table></div>\";\n"
"    return div;\n"
"}\n"
"\n"
"\n"
"// fold on the columns, each column produces two divs (ascending and descending)\n"
"document.write([0, 1, 2, 3].reduce(function(acc, col){ return acc + gen_a_div(col, true, 'd_' + th[col] + '_a') + gen_a_div(col, false, 'd_' + th[col] + '_d');}, \"\")); \n"
"\n"
"// show first DIV by default\n"
"document.getElementById(\"d_\" + th[0] + \"_d\").style.display = \"block\";\n"
"\n"
"</script>\n"
"<br><hr>\n"
"<address>Powered by <a href='http://tstool.sourceforge.net/drops/uhttpd-%s.tar.gz'>uhttpd v%s</a>, &copy;&nbsp;2002-2004&nbsp;<a href='mailto:xiongyw@hotmail.com'>Yuwu (Bruin) Xiong</a></address>\n"
"</body>\n"
"</html>\n";
#else
"];\n"
"\n"
"\n"
"/**\n"
" * hide and show DIV elements: this effectively trigger the flipping process\n"
" *\n"
" * @param {String} to_hide, the id of DIV to hide\n"
" * @param {String} to_show, the id of DIV to show\n"
" * @return none\n"
" */\n"
"function hide_n_show(to_hide, to_show){\n"
"\n"
"    // define hook inside so it has access to arguments \"to_hide\" and \"to_show\"\n"
"    var hook = function(){\n"
"        document.getElementById(\"flipper\").removeEventListener('webkitTransitionEnd', hook, false);\n"
"        document.getElementById(to_show).style.display = \"block\";\n"
"        document.getElementById(to_hide).style.display = \"none\";\n"
"        if(to_show.indexOf(\"asc\") > 0)\n"
"            document.getElementById(\"flipper\").className = \"back\";\n"
"        else\n"
"            document.getElementById(\"flipper\").className = \"\";\n"
"    }\n"
"\n"
"    // to dynamically set a good width for the out-most container DIV\n"
"    var table_width = window.getComputedStyle(document.getElementById(\"t\"+to_hide), null).getPropertyCSSValue('width').getFloatValue(CSSPrimitiveValue.CSS_NUMBER) + 10;\n"
"    document.getElementById(\"container\").style.width = table_width + \"px\";\n"
"\n"
"    document.getElementById(\"flipper\").addEventListener('webkitTransitionEnd', hook, false);\n"
"    // let it go...\n"
"    document.getElementById(\"flipper\").className = \"edge\";\n"
"}\n"
"\n"
"\n"
"/** \n"
" * return a compare function for sort()\n"
" *\n"
" * @param {Number} col: the index of the column to sort by\n"
" * @param {Boolean} ascending: ascending (true) or descending (false)\n"
" * @return {Function} The compare function for Array.prototype.sort()\n"
" */\n"
"function sort_by_col(col, ascending){\n"
"    return function (a,b){\n"
"        var ord = 0;\n"
"        if(a[col] > b[col]) ord = ascending? 1 : - 1;\n"
"        if(a[col] < b[col]) ord = ascending? - 1 : 1;\n"
"        return ord;\n"
"    }\n"
"}\n"
"\n"
"/**\n"
" * convert a number into string seperated by commas\n"
" *\n"
" * @param {Number} size: the size\n"
" * @return {String} a converted string\n"
" */\n"
"function size_with_comma(size){\n"
"    if(size < 0) return \"-\"\n"
"    var s = \"\" + size;\n"
"    var result = \"\"\n"
"    var mod = s.length % 3;\n"
"    var n = parseInt((s.length - 1) / 3);\n"
"    if(mod == 0) mod = 3\n"
"    if(mod) result += s.substring(0, mod);\n"
"    for(var i = 0; i < n; i ++){\n"
"	result += \",\" + s.substring(mod + i * 3, mod + i * 3 + 3);\n"
"    }\n"
"    return result;\n"
"}\n"
"\n"
"/* id rules for tables and their parent divs */\n"
"function div_id(col, asc){\n"
"    return th[col] + (asc? \"_asc\" : \"_dsc\");\n"
"}\n"
"\n"
"function table_id(col, asc){\n"
"    return \"t\" + div_id(col, asc);\n"
"}\n"
"\n"
"\n"
"/**\n"
" * return a html table row <tr> for the header\n"
" *\n"
" * @param {Number} col: the index of the column by which the table is sorted\n"
" * @param {Boolean} ascending: ascending (true) or descending (false)\n"
" * @return {String} string to be added to the document\n"
" */\n"
"function gen_table_header(col, asc){\n"
"    /**\n"
"     * @param {Number} column: the index of the table column\n"
"     * @return {String}: a <th> in the <tr>\n"
"     */\n"
"    var header = function(column){\n"
"        return \"<th><a href=\\\"javascript: hide_n_show('\" + \n"
"            div_id(col, asc) + \"', '\" + div_id(column, !asc) + \"')\\\">\" + th[column] +\"</a>&nbsp;\" + \n"
"            ((col === column)?(asc? \"&uarr;\" : \"&darr;\") : \"&nbsp;\") + \"</th>\";\n"
"    }\n"
"\n"
"    return \"<tr>\" + [0,1,2,3].map(header).join(\" \") + \"</tr>\";\n"
"}\n"
"\n"
"/**\n"
" * return a content row in html\n"
" *\n"
" * @param {Array} x: an entry in the table array\n"
" * @return {String} the string to be written to the document\n"
" */\n"
"function gen_a_table_row(x){\n"
"    // for directories: bold the text, prefix the name with \"/\", keep the \"Size\" field as '-'\n"
"    // for files: keep the \"Type\" field empty\n"
"    var d = (x[0] === 'd');  \n"
"\n"
"    return \"<tr>\" + \n"
"           \"<td>\" + (d? x[0] : \"\") + \"</td>\" + \n"
"           \"<td>\" + (d? \"<b>\":\"\") + \"<a href='\" + x[4] + \"'>\" + (d? \"/\" : \"\") + x[1] + \"</a>\" + (d? \"</b>\":\"\") + \"</td>\" +\n"
"           \"<td align=right>\" + (d? \"-\": size_with_comma(x[2])) + \"</td>\" +  \n"
"           \"<td>\" + x[3] + \"</td>\" +\n"
"           \"</tr>\";\n"
"}\n"
"\n"
"/** \n"
" * generate a div which encapsulates a table\n"
" * \n"
" * @param {Number} col: the index of the column by which the table is sorted\n"
" * @param {Boolean} asc: ascending (true) or descending (false)\n"
" * @return {String} the div content\n"
" */\n"
"function gen_a_div(col, asc){\n"
"    table.sort2(sort_by_col(col, asc));\n"
"    var div = \"<div class='table' id='\"+ div_id(col, asc) + \"'><table id='\" + table_id(col, asc) + \"'>\";\n"
"    div = div + gen_table_header(col, asc);\n"
"    div = div + table.map(gen_a_table_row).join(\" \");\n"
"    div = div + \"</table></div>\";\n"
"    return div;\n"
"}\n"
"\n"
"\n"
"/*\n"
" * sort2() is to always keep the '..' entry at the top\n"
" *\n"
" * @param {Function} cmp: a compare function required by sort2()\n"
" * @return {Array} the array is sorted in place\n"
" *\n"
" * noted(bruin, 2013-11-03): \n"
" * - it also works to add the sort() to the \"table\" object directly (thus masking the prototype's sort). \n"
" *   the drawback is that whenever we do \"table=table.filter()\", the new sort() is gone from the \"table\". \n"
" * - it will goes into a infinity recursive call if we override the Array.prototype.sort(), as in the case\n"
" *   here we still need to call original sort() to sort the \"rest\" array.\n"
" */\n"
"Array.prototype.sort2 = function (cmp){\n"
"\n"
"    var parent = '..';\n"
"    var dotdot = this.filter(function(x){return x[1] === parent;});\n"
"    var rest = this.filter(function(x){return x[1] != parent;}).sort(cmp);\n"
"\n"
"    this.length = 0; // empty the array\n"
"\n"
"    if(dotdot.length != 0){   \n"
"        this.push(dotdot[0]); \n"
"    }\n"
"\n"
"    for(var i = 0; i < rest.length; i ++){\n"
"        this.push(rest[i]);\n"
"    }\n"
"\n"
"    return this;\n"
"}\n"
"\n"
"\n"
"////////////////////////////////////////////////////////////\n"
"// table processing starts...\n"
"////////////////////////////////////////////////////////////\n"
"\n"
"// 1. filter out the '.' entry, if any\n"
"table = table.filter(function(x){return x[1] != '.'});\n"
"\n"
"// 2. generate and output the html content\n"
"var html = \"<div id='container'>\";\n"
"html += \"<div id='flipper'>\";\n"
"// front: put descending ordered tables\n"
"html += \"<div id='front'>\";\n"
"html += [0, 1, 2, 3].reduce(function(acc, col){return acc + gen_a_div(col, false);}, \"\"); \n"
"html += \"</div>\";\n"
"// back: put ascending ordered tables\n"
"html += \"<div id='back'>\";\n"
"html += [0, 1, 2, 3].reduce(function(acc, col){return acc + gen_a_div(col, true);}, \"\"); \n"
"html += \"</div>\";\n"
"html += \"</div>\";\n"
"\n"
"document.write(html);\n"
"\n"
"\n"
"// 3. show a div on the front pane, as the default table\n"
"document.getElementById(div_id(0, false)).style.display = \"block\";\n"
"\n"
"</script>\n"
"</div>\n"
"<br><hr>\n"
"<address>Powered by <a href='http://tstool.sourceforge.net/drops/uhttpd-0.0.2.tar.gz'>uhttpd v0.0.2</a>, &copy;&nbsp;2002-2004&nbsp;<a href='mailto:xiongyw@hotmail.com'>Yuwu (Bruin) Xiong</a></address>\n"
"</body>\n"
"</html>\n";
#endif

static int s_write_dir_page(int sd, char *p_dirpath,  const char *root_dir, int *status_code, int *bytes_sent){

#define INIT_CONTENT_SIZE       2048

#define FLAG_FIELD_SIZE         5
#define NAME_FIELD_SIZE         64
#define SIZE_FIELD_SIZE         16
#define TIME_FIELD_SIZE         36 
#define MAX_ENTRY_SIZE          (FLAG_FIELD_SIZE + NAME_FIELD_SIZE + SIZE_FIELD_SIZE + TIME_FIELD_SIZE + 1024)

#define MAX_HEAD_SIZE           8192
#define MAX_TAIL_SIZE           8192


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

	/* part 1 */
	head_size = snprintf(head, MAX_HEAD_SIZE, s_part1, p_dirpath + strlen(root_dir), p_dirpath + strlen(root_dir));
	log_debug_msg(LOG_INFO, "head_size=%d>%s", head_size, head);
		
        /* part 2 */
	content = malloc(INIT_CONTENT_SIZE);
	if(!content){
		log_debug_msg(LOG_INFO, "malloc(INIT_CONTENT_SIZE) fail");
		return - 1;
	}
	content_buf_size = INIT_CONTENT_SIZE;

        /*
        content_size = snprintf(content, INIT_CONTENT_SIZE, "</head><body style=\"background-color:#f0f0f0\"<b>Folder: %s"
                "</b><br><br>\n<script language='javascript'>\nvar i;\n// two dimensional array\n"
                "var ENTRIES = [\n",  p_dirpath + strlen(root_dir));
        */
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

		/* output format: [type, name, size, time] */
		strftime(timebuf, sizeof(timebuf), "%Y-%m-%d %H:%M", localtime(&st.st_mtime));
		
		entry_len = snprintf(entry, MAX_ENTRY_SIZE, "['%s', '%s', %d, '%s', '%s%s'],\n",
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
        //	content_size -= 2;  /* delete the comma (and the \n) after the last entry */

	/* part 3 */
	tail_size = snprintf(tail, MAX_TAIL_SIZE, s_part3, VERSION, VERSION);
	log_debug_msg(LOG_INFO, "tail_size=%d>%s", tail_size, tail);
	
	*status_code = 200;
	write_status_line(sd, *status_code, "");
	write_general_header(sd);
	write_response_header(sd, NULL);
	write_entity_header(sd, head_size + content_size +  tail_size, "text/html");

	/* entity-body: the html page(head + content + tail) */
	write(sd, CRLF, 2);
	*bytes_sent = 0;
	*bytes_sent += write(sd, head, head_size);
	log_debug_msg(LOG_INFO, "part 1 done");
	*bytes_sent += write(sd, content, content_size);
	log_debug_msg(LOG_INFO, "part2 done");
	*bytes_sent += write(sd, tail, tail_size);
	log_debug_msg(LOG_INFO, "part3 done");

	free(content);
	/*closedir(dp);	*/
		
	return 0;
}

