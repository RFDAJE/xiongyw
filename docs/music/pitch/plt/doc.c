/* created(bruin, 2007-01-04): calculate degree of consonance (doc) 
 * or degree of dissonance (dod) for intervals whoes corresponding
 * frequency ratios are expressed in (small) integers 
 *
 * $Id: doc.c 2 2007-03-22 12:54:39Z Administrator $
 */

#include <stdlib.h>   /* atof() needs it to behavor correctly */
#include <stdio.h>
#include <math.h>


#define VERY_BIG_NUM            (10000.)


/* human ear can not recognize interval less than the threshold below */
#define EAR_THRESHOLD_IN_CENT   (6.0)

typedef struct{
	/* freq ratio expressed in numerator/denominator, 
	 * where numberator >= denominator, and ratio < 2.0;
	 * since we will make sure that gcd(num, den) = 1 
	 * (i.e., co-prime), the doc of the ratio is equal to 
	 *  1 / (num * den) 
	 */
	unsigned short num;   
	unsigned short den;
}ratio_t;

#define RATIO_2_CENT(r)         (1200. * log(1. * r) / log(2.))
#define GET_RATIO(ratio_t)      (1. * ratio_t.num / ratio_t.den)
#define GET_CENT(ratio_t)        RATIO_2_CENT(GET_RATIO(ratio_t))
#define GET_DOD(ratio_t)        (ratio_t.num * ratio_t.den)
#define GET_DOC(ratio_t)        (1. / GET_DOD(ratio_t))

unsigned int get_gcd_2(int a, int b, int* x0, int* y0, int* steps); 


int main(int argc, char* argv[])
{

	unsigned int i, j, k, idx;
	unsigned int max_num;      /* num of intervals to calculate */
	double       threshold;    
	double       cent, ratio, step;

	/* pointer to arrays */
	ratio_t      *_ratio;
	unsigned int *_doc_des;   /* sort by doc in descending order */
	unsigned int *_ratio_asc; /* sort by ratio in ascending order */

	/* get arguments */
	if(argc != 3){
		perror("#usage: doc max_num threshold\n");
		exit(1);
	}
	else{
		max_num = atoi(argv[1]);
		threshold = (double)atof(argv[2]);
	}
	printf("#max_num=%d, threshold=%8.3f\n", 
             max_num,    threshold);

	/* allocate memory */
	if(NULL == (_ratio = malloc(sizeof(ratio_t) * max_num))){
		printf("#malloc _ratio failed.\n");
		goto EXIT;
	}
	else if(NULL == (_doc_des = malloc(sizeof(int) * max_num))){
		printf("#malloc _doc_des failed.\n");
		goto EXIT;
	}
	else if(NULL == (_ratio_asc = malloc(sizeof(int) * max_num))){
		printf("#malloc _ratio_asc failed.\n");
		goto EXIT;
	}
	
	/* the first 2 freq_ratio is 1/1 and 2/1 */
	_ratio[0].num = 1;
	_ratio[0].den = 1;
	_ratio[1].num = 2;
	_ratio[1].den = 1;
	idx = 2;
	/* loop: i is the denominator, j is the numerator */
	for(i = 2; idx < max_num; i ++){
		for(j = i; j < 2 * i && idx < max_num; j ++){
			if(get_gcd_2(i, j, NULL, NULL, NULL) == 1){
				_ratio[idx].num = j;
				_ratio[idx].den = i;
				idx ++;
			}
		}
	}

#if (0)
	/* gnu plot vector format to illustrate the diag seq generation */
	printf("# x, y, xdelta, ydelta\n");
	for(i = 0; i < max_num - 1; i ++){
		printf("%.1f, %.1f, %.1f, %.1f\n", 
		       1. * _ratio[i].den, 
		       1. * _ratio[i].num,
		       1. * _ratio[i + 1].den - 1. * _ratio[i].den,
		       1. * _ratio[i + 1].num - 1. * _ratio[i].num);
	}
#endif
	
	/* sort by doc in descending order: simply insertion sort */
	for(i = 0; i < max_num; i ++){
		int cur, tmp;
		_doc_des[i] = i;
		cur = GET_DOD(_ratio[i]);
		for(j = 0; j < i; j ++){
			tmp = GET_DOD(_ratio[_doc_des[j]]);
			if(cur < tmp){
				/* insert current index i before j */
				for(k = i; k > j; k --){
					_doc_des[k] = _doc_des[k - 1];
				}
				_doc_des[j] = i;
				break;
			}
#if (0)			
			/* test */
			if(cur == tmp){
				printf("#!!! ");
				printf("%d * %d = %d * %d = %d; cent_diff=%4.2f\n", 
				 _ratio[i].num, _ratio[i].den,
				 _ratio[_doc_des[j]].num, _ratio[_doc_des[j]].den,
				 cur,
				 fabs(GET_CENT(_ratio[i]) - GET_CENT(_ratio[_doc_des[j]])));
			}
#endif			
		}
	}
	
	/* sort by ratio in ascending order */
	for(i = 0; i < max_num; i ++){
		double cur, tmp;
		_ratio_asc[i] = i;
		cur = GET_RATIO(_ratio[i]);
		for(j = 0; j < i; j ++){
			tmp = GET_RATIO(_ratio[_ratio_asc[j]]);
			if(cur < tmp){
				/* insert current index i before j */
				for(k = i; k > j; k --){
					_ratio_asc[k] = _ratio_asc[k - 1];
				}
				_ratio_asc[j] = i;
				break;
			}
		}
	}

#if (0)
	/* print the results in the following format:
	 *   idx, diag_ratio, diag_doc, doc_des_ratio, doc_des_doc, ratio_asc_ratio, ratio_asc_doc
	 * where "diag_"      represents the original diagnal generated rational number sequence;
	 *       "doc_des_"   represents the sorted sequence in descending order of doc;
	 *       "ratio_asc_" represents the sorted sequence in ascending order of ratio;
	 */
	printf("# data format: idx,");
	printf("   diag_ratio, diag_doc,");
	printf("   doc_des_ratio, doc_des_doc,");
	printf("   ratio_asc_ratio, ratio_asc_doc\n");
	for(i = 0; i < max_num; i ++){
#if (1)		
			printf("%.1f,    %.12f, %.12f,     %.12f, %.12f,     %.12f, %.12f \n",      1. * i, 
			GET_RATIO(_ratio[i]),             GET_DOC(_ratio[i]),
			GET_RATIO(_ratio[_doc_des[i]]),   GET_DOC(_ratio[_doc_des[i]]),
			GET_RATIO(_ratio[_ratio_asc[i]]), GET_DOC(_ratio[_ratio_asc[i]]));
#else
			printf("%d & %d/%d & 1/%d & %d/%d & 1/%d & %d/%d & 1/%d\\\\\\hline\n", i,
			_ratio[i].num, _ratio[i].den, GET_DOD(_ratio[i]),
			_ratio[_doc_des[i]].num, _ratio[_doc_des[i]].den, GET_DOD(_ratio[_doc_des[i]]),
			_ratio[_ratio_asc[i]].num, _ratio[_ratio_asc[i]].den, GET_DOD(_ratio[_ratio_asc[i]]));
#endif			
	}	
#endif



#if (0)
	/* print the results in the following format:
	 *   idx, diag_ratio_den, diag_ratio_num, diag_dod, doc_des_ratio_den, doc_des_ratio_num, doc_des_dod, ratio_asc_ratio_den, ratio_asc_ratio_num, ratio_asc_dod
	 * where "diag_"      represents the original diagnal generated rational number sequence;
	 *       "doc_des_"   represents the sorted sequence in descending order of doc;
	 *       "ratio_asc_" represents the sorted sequence in ascending order of ratio;
	 */
	printf("# data format: \n#idx,");
	printf("   diag_ratio_den, diag_ratio_num, diag_dod,");
	printf("   doc_des_ratio_den, doc_des_ratio_num, doc_des_dod,");
	printf("   ratio_asc_ratio_den, ratio_asc_ratio_num, ratio_asc_dod\n");
	for(i = 0; i < max_num; i ++){
			printf("%.1f,   %.1f, %.1f, %.1f,   %.1f, %.1f, %.1f,   %.1f, %.1f, %.1f\n", 1. * i,
			1. * _ratio[i].den, 1. * _ratio[i].num, 1. * GET_DOD(_ratio[i]),
			1. * _ratio[_doc_des[i]].den, 1. * _ratio[_doc_des[i]].num, 1. * GET_DOD(_ratio[_doc_des[i]]),
			1. * _ratio[_ratio_asc[i]].den, 1. * _ratio[_ratio_asc[i]].num, 1. * GET_DOD(_ratio[_ratio_asc[i]]));
	}	
#endif





#if (0)
	/* plot the doc within one octave, take the threshold as the radius of the neighborhood */
	printf("#ratio, doc (biggest in the neighborhood)\n");
	/* step is half of the threshold */
	step = threshold / 2.;
	for(i = 0, ratio = 1.; ratio <= 2.; i ++, ratio += step){
			double low = ratio - threshold;
			double high =  ratio + threshold;
			/* dod (degree of dissonance) is reciprocal of doc */
			double dod = VERY_BIG_NUM, tmp_dod, tmp_ratio; 
			/* find the smallest dod in range [low, high] */
			for(j = 0; j < max_num ; j ++){
					tmp_ratio = GET_RATIO(_ratio[_ratio_asc[j]]);
					if(low < tmp_ratio && tmp_ratio < high){
							tmp_dod = GET_DOD(_ratio[_ratio_asc[j]]);
							if(dod > tmp_dod) dod = tmp_dod;
					}
					if(tmp_ratio > high)
						break;
			}
			printf("%7.5f, %10.9f\n", ratio, 1./dod);
	}
#endif


#if (1)
	/* plot the doc within one octave using cent, take 6 cents (threshold) as the radius of the neighborhood */
	printf("#cent, doc (biggest in the neighborhood)\n");
	/* step is half of the threshold */
	step = EAR_THRESHOLD_IN_CENT / 2.;
	for(i = 0, cent = 0.; cent <= 1200.; i ++, cent += step){
			double low = cent - threshold;
			double high =  cent + threshold;
			/* dod (degree of dissonance) is reciprocal of doc */
			double dod = VERY_BIG_NUM, tmp_dod, tmp_cent; 
			/* find the smallest dod in range [low, high] */
			for(j = 0; j < max_num ; j ++){
					tmp_cent = GET_CENT(_ratio[_ratio_asc[j]]);
					if(low < tmp_cent && tmp_cent < high){
							tmp_dod = GET_DOD(_ratio[_ratio_asc[j]]);
							if(dod > tmp_dod) dod = tmp_dod;
					}
					if(tmp_cent > high)
						break;
			}
			printf("%7.5f, %10.9f\n", cent, 1./dod);
	}
#endif

EXIT:
	if(_ratio)     free(_ratio);
	if(_doc_des)   free(_doc_des);
	if(_ratio_asc) free(_ratio_asc);

	return 0;
}


