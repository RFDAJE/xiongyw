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


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include <semaphore.h>
#include <fcntl.h>
#include <syslog.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>

#include "tcpserver.h"   

#define BACKLOG       128      /* backlog for listen() */

static void  s_daemonize(const char *pname, const char *workdir, const char *lockfile);
static void  s_on_signal(int sig);   
static void* s_start_thread(int (*pfunc)(int sd)); 

/*** global variables */

extern int      errno;

static char     s_lockfile[128];  /* lockfile name */
static int      s_listensd;       /* listen socket descriptor */

static unsigned int s_maxsessions;    /* max connections */
static unsigned int s_maxidle = 0;    /* max number of idle working threads */
static unsigned int s_minidle = 0;    /* min number of idle working threads */

static unsigned int s_ntotal = 0;     /* total # of current working threads */
static unsigned int s_nidle  = 0;     /* # of current idle working threads */

static sem_t    s_sem;            /* tells there is no enough idle threads */ 
static pthread_mutex_t s_mlock = PTHREAD_MUTEX_INITIALIZER;
                                  /* mutex lock betw. threads for accept() */

static int      s_log_facility;
static int      s_log_priority;
static int      (*s_clean_up)(void);

int  server_run(uint32_t         inaddr,       /* ip address in network order */
                uint16_t         port,         /* port number of the listening socket */
                uint32_t         maxidle,      /* max number of idle working thread */
                unsigned int     minidle,      /* min number of idle working thread */
                unsigned int     maxsessions,  /* max connections */
                const char*      pname,        /* process name to be logged */
                const char*      workdir,      /* working dirctory */
                const char*      lockfile,     /* lock file full path name */
		int              log_facility, /* openlog(, , log_facility) */
		int              log_priority, /* syslog(log_priority, ...) */
		int              (*post_daemonize)(void),  /* extra work after daemonizing */
                int 	 	 (*thread_proc)(int sd),   /* thread proc */
                int 	 	 (*clean_up)(void)){       /* cleaning proc need to call before exit */ 


    struct sockaddr_in myaddr;  
    int                sockflag = 1;


    if(maxidle < minidle)
        maxidle = minidle;  
    if(maxsessions < minidle)
        maxsessions = minidle; 

    s_maxidle = maxidle;
    s_minidle = minidle;
    s_maxsessions = maxsessions;

	s_log_facility = log_facility;
	s_log_priority = log_priority;

	s_clean_up = clean_up;
    s_daemonize(pname, workdir, lockfile); 
    if(post_daemonize)
	(*post_daemonize)();

    sprintf(s_lockfile, "%s", lockfile);

    syslog(s_log_priority, "port=%d\n", port);
    syslog(s_log_priority, "maxsessions=%d\n", maxsessions);
    syslog(s_log_priority, "maxidle=%d\n", maxidle);
    syslog(s_log_priority, "minidle=%d\n", minidle);
    syslog(s_log_priority, "workdir=%s\n", workdir);
    syslog(s_log_priority, "lockfile=%s\n", lockfile);
    
    /*** listen on the s_listensd */
    s_listensd = socket(PF_INET, SOCK_STREAM, 0);
    if(s_listensd < 0){
        syslog(s_log_priority, "%s: socket() fail: %s", pname, strerror(errno));
        exit(1);
    }

    if(setsockopt(s_listensd, SOL_SOCKET, SO_REUSEADDR, &sockflag, sizeof(sockflag)) < 0){
        syslog(s_log_priority, "setsockopt(..., SO_REUSEADDR, ...) fail.");
        exit(1);
    }

    memset(&myaddr, 0, sizeof(myaddr));
    myaddr.sin_family = AF_INET;
    myaddr.sin_addr.s_addr = inaddr;
    myaddr.sin_port = htons(port);
    if(bind(s_listensd, (struct sockaddr*)&myaddr, sizeof(myaddr)) != 0){
        syslog(s_log_priority, "bind() fail: %s", strerror(errno));
        s_on_signal(0);
        exit(1);
    }   
    if(listen(s_listensd, BACKLOG) != 0){
        syslog(s_log_priority, "listen() fail: %s", strerror(errno));
        s_on_signal(0);
        exit(1);
    }   

    /*** initialize the semaphore, set inital value to 1 */
    if(sem_init(&s_sem, 0, 1) != 0){ 
        syslog(s_log_priority, "sem_init() fail: %s", strerror(errno));
        s_on_signal(0);
        exit(1);
    }   


    /*** the main thread only reponsible for creating new working
             threads when necessary, threads termination was done by
             working threads themselves by suicide when apply */

    for(;;){
        sem_wait(&s_sem);   /* block if s_sem = 0 */
#ifdef DEBUG
        syslog(s_log_priority, "sem_wait() returns. total=%d, idle=%d", s_ntotal, s_nidle);
#endif
    
        for(; s_nidle < s_maxidle && s_ntotal < s_maxsessions ;){
            pthread_t tid;  
            if(pthread_create(&tid, NULL, (void* (*)(void*))s_start_thread, thread_proc) != 0){
                syslog(s_log_priority, "pthread_create() fail: %s", strerror(errno));
		continue;
            }
            s_ntotal ++;
            s_nidle ++; 
        }
    }
}

/* prepair the process to be a daemon */
static void s_daemonize(const char *pname,  /* process name */
                      const char *workdir, /* working directory */
                      const char *lockfile /* lock file name */
 ){  

    int   i, fd;    
    pid_t pid;
    char  buf[10];
    struct flock lock;
        
    /*** fork() to create own process grp, and detaches from
           any controlling tty, and not be the process grp leader */    
    pid = fork();
    if(pid > 0)  /* parent got to die */
        exit(0);
    if(pid < 0){ /* error occured     */
        sprintf(buf, "%s: first fork() fail.\n", pname);
        perror(buf);
        exit(1);
    }   
    /* now is the first child process, which is not the 
           process group leader, so we can call setsid() */
    
    if(setsid() == - 1){
        sprintf(buf, "%s: setsid() fail.\n", pname);
        perror(buf);
        exit(1);
    }
    
    /* now the process is the leader of the session, the leader of its
           process grp, and have no controlling tty */

    signal(SIGHUP, SIG_IGN); /* ignore the SIGHUP, in case the session leader
                                    sending it when terminating.  */

    pid = fork();   /* fork again, don't be the process grp leader */
    if(pid > 0)  /* the first child process */
        exit(0);
    if(pid < 0){
        sprintf(buf, "%s: second fork() fail\n", pname);
        perror(buf);
        exit(1);
    }

    /* following is the grandchild process, which is not the grp leader,
           have no controlling tty ==> */

    /*** open syslog */ 
    openlog(pname, LOG_PID, s_log_facility);

    /*** install our signal handlers: TBD */ 
    signal(SIGPIPE, SIG_IGN);
    signal(SIGHUP,  s_on_signal);
        signal(SIGABRT, s_on_signal);
        signal(SIGINT,  s_on_signal);
        signal(SIGTERM, s_on_signal);
        signal(SIGALRM, s_on_signal);
        /*signal(SIGPIPE, s_on_signal);*/
        signal(SIGQUIT, s_on_signal); 

    /*** close all inherited file/socket descriptors */
    for(i = 0; i < getdtablesize(); i ++)
        close(i);

    /*** open stdin/stdout/stderr to /dev/null for other routines */
    fd = open("/dev/null", O_RDWR);
    if( fd != 0 ){  /* fd should be 0: stdin */
        syslog(s_log_priority, "%s: open /dev/null fail.", pname);
        exit(1);
    }
    if(dup(fd) != 1){ /* first dup should be 1: stdout */
        syslog(s_log_priority, "%s: first dup() fail.", pname);
        exit(1);
    }
    if(dup(fd) != 2){ /* first dup should be 2: stderr */
        syslog(s_log_priority, "%s: second dup() fail.", pname);
        exit(1);
    }

    /*** change root direcoty */
    if(chroot("/") != 0){
        syslog(s_log_priority, "%s: chroot(/) fail.", pname);
        /*exit(1);*/
    }

    /* change current working directory */
    switch(chdir(workdir)){ 
        case 0:       /* success */
            break;
#if(0)
        case ENOENT:  /* does not exist, create it, TBD */
            break;
#endif
        default:        
            syslog(s_log_priority, "%s: chdir(%s) fail.", pname, workdir);
            exit(1); 
    }

    /*** change umask */
    umask(0027);

    /*** prevent other instance from running simultaneously */
    fd = open(lockfile, O_RDWR | O_CREAT, 0640);
    if(fd < 0){   /* error occured */
        syslog(s_log_priority, "%s: open(%s...) fail.", pname, lockfile);
        exit(1);
    }

    lock.l_type = F_WRLCK;
    lock.l_start = 0;
    lock.l_whence = SEEK_SET;
    lock.l_len = 0; /* lock the whole file */
    
    if(fcntl(fd, F_SETLK, &lock) < 0){
        syslog(s_log_priority, "fcntl(.., F_SETLCK, ...) fail: another instant running, I quit.\n");
        exit(0);
    }

    /* write pid to the lock file */
    sprintf(buf, "%6d\n", (int)getpid());
    write(fd, buf, strlen(buf));
}

static void s_on_signal(int sig){

    syslog(s_log_priority, "signal %d cought", sig);

    /*** remove the lock file: TBD */
	if(s_lockfile[0])
    	unlink(s_lockfile); 

    /*** destroy the semaphore: TBD */
    sem_destroy(&s_sem);
    
   /*** terminate all working threads: TBD */

    close(s_listensd);

    if(s_clean_up)
	(*s_clean_up)();

    closelog();
    exit(sig);  
}

static void* s_start_thread(int (*pfunc)(int sd)){ 

    int                 clisd;    
    struct sockaddr_in  cliaddr;   
    socklen_t           clilen;
    int                 ret;

#ifdef DEBUG
    syslog(s_log_priority, "tid[%5d] starts. (%d:%d)", (int)pthread_self(), s_ntotal, s_nidle);  
#endif

    for(;;){    
        clilen = sizeof(cliaddr);

        pthread_mutex_lock(&s_mlock);
        clisd = accept(s_listensd, (struct sockaddr *)&cliaddr, &clilen);
        s_nidle --;    /* I am not idle from now on */
        pthread_mutex_unlock(&s_mlock);

#ifdef DEBUG
        syslog(s_log_priority, "tid[%5d] <- %s:%d [%d:%d]", (int)pthread_self(), inet_ntoa(cliaddr.sin_addr), cliaddr.sin_port, s_ntotal, s_nidle);  
#endif

        if(clisd < 0){
            syslog(s_log_priority, "thread %d accept() fail: %s", (int)pthread_self(), strerror(errno));
	    s_nidle ++;
            continue;  
        }

        /*** check if enough idle working threads exists */
        if(s_nidle < s_minidle && s_ntotal < s_maxsessions)
            sem_post(&s_sem);  /* tell the main thread to create more threads */
        
    
        /*** do the main job here */
	ret = (*pfunc)(clisd);

#ifdef DEBUG
        syslog(s_log_priority, "tid[%5d] -> %s:%d = %d <%d:%d>", (int)pthread_self(), inet_ntoa(cliaddr.sin_addr), cliaddr.sin_port, ret, s_ntotal, s_nidle + 1);
#endif
        

        /*** check if too many idle working threads, if, suicide */
        if(s_nidle + 1 > s_maxidle){
            s_ntotal --;

#ifdef   DEBUG
            syslog(s_log_priority, "thread[%5d] will suicide, total=%4d, idle=%3d", (int)pthread_self(), s_ntotal, s_nidle);
#endif

            pthread_exit(NULL);  /* all just return; ? */
        }
	else{
	    s_nidle ++;
	}
    } /* end for(;;) */
}
