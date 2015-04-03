/*
 * http://blog.csdn.net/absurd/article/details/1587938
 *
 * man 7 netlink
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/types.h>
#include <linux/netlink.h>
#include <errno.h>
#include <time.h>

#define UEVENT_BUFFER_SIZE      2048
static int init_uevt_sock(void);
static char* timestamp(void);

int main(int argc, char* argv[])
{
    char buf[UEVENT_BUFFER_SIZE*2] = {0};
    int uevt_sock = init_uevt_sock();
    int cnt = 0;

    while(1)
    {
        memset(buf, 0, UEVENT_BUFFER_SIZE*2);
        recv(uevt_sock, &buf, sizeof(buf), 0);
        cnt ++;
        printf("%d(%s): %s\n", cnt, timestamp(), buf);
    }

    return 0;
}

static int init_uevt_sock(void)
{
    struct sockaddr_nl snl;
    const int buffersize = 16 * 1024 * 1024;
    int retval;

    memset(&snl, 0x00, sizeof(struct sockaddr_nl));
    snl.nl_family = AF_NETLINK;
    snl.nl_pid = getpid();
    snl.nl_groups = 1;

    int uevt_sock = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_KOBJECT_UEVENT);
    if (uevt_sock == -1) {
        printf("error getting socket: %s", strerror(errno));
        return -1;
    }

    /* set receive buffersize */
    setsockopt(uevt_sock, SOL_SOCKET, SO_RCVBUFFORCE, &buffersize, sizeof(buffersize));

    retval = bind(uevt_sock, (struct sockaddr *) &snl, sizeof(struct sockaddr_nl));
    if (retval < 0) {
        printf("bind failed: %s", strerror(errno));
        close(uevt_sock);
        uevt_sock = -1;
        return -1;
    }

    return uevt_sock;
}

static char* timestamp(void)
{
    static char outstr[200];
    time_t t;
    struct tm *tmp;

    t = time(NULL);
    tmp = localtime(&t);
    if (tmp == NULL) {
	return NULL;
    }

    if (strftime(outstr, sizeof(outstr), "%H:%M:%S", tmp) == 0) {
	return NULL;
    }
    else {
        return outstr;
    }
}
