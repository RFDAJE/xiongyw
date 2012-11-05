/* created(bruin, 2007-02-02): diag sequence trend.
 *
 * $Id: diag_trend.asy 2 2007-03-22 12:54:39Z Administrator $
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
//scale(pic2,Linear, Log);

int x_apart = 12;
int max_num = 100;  /* point numbers */

pen dot_pen = linewidth(1.5) + red;
pen tick_pen = linewidth(0.5) + black  + fontsize(8);
pen label_pen = fontsize(10);
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.2) + gray(0.5);


pair seq[];          /* x=numerator, y=denominator */
real ratio[];        /* ratio sequence in ascending order */
real ratio_by_doc[]; /* ratio sequence in doc's ascending order */

pair ratio_orig[], ratio_sort_by_ratio[], ratio_sort_by_doc[], doc_orig[];

int i, j, idx;

/* 1. prepair the diag sequence firstly */
/* the first 2 freq_ratio is 1/1 and 2/1 */
seq[0] = (1, 1);
seq[1] = (2, 1);
ratio[0] = 1;
ratio[1] = 2;
ratio_orig[0] = (0, 1);
ratio_orig[1] = (1, 2);
doc_orig[0] = (0, 1);
doc_orig[1] = (0, 1/2);
idx = 2;
/* loop to generate the diag seq: i is the denominator, j is the numerator */
for(i = 2; idx < max_num; ++ i){
	for(j = i; j < 2 * i && idx < max_num; ++ j){
		if(gcd(i, j) == 1){
			seq[idx] = (j, i);
			ratio[idx] = seq[idx].x / seq[idx].y;
			ratio_orig[idx] = (idx, j / i);
			doc_orig[idx] = (idx, 1. / i / j);
			++ idx;
		}
	}
}
ratio = sort(ratio);

/* 2. get ratio_by_doc[]  */
{
	real temp[][] = new real[max_num][2]; /* [][0] is doc's reciprocal (1/doc), [][1] is ratio */
	for(i = 0; i < max_num; ++ i){
		temp[i][0] = seq[i].x * seq[i].y;
		temp[i][1] = seq[i].x / seq[i].y;
	}
	temp = sort(temp); /* now temp[1] can be copied to ratio_by_doc[] */
	for(i = 0; i < max_num; ++ i)
		ratio_by_doc[i] = temp[i][1];
}

for(i = 0; i < max_num; ++ i){
	ratio_sort_by_ratio[i] = (i, ratio[i]);
	ratio_sort_by_doc[i] = (i, ratio_by_doc[i]);
}

/* pic1 */
dot(pic1, ratio_orig, dot_pen);
xaxis(pic1, Label(minipage("\centering序~号\\\CJKfamily{hei}{a) 频率比变化趋势}", 100), label_pen),  Bottom, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
yaxis(pic1, Label("频率比", label_pen), Left,  RightTicks(Label("%#.1f", tick_pen), N=5, n=1, Size=1.2, pTick=tick_pen));
draw(pic1, (0,1)--(max_num,1)--(max_num,2)--(0,2)--cycle, border_pen); // border


/* pic2 */
ticklabel ExpFormat() {
  return new string(real x) {
    return format("%#.3f",exp(x));
  };
}

for(i = 0; i < seq.length; ++ i){
	dot(pic2, (i, log(1. / seq[i].x / seq[i].y)), dot_pen);
}
/* grid */
real v[] = {0.000912, 0.003698, 0.014996, 0.06081, 0.246597};
for(i = 1; i <= 4; ++ i){
	draw(pic2, (0,log(v[i]))--(max_num,log(v[i])),grid_pen);  /* horizontal */
	draw(pic2, (i*20,log(v[0]))--(i*20,0),grid_pen);  /* vertical */
}
xaxis(pic2, Label(minipage("\centering序~号\\\CJKfamily{hei}{b) 和谐度变化趋势}", 100), label_pen), BottomTop, p=border_pen, LeftTicks(Label(tick_pen), N=5, n=1, Size=1.2, extend=false, pTick=tick_pen));
yaxis(pic2, Label("和谐度", label_pen), LeftRight, p=border_pen, RightTicks(Label(tick_pen), ticklabel=ExpFormat(), N=5, n=1, Size=1.2, extend=false, pTick=tick_pen));


add(pic1.fit(),  (0,0), W);
add(pic2.fit(), (x_apart,0), E);