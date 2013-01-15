/* created(bruin, 2007-02-01): diag sequence in dots.
 *
 * $Id: diag_dots.asy 2 2007-03-22 12:54:39Z Administrator $
 */
 
import graph;
import fontsize;
import "gcd.asy" as gcd;

texpreamble("\usepackage{CJK}\AtBeginDocument{\begin{CJK*}{GBK}{kai}}
  \AtEndDocument{\clearpage\end{CJK*}}");


unitsize(4);
//defaultpen(basealign(1));


real dot_radius = 1.2;
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.1) + /* dashed + */ gray(0.5);
pen dot_pen = linewidth(dot_radius * 2) + red;

int range = 50;
int i, j, i0 = 0, j0 = 0, idx = 0;


/* grid */
for(i = 0; i <= range / 10; ++ i){
	draw((0,i*10)--(range,i*10),grid_pen);  /* horizontal */
	draw((i*10,0)--(i*10,range),grid_pen);  /* vertical */
}

/* border */
draw(box((0,0),(range,range)),border_pen);

/* diag lines */
//draw((0,0)--(range,range),grid_pen);
//draw((0,0)--(range/2,range),grid_pen);

/* dots */
/* loop: i is the denominator, j is the numerator */
for(i = 1; i < range; ++ i)
for(j = i; j <= 2 * i; ++ j){
	if(gcd(i, j) == 1){
		if(j < range) 
			dot((i,j), dot_pen);
	}
}

xaxis("·ÖÄ¸", Bottom, LeftTicks(beginlabel=false, n=1, Size=0, size=0, pTick=linewidth(0.1)));
yaxis("·Ö×Ó", Left,  RightTicks(beginlabel=false, n=1, Size=0, size=0, pTick=linewidth(0.1)));
label("0", (0,0), SW); // origin