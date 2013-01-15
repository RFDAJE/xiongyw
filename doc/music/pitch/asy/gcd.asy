/* created(bruin, 2007-02-01): put common local functions here.
 *
 * $Id: gcd.asy 2 2007-03-22 12:54:39Z Administrator $
 */



/* created(bruin, 2006-07-24): get gcd of two integers.
 * modified(bruin, 2007-02-01): simplify it for asymptote.
 *
 * return: the gcd, 0 means no gcd (i.e., infinity).
 */
int gcd(int a, int b)
{

	int aa, bb, gcd, r, q; 
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
		int tmp = aa;
		aa = bb;
		bb = tmp;
		swapped = 1;
	}

	_steps = 0;
	
	/* handle trivial cases */
	if(aa == 0 || bb == 0) return 0;


	/* main loop for normalized pair (aa, bb) */
	gcd = bb;
	_x0 = 0;
	_y0 = 1;
	while((r = aa % bb) != 0){
		
		q = (int) (aa / bb);
		
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

		/* prepare for the next step */
		aa = bb;
		bb = r;
		gcd = r;

		_steps += 1;
	}

	return gcd;
}