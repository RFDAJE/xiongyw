/* 
 * (noted, bruin, 2006-12-25)
 *
 * "circle of fifths": up or down at frequency ratio 3/2
 *
 * generally, we can "circle" (up or down) with any frequency ratio (q), then 
 * the generated series (temperament) could be calculated as follows:
 * 
 * 1. set the freq of the "base tone" as 1, so any number can be treated as 
 *    both a freq and a freq ratio (to the base tone)
 * 2. the freq (ratio) of any tone is in a geometric series: 
 *        freq(N)= q**N
 *    where q is the common ratio, and N is an integer (positive and negative). 
 * 3. octavize all freq (ratio) in the geometric series, i.e., octavize them 
 *    into [1,2), by:
 *        octavize(x) = x / 2**(floor(log(x)/log(2)))
 * 4. calculate the interval betw the base tone and any freq (ratio) in [1,2):
 *        cent(x) = 1200 * log(x) / log(2)
 *
 *
 * when q=2**(1/12), we get 12-equal temperament;
 * when q=3/2, we get circle of fifths;
 * when q=4/3, we get "circle of fouths", which is essentially the same as circle of fifths;
 *
 * when q=7/4, we get a five-tone scale produces "PrimaSounds", as invented by Arnold Keyserling in 1971.
 *    
 */

/* compile: "gcc circle.c -lm" */

#include <stdio.h>
#include <math.h>

#define COMMA_MAXIMA_IN_CENT (23.460010)
#define JING_COMMA_IN_CENT   ( 3.615046)
#define QIAN_COMMA_IN_CENT   ( 1.845311)

#define THRESHOLD_IN_CENT    (COMMA_MAXIMA_IN_CENT + 0.000001)

/* freq and cent of 12-equal temperament */
double g_freq_12[12];
double g_cent_12[12];


double octavize(double x)
{
		if(x <= 0.0)
				return 0.;
		return (x / pow(2., floor(log(x)/log(2.))));
}

double cent(double x)
{	
		if(x <= 0.0)
				return 0.;
		return (1200. * log(x) / log(2.));
}

/* circle with a common ratio several times */
void circle(double ratio, /* common ratio */
            int    num)   /* times, can be either positive or negative */
{
		int i, j;
		double f, q, c, d;

		printf("circle(ratio=%f, num=%d):\n", ratio, num);
		
		q = (num > 0.)? ratio : 1. / ratio;

		for(i = 0; i < abs(num); i ++){
				f = octavize(pow(q, i));
				c = cent(f);
				printf("%4d: %.4f, %.2f", i, f, c);

				/* mark if the tone nearly closes the "circle"  */
				if(c < THRESHOLD_IN_CENT)        printf(" [#%f]",c);
				if(c > (1200-THRESHOLD_IN_CENT)) printf(" [b%f]",1200.-c);

				/* make if the tone close to any tone of the 12 equal temperament */
				for(j = 0; j < 12; j ++){
						d = fabs(c - g_cent_12[j]); /* diff */
						if(d < THRESHOLD_IN_CENT){
								printf(" ==>%d: %.0f, %f", j, g_cent_12[j], d);
						}
				}

				printf("\n");
		}
}

void main(){

		int i;

		printf("12-equal temperament: idx: freq, cent \n");
		for(i = 0; i < 12; i ++){
				g_freq_12[i] = pow(2., i / 12.);
				g_cent_12[i] = cent(g_freq_12[i]);
				printf("%4d: %.4f, %.2f\n", i, g_freq_12[i], g_cent_12[i]);
		}

		/* 12-equal temperament */
		/* circle(pow(2.,1/12.),12); */
#if (0)		
		/* circle of fifths: up/down */
		circle(3./2., 1000);
		circle(3./2., -1000);

		/* circle of fourths: up/down */
		circle(4./3., 1000);
		circle(4./3., -1000);
#endif

		/* circle of 7/4: up/down */
		circle(7./4., 1000);
		circle(7./4., -1000);
}
