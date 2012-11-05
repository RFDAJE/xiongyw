/* created(bruin, 2007-02-05): docdes sequence dot diagram in a series of 2.
 *
 * $Id: docdes_2in1.asy 2 2007-03-22 12:54:39Z Administrator $
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
int max_num = 2000;  /* point numbers */
int pic1_num = 500;
int pic2_num = max_num;

pen dot_pen1 = linewidth(1.5) + red;
pen dot_pen2 = linewidth(1.2) + red;

pen tick_pen = linewidth(0.5) + black  + fontsize(8);
pen label_pen = fontsize(10);
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.2) + gray(0.5);

real doc_ratio1[][] = new real[pic1_num][2];
real doc_ratio2[][] = new real[pic2_num][2];

int i, j, idx;

/* 1. prepair the diag sequence firstly */
/* the first 2 freq_ratio is 1/1 and 2/1 */
doc_ratio2[0][0] = 1;
doc_ratio2[0][1] = 1;
doc_ratio2[1][0] = 1/2;
doc_ratio2[1][1] = 2;
idx = 2;
/* loop to generate the diag seq: i is the denominator, j is the numerator */
for(i = 2; idx < max_num; ++ i){
	for(j = i; j < 2 * i && idx < max_num; ++ j){
		if(gcd(i, j) == 1){
			doc_ratio2[idx][0] = 1 / j / i;
			doc_ratio2[idx][1] = j / i;
			++ idx;
		}
	}
}
/* copy from longer array to short array */
for(i = 0; i < pic1_num; ++ i){
	doc_ratio1[i][0] = doc_ratio2[i][0];
	doc_ratio1[i][1] = doc_ratio2[i][1];
}
/* sort them */
doc_ratio1 = sort(doc_ratio1);
doc_ratio2 = sort(doc_ratio2);

/* pic1 */
for(i = 0; i < pic1_num; ++ i){
	dot(pic1, (pic1_num - i - 1, doc_ratio1[i][1]), dot_pen1);
}
xaxis(pic1, Label(minipage("\centering序号\\\CJKfamily{hei}{a) 前\,500\,项}", 100), label_pen),  BottomTop, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
yaxis(pic1, Label("频率比", label_pen), LeftRight,  RightTicks(Label("%#.1f", tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
//draw(pic1, (0,1)--(max_num,1)--(max_num,2)--(0,2)--cycle, border_pen); // border

/* pic2 */
for(i = 0; i < pic2_num; ++ i){
	dot(pic2, (pic2_num - i - 1, doc_ratio2[i][1]), dot_pen2);
}

//dot(pic2, ratio_orig, dot_pen);
xaxis(pic2, Label(minipage("\centering序号\\\CJKfamily{hei}{b) 前\,2000\,项}", 100), label_pen),  BottomTop, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
yaxis(pic2, Label("频率比", label_pen), LeftRight,  RightTicks(Label("%#.1f", tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
//draw(pic2, (0,1)--(max_num,1)--(max_num,2)--(0,2)--cycle, border_pen); // border


add(pic1.fit(), (0,0), NE);
add(pic2.fit(), (xsize+x_apart,0), NE);

