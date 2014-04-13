#ifndef __GET_H__
#define __GET_H__

int handle_get_request(int sd, const char *url, int host_index, int *status_code, int *bytes_sent, int is_head);


#endif /* __GET_H__ */