/* added(bruin, 2006-07-24): 
 * return: the gcd, 0 means no gcd (i.e., infinity).
 * x0,y0: a * x0 + b * y0 = gcd(a, b)
 */
unsigned int get_gcd_2(int a, int b, int* x0, int* y0, int* steps)
{

	unsigned int aa, bb, gcd, r, q; 
	int _steps, _x0, _y0, x_1, y_1, x_2, y_2; /* _x0 is x(n), x_1 is x(n-1), x_2 is x(n-2) */
	
	int swapped = 0; /* |a| < |b| ? */
	
	/* abs: make them all positive, since (a, b) = (|a|, |b|) */
	if(a < 0)
		aa = - a;
	else 
		aa = a;
	if(b < 0)
		bb = - b;
	else
		bb = b;

	/* swap: make sure aa >= bb */
	if(aa < bb){
		unsigned int tmp = aa;
		aa = bb;
		bb = tmp;
		swapped = 1;
	}

	_steps = 0;
	
	/* handle trivial cases */
	if(aa == 0 && bb == 0){
		gcd = 0; 
		_x0 = _y0 = 0;
		goto RET;
	}

	if(aa == 0){
		gcd = bb; 
		_x0 = 0;
		_y0 = 1;
		goto RET;
	}

	if(bb == 0){
		gcd = aa; 
		_x0 = 1;
		_y0 = 0;
		goto RET;
	}

	/* main loop for normalized pair (aa, bb) */
	gcd = bb;
	_x0 = 0;
	_y0 = 1;
	while(r = aa % bb){
		
		q = aa / bb;
		
		/* steps:
		   0:     a=bq1+r1   => r1=a-bq1    => (x1,y1)=(1,     -q1) 
		   1:     b=r1q2+r2  => r2=b-r1q2   => (x2,y2)=(-q2x1, -q2y1) + ( 0,  1)
		   2:     r1=r2q3+r3 => r3=r1-r2q3  => (x3,y3)=(-q3x2, -q3y2) + (x1, y1)
		   3:     r2=r3q4+r4 => r4=r2-r3q4  => (x4,y4)=(-q4x3, -q4y3) + (x2, y2)
		   ...
		 */
		if(_steps == 0){
			_x0 = 1;
			_y0 = - q;
			
		}
		else if(_steps == 1){
			/* save the previous (x, y) */
			x_1 = _x0;
			y_1 = _y0;
			/* calcuate the new (x, y) */
			_x0 = - q * _x0;
			_y0 = - q * _y0 + 1;
		}
		else{
			/* save two previous (x, y) */
			x_2 = x_1;
			y_2 = y_1;
			x_1 = _x0;
			y_1 = _y0;
			/* calcuate the new (x, y) */
			_x0 = - q * _x0 + x_2;
			_y0 = - q * _y0 + y_2;
		}

		/* printf("\nstep=%2d, (%4d, %4d), r=%4d", *steps, aa, bb, r); */

		/* prepare for the next step */
		aa = bb;
		bb = r;
		gcd = r;

		_steps += 1;
	}


RET:
	
	/* handle the "swap" & "abs" cases for (x0, y0) */
	if(swapped){
		int tmp = _x0;
		_x0 = _y0;
		_y0 = tmp;
	}
	_x0 *= (a < 0)? - 1 : 1;
	_y0 *= (b < 0)? - 1 : 1;

	/* assign return values */	
	if(steps)
		*steps = _steps;
	if(x0)
		*x0 = _x0;
	if(y0)
		*y0 = _y0;

#if (0)
	/* verify the value */
	if((a * _x0 + b * _y0) != gcd){
		printf("ERROR: %d * %d + %d * %d != %d\n", a, _x0, b, _y0, gcd);
	}
	else{
		printf("OK: %d * %d + %d * %d = %d ", a, _x0, b, _y0, gcd);
	}
#endif

	/* printf(" ==> gcd(%d, %d)=%d\n", a, b, gcd); */
	
	return gcd;
}

