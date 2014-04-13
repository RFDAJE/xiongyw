#ifndef __TCPSERVER_H__ 
#define __TCPSERVER_H__

#include <netinet/in.h>

/*

overview
--------

the routing "server_run(..) was designed to serve as a multi-threading 
daemon under unix for tcp connections by using pthread, and implement
the dynamic thread preallocation feature. 

as the thumb of rule for multi-threading programming, using this daemon
requires the thread procedure does not use static or global variables
among threads. if really needed, use thread_specific_data(TSD) instead.

behavoir description
--------------------

the thread preallocation behavior was controlled by three parameters 
passed to it:

unsigned int maxsessions: max # of total working thread
unsigned int maxidle:     max # of idle working thread
unsigned int minidle:     min # of idle working thread

"maxsessions" is the max number of the totoal concurrent working threads
(idle threads plus busy threads). if this number been reached, the daemon
will not spawn new threads to "accept()" incoming tcp connections queued
in the kernel, if any; otherwise, "maxidle" and "minidle" are two number 
to control the maximum and minimum thread pool size as follows:

the daemon will first spawn "maxidle" working threads in the pool and get
ready to serve incoming connections.  each time a new connection arrives, 
one idle thread in the pool will handle the request, thus the pool size 
decreases by one each time. if the pool size decrease to "minidle", and
the number of total threads are less than "maxsessions", the daemon will 
create new threads to increase the pool size to "maxidle" again. 

when each busy thread finishes the request, it either be idle again, or 
suicide. it depends on the current idle thread number. ie, if the current 
idle number less than "maxidle", it will be idle again; otherwise, it just
suicides. put it another way, it's the main thread's duty to create working
threads, it does not kill/terminate working theads. this is up to each 
working thread itself to decide whether or not to suicide.


implementation brief
--------------------

number of idle threads and number of totol thread are stored in two global
variables accessible(read/write) by all threads(main thread and working
threads):

static unsigned int s_ntotal;
static unsigned int s_nidle;

these numbers are altered/checked in the following conditions:

1. the main thread create a new working thread in the pool:

   when startup or sem_wait() returns:

   if(s_ntotal < maxsessions && s_nidle < maxidle){
	create_new_working_threads;
        s_ntotal increase;
        s_nidle increase; 
   }

2. a idle working thread returned from "accept()", gets busy:
   
   s_nidle --;
   if(s_nidle < minidle){
	tell_main_thread_to_create_new_working_treads_by_"sem_post()"
   }

3. a busy thread finished it's work, gets idle again:
   s_nidle ++;
   if(s_nidle >= maxidle){
        the_thread_suicides
        s_nidle --;
        s_ntotal --;
   }


other two global variables server to do coordination betw. threads:

static sem_t  s_sem;
static pthread_mutex_t s_mlock;

the semophore is used for any working thread to tell the main thread
there are no enough idle threads in the pool, thus the main thread knows
it's time to spawn new threads;

the mutex is a lock betw each idle threads in the pool for "accept()" call. 
each idle thread must first get the mutex lock, then it can call "accept()",
thus at any time, there is only one thread has the chance to call and
wait at "accept()", this avoids the "thundering herd" problem.
*/

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
                int 	 	 (*clean_up)(void));       /* cleaning proc need to call before exit */ 


#endif 
