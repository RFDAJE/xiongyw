/* 
 * note that the source file must be utf8-encoded.
 * emacs: 
 *   c-x RET f utf-8
 *   c-x c-s
 * vim: 
 *   :setlocal nobomb
 *   :set encoding=utf-8
 *   :set fileencoding=utf-8
 *   :w
 */

settings.tex = "xelatex";

import graph;

size(400, 200, IgnoreAspect);

real birth_day = 2000. + (11 * 30 + 19) / 365.;
pair[] height={
               (birth_day,                         .5),   // 2000.12.19: height is to be confirmed
               (2004. + (11 * 30 + 19) / 365.,     .98),  // 2004.12.19: 0.98m
               (2011. + (11 * 30 + 19) / 365.,    1.335), // 2011.12.19: 1.335
	       (2013. + (11 * 30 + 19) / 365.,    1.466), // 2013.12.19: 1.466
	       (2014. + ( 7 * 30 + 18) / 365.,    1.500), // 2014.08.18: 1.500
	       (2014. + (11 * 30 + 19) / 365.,    1.517), // 2014.12.19: 1.517
	       (2015. + ( 4 * 30 +  2) / 365.,    1.534), // 2015.05.02: 1.534
	       (2015. + ( 6 * 30 +  2) / 365.,    1.543), // 2015.07.02: 1.543
	       (2016. + ( 1 * 30 + 13) / 365.,    1.550)  // 2016.02.13: 1.550
	      };

height -= (birth_day, 0);      // make X-axis starts from 0
//height = scale(1, 4) * height; // scale up Y-axis

pen dp=linewidth(1);
draw((0,0)--(20, 0), white);
draw((0,0)--(0,2),white);

int i;
path p = nullpath;
for (i = 0; i < size(height); ++ i) {
 p = p--height[i];
}
write(p);
draw(p, dp+red);
dot(height, linewidth(2));

xaxis("$age$", BottomTop, LeftTicks);
yaxis("$height$", LeftRight, RightTicks(trailingzero));


