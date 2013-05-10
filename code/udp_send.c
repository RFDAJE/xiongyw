/* created(bruin, 2007-08-22): utiliy to send udp packets to STB for 
   benchmarking the ethernet driver through put.  

   compile by: "gcc udp_send.c -lm -o udp_send"   
*/

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <time.h>
#include <math.h>

/* IP address does not really matter since we are dealing with MAC layer.
 * we manully set an arp entry for the PC to map this IP to STB's MAC, then
 * arp on PC will figure out the MAC address from this IP */
#define STB_IP "192.168.3.9" 
#define PORT   8172 /* the port does not matter in our case */
#define TIME_FMT           "%H:%M:%S"
#define PRINT_COUNT  1000
#define SYNC_BYTE   0x48  /* first byte of the payload */

/* the time spend in sendto() API can be ignored compared to usleep(),
 * so we use this to adjust the sending speed */
#define PACKETS_PER_SECOND   2000
#define BUFLEN               1200


int main(void)
{
	struct sockaddr_in si_other;
	int s, i, slen=sizeof(si_other);
	unsigned char buf[BUFLEN];
	time_t start, now;
	char time_start[128], time_now[128];

	if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))==-1){
		fprintf(stderr, "socket() fail.\n");
		exit(1);
	}


	memset((char *) &si_other, sizeof(si_other), 0);
	si_other.sin_family = AF_INET;
	si_other.sin_port = htons(PORT);
	if (inet_aton(STB_IP, &si_other.sin_addr)==0) {
		fprintf(stderr, "inet_aton() failed\n");
		exit(1);
	}

	printf("UDP sending speed: Packets/s: %d; Bytes/s: %d; Bits/s: %d\n", PACKETS_PER_SECOND, PACKETS_PER_SECOND * BUFLEN, PACKETS_PER_SECOND * BUFLEN * 8);

	start = time(NULL);
	strftime(time_start, sizeof(time_start), TIME_FMT, gmtime(&start));

	buf[0] = SYNC_BYTE;
	for (i=0; ; i++) {
		buf[1] = buf[BUFLEN - 1] = i % 256;
		if (sendto(s, buf, BUFLEN, 0, &si_other, slen)==-1){
			fprintf(stderr, "sendto() failed at %d\n", i);
			exit(1);
		}
		if(0 == i % PRINT_COUNT){
			now = time(NULL);
			strftime(time_now, sizeof(time_now), TIME_FMT, gmtime(&now));
			printf("%s-%s: %d packets sent\n", time_start, time_now, i);
		}
		
		usleep(1000000. / PACKETS_PER_SECOND); /* the time spend in sendto() API can be ignored compared to usleep() */
	}
	close(s);
	return 0;
}
