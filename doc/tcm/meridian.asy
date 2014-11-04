/*
 * created(bruin, 2014-11-04)
 */

settings.tex = "xelatex";

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");
texpreamble("\xeCJKsetcharclass{\"2600}{\"267F}{1}");  // this tells xetex to treat "symbol misc" as CJK


import math;
//import three;
//import labelpath3;
//import labelpath;
import fontsize;

/*
 * about sizes
 */
real pt2cm = 1 / 72.27 * 2.54; // 1 pt = 1/72.27 inch; 
real bp2cm = 1 / 72 * 2.54;    // 1 bp = 1/72 inch
real cm2pt = 1 / pt2cm;
real cm2bp = 1 / bp2cm;

real unit_size_in_cm = 0.5;   // make yinyang circle size about 1x1cm
real unit_size_in_pt = unit_size_in_cm * cm2pt;
real line_width_in_cm = 4;
real line_width_in_bp = line_width_in_cm * cm2bp;
real font_size_in_cm = 12;
real font_size_in_pt = font_size_in_cm * cm2pt; 
real font_size_in_user = font_size_in_cm / unit_size_in_cm;

unitsize(unit_size_in_pt);
defaultpen(linewidth(line_width_in_bp) + black + linecap(2));
defaultpen(fontsize(font_size_in_pt));
//defaultpen(basealign(0));

//label("1", (0, 0), invisible);
//real font_height = (max(currentpicture).y - min(currentpicture).y) * bp2cm / unit_size_in_cm;



path[]  big_e = (0,0)--(150,0)^^(0,100)--(150,100)^^(0,200)--(150,200)^^(0,0)--(0,200);

draw(big_e);

// yin: black

label("\texttt{\bfseries\itshape LU}", (0,200), NW);
label("\texttt{\bfseries\itshape HT}", (0,100), NW);
label("\texttt{\bfseries\itshape PC}", (0,  0), NW);

label("\texttt{\bfseries SP}", (0,200), SW);
label("\texttt{\bfseries KI}", (0,100), SW);
label("\texttt{\bfseries LR}", (0,  0), SW);

// yang: red


label("\texttt{\bfseries\itshape LI}", (150,200), NE);
label("\texttt{\bfseries\itshape SI}", (150,100), NE);
label("\texttt{\bfseries\itshape TE}", (150,  0), NE);

label("\texttt{\bfseries ST}", (150,200), SE);
label("\texttt{\bfseries BL}", (150,100), SE);
label("\texttt{\bfseries GB}", (150,  0), SE);

