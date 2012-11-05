/* created(bruin, 2007-02-02): cent/doc relation.
 *
 * $Id: cent_doc.asy 2 2007-03-22 12:54:39Z Administrator $
 */

import graph;
import stats;
import fontsize;
import "gcd.asy" as gcd;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             \usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             \newcommand{\myfrac}[2]{#1\!/\!#2}
             \AtBeginDocument{\begin{CJK*}{GBK}{kai}}
             \AtEndDocument{\clearpage\end{CJK*}}"
            );


real ratio2cent(real r)
{
	return  (1200. * log(1. * r) / log(2.));
}


size(300, 160, IgnoreAspect);
int max_num = 10000;  /* sufficient for step size 3.0 */

pen line_pen = linewidth(0.2) + red;
pen tick_pen = linewidth(0.1) + black + fontsize(5);
pen cut_pen = linewidth(0.1) + dashdotted + blue + fontsize(5);
pen ratio_pen = linewidth(0.1) + blue + fontsize(5);
pen label_pen = fontsize(8);
pen border_pen = linewidth(0.8) + black;
pen grid_pen = linewidth(0.1) + dashdotted + gray(0.5);


real ratio_doc[][] = new real[max_num][2]; /* [][0] is ratio, [][1] is doc */
pair cent_logdoc[];     /* x=cent, y=log(doc) */

int i, j, idx;

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
			ratio_doc[idx][1] = 1. / i / j;
			++ idx;
		}
	}
}
ratio_doc = sort(ratio_doc);  // sort by ratio (i.e. the 1st column)

real ear_threshold_in_cent = 6.0;
real step = ear_threshold_in_cent / 2;
real cent, low, high;
for(i = 0, cent = 0.; cent <= 1200.; ++ i, cent += step){
		low = cent - ear_threshold_in_cent;
		high =  cent + ear_threshold_in_cent;
		/* dod (degree of dissonance) is reciprocal of doc */
		real doc = 0., tmp_doc, tmp_cent; 
		/* find the smallest dod in range [low, high] */
		for(j = 0; j < max_num ; ++ j){
				tmp_cent = ratio2cent(ratio_doc[j][0]);
				if(low < tmp_cent && tmp_cent < high){
						tmp_doc = ratio_doc[j][1];
						if(doc < tmp_doc) doc = tmp_doc;
				}
				if(tmp_cent > high)
					break;
		}
		cent_logdoc[i] = (cent, log(doc));
}
//write(cent_logdoc);

guide halfbox_nw(pair a, pair b)
{
  return a--(a.x,b.y)--b;
}
guide halfbox_se(pair a, pair b)
{
  return a--(b.x,a.y)--b;
}
guide halfbox_middle(pair a, pair b)
{
  return a--((a.x + b.x) / 2, a.y)--((a.x + b.x) / 2, b.y)--b;
}

for(i = 0; i < cent_logdoc.length - 1; ++ i){
	draw(halfbox_middle(cent_logdoc[i], cent_logdoc[i+1]), line_pen);
	//draw(halfbox_nw(cent_logdoc[i], cent_logdoc[i+1]), line_pen);
	//draw(halfbox_se(cent_logdoc[i], cent_logdoc[i+1]), line_pen);
}

ticklabel ExpFormat() {
  return new string(real x) {
    return format("%#.4f",exp(x));
  };
}

/* grid */
real v[] = {0.000045, 0.000335, 0.002479, 0.018316, 0.135335};
//for(i = 1; i <= 4; ++ i){
//	draw((0,log(v[i]))--(1200,log(v[i])),grid_pen);  /* horizontal */
//}

real doc_threshold = 1 / 40;
yequals(y=log(doc_threshold), extend=true, xmin=0, xmax=1200, cut_pen);
label("0.025", (0, log(doc_threshold)), W, cut_pen);
//label("0.025", (1200, log(doc_threshold)), E, cut_pen);

/* vertical grid */
for(i = 1; i < 12; ++ i){
	draw((i*100,log(v[0]))--(i*100,0), grid_pen);  
}

xaxis(Label("音分值", label_pen),  BottomTop, LeftTicks(Label(tick_pen), N=12, n=2, Size=1.2, size=0.8, pTick=tick_pen));
yaxis(Label("和谐度", label_pen), LeftRight, RightTicks(Label("%#.1f", tick_pen), ticklabel=ExpFormat(), N=4, n=1, Size=1.2, pTick=tick_pen));



/* mark consonance ratios */
label("\myfrac{1}{1}", (0, 0), SE, ratio_pen);
label("\myfrac{2}{1}", (1200, log(1/2)), SW, ratio_pen);
label("\myfrac{3}{2}", (ratio2cent(3/2), log(1/6)), N, ratio_pen);
label("\myfrac{4}{3}", (ratio2cent(4/3), log(1/12)), N, ratio_pen);
label("\myfrac{5}{3}", (ratio2cent(5/3), log(1/15)), N, ratio_pen);
label("\myfrac{5}{4}", (ratio2cent(5/4), log(1/20)), N, ratio_pen);
label("\myfrac{7}{4}", (ratio2cent(7/4), log(1/28)), N, ratio_pen);
label("\myfrac{6}{5}", (ratio2cent(6/5), log(1/30)), N, ratio_pen);
label("\myfrac{7}{5}", (ratio2cent(7/5), log(1/35)), N, ratio_pen);
label("\myfrac{8}{5}", (ratio2cent(8/5), log(1/40)), N, ratio_pen);
label("\myfrac{7}{6}", (ratio2cent(7/6), log(1/42)), S, ratio_pen);
label("\myfrac{9}{5}", (ratio2cent(9/5), log(1/45)), S, ratio_pen);


