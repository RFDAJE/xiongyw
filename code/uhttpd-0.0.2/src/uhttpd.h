#ifndef __HTTPD_H__ 
#define __HTTPD_H__

#define LISTENPORT    80     /* we listen on this port by default */
#define MAXIDLE       10     /* max idle working threads in the pool */
#define MINIDLE       5      /* minmum idle working threads in the pool */
#define MAXSESSIONS   20

#define LOCKF         "/tmp/LOCK..http"
#define WORKDIR       "/tmp"


#define MAX_DOMAIN_NAME_SIZE     64
#define MAX_FILE_NAME_SIZE       128   /* size the file name and its suffix, if any */
#define MAX_PATH_NAME_SIZE       1024  /* size of the full path name of the file    */ 

typedef struct{
	char domain[MAX_DOMAIN_NAME_SIZE + 1];
	char root_dir[MAX_PATH_NAME_SIZE + 1];      
	char default_file[MAX_FILE_NAME_SIZE + 1];
	char log_file[MAX_PATH_NAME_SIZE + 1];
	int  log_fd;
}VHOST;


extern unsigned int g_nvhosts;  /* number of virtual hosts */
extern VHOST *g_vhosts;         /* array holds virtual hosts config */

#define DEBUG

#endif /* __HTTPD_H__ */
