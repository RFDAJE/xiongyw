#ifndef __READCONFIG_H__
#define __READCONFIG_H__


void read_config(const char *conf_file, 
		 uint32_t *inaddr,
                 short *nport, 
                 unsigned int *maxsessions, 
                 unsigned int *maxidle, 
                 unsigned int *minidle, 
                 char *workdir, 
                 char *lockfile,
                 unsigned int *nvhosts,
		 VHOST **vhosts);


#endif
