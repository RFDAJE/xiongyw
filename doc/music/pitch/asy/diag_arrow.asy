/* created(bruin, 2007-02-01): draw diag generation sequence.
 *
 * $Id: diag_arrow.asy 2 2007-03-22 12:54:39Z Administrator $
 */
 
import graph;
import fontsize;
import "gcd.asy" as gcd;

texpreamble("\usepackage{CJK}\AtBeginDocument{\begin{CJK*}{GBK}{kai}}
  \AtEndDocument{\clearpage\end{CJK*}}");


unitsize(20);
//defaultpen(basealign(1));


real dot_radius = 5;
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.2) + /* dashed + */ gray(0.5);
pen dot_pen = linewidth(dot_radius * 2) + black;
pen arrow_pen = linewidth(0.4) + red;

int range = 10;
int i, j, i0 = 0, j0 = 0, idx = 0;
bool out = false;


/* grid */
for(i = 0; i <= range; ++ i){
	draw((0,i)--(range,i),grid_pen);  /* horizontal */
	draw((i,0)--(i,range),grid_pen);  /* vertical */
}

/* border */
draw(box((0,0),(range,range)),border_pen);

/* diag lines */
draw((0,0)--(range,range),grid_pen);
draw((0,0)--(range/2,range),grid_pen);

/* dots and arrows */
/* loop: i is the denominator, j is the numerator */
for(i = 1; i < range && !out; ++ i)
for(j = i; j <= 2 * i; ++ j){
	if(gcd(i, j) == 1){
		if(j > range){ /* out of the pic range, stop drawing */
			out = true;
			continue;
		}
		idx += 1;
		dot((i,j), dot_pen);
		label(format("%d", idx), (i, j), Center, linewidth(0.1) + white + fontsize(dot_radius * 1.7));
		if(i0 != 0){
			draw((i0,j0)--(i,j), arrow_pen, Arrow, TrueMargin(dot_radius, dot_radius));
		}
		i0 = i;		j0 = j;
	}
}

xaxis("·ÖÄ¸", Bottom, LeftTicks(beginlabel=false, n=1, Size=0, size=0, pTick=linewidth(0.1)));
yaxis("·Ö×Ó", Left,  RightTicks(beginlabel=false, n=1, Size=0, size=0, pTick=linewidth(0.1)));
label("0", (0,0), SW); // origin