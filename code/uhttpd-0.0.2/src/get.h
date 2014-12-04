#ifndef __GET_H__
#define __GET_H__

int handle_get_request(int sd, const char *url,     /* input  */
						int host_index,             /* input */
						int *status_code,           /* output */
						long long int range_start,	/* input, inclusive; "-1" means ALL and range_end is ignored */
						long long int range_end,	/* input, inclusive */
						long long int *bytes_sent,            /* output, excluding http headers */
						int is_head);               /* input, 0 for "GET", others for HEAD request */


#endif /* __GET_H__ */
