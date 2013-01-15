/* created(bruin, 2007-02-05): ratioasc sequence dot diagram in a series of 2.
 *
 * $Id: ratioasc_trend.asy 2 2007-03-22 12:54:39Z Administrator $
 */

import graph;
import fontsize;
import "gcd.asy" as gcd;

texpreamble("\usepackage{CJK}\AtBeginDocument{\begin{CJK*}{GBK}{kai}}
  \AtEndDocument{\clearpage\end{CJK*}}");

picture pic1, pic2;
real xsize=200, ysize=150;
size(pic1, xsize, ysize, IgnoreAspect);
size(pic2, xsize, ysize, IgnoreAspect);

int x_apart = 10;
int max_num = 500;  /* point numbers */

pen dot_pen1 = linewidth(0.8) + red;
pen dot_pen2 = linewidth(1.5) + red;

pen tick_pen = linewidth(0.5) + black  + fontsize(8);
pen label_pen = fontsize(10);
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.1) + gray(0.5);

real ratio_doc[][] = new real[max_num][2];

int i, j, idx;

/* 1. prepair the diag sequence firstly */
/* the first 2 freq_ratio is 1/1 and 2/1 */
ratio_doc[0][0] = 1;
ratio_doc[0][1] = 1;
ratio_doc[1][0] = 2;
ratio_doc[1][1] = 1/2;
idx = 2;
/* loop to generate the diag seq: i is the denominator, j is the numerator */
for(i = 2; idx < max_num; ++ i){
	for(j = i; j < 2 * i && idx < max_num; ++ j){
		if(gcd(i, j) == 1){
			ratio_doc[idx][0] = j / i;
			ratio_doc[idx][1] = 1 / j / i;
			++ idx;
		}
	}
}
/* sort it */
ratio_doc = sort(ratio_doc);


/* pic1 */
for(i = 0; i < max_num; ++ i){
	dot(pic1, (i, ratio_doc[i][0]), dot_pen1);
}
/* grid */
for(i = 1; i < 5; ++ i){
	draw(pic1, (0, 1+i*0.2)--(max_num,1+i*0.2),grid_pen);  /* horizontal */
	draw(pic1, (i * 100,1)--(i*100,2),grid_pen);  /* vertical */
}
xaxis(pic1, Label(minipage("\centering序号\\\CJKfamily{hei}{a) 频率比变化趋势}", 100), label_pen),  BottomTop, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
yaxis(pic1, Label("频率比", label_pen), LeftRight,  RightTicks(Label("%#.1f", tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));

/* pic2 */
for(i = 0; i < max_num; ++ i){
	dot(pic2, (ratio_doc[i][0], log(ratio_doc[i][1])), dot_pen2);
}

ticklabel ExpFormat() {
  return new string(real x) {
    return format("%#.4f",exp(x));
  };
}
xaxis(pic2, Label(minipage("\centering频率比\\\CJKfamily{hei}{b) 和谐度变化趋势}", 100), label_pen),  BottomTop, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
yaxis(pic2, Label("和谐度", label_pen), LeftRight,  RightTicks(Label("%#.1f", tick_pen), ticklabel=ExpFormat(), N=5, n=1, Size=1.2, pTick=tick_pen));

add(pic1.fit(), (0,0), NE);
add(pic2.fit(), (xsize+x_apart,0), NE);

