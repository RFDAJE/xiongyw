/*
 * created(bruin, 2014-11-04)
 */

settings.tex = "xelatex";
usepackage("fontspec");

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");



import math;
import fontsize;

/*
 * about sizes
 */
real pt2cm = 1 / 72.27 * 2.54; // 1 pt = 1/72.27 inch; 
real bp2cm = 1 / 72 * 2.54;    // 1 bp = 1/72 inch
real cm2pt = 1 / pt2cm;
real cm2bp = 1 / bp2cm;

real unit_size_in_cm = 1;
real unit_size_in_pt = unit_size_in_cm * cm2pt;
real font_size_in_cm = 0.5;
real font_size_in_pt = font_size_in_cm * cm2pt; 

unitsize(unit_size_in_pt);

pen pen_e = linewidth(250) + black + linecap(2);
pen pen_yin = linewidth(1) + black;
pen pen_yang = linewidth(1) + red;
pen pen_text = fontsize(160) + grey;

/*
 * size/coordinates of the big E:
 *
 *     +-----(150,200)
 *     |
 *     +-----(150,100)
 *     |
 *     +-----(150,0)
 *  (0,0)    
 */
path[]  BIG_E = (0,0)--(150,0)^^(0,100)--(150,100)^^(0,200)--(150,200)^^(0,0)--(0,200);
pair up = (0, 6), down = (0, -16);
pair left1 = (-7, 0), left2 = (-25, 0);
pair lu = (0, 200) + up + left1,   li = (150, 200) + up + left2,
     sp = (0, 200) + down + left1, st = (150, 200) + down + left2,
     ht = (0, 100) + up + left1,   si = (150, 100) + up + left2,
     ki = (0, 100) + down + left1, bl = (150, 100) + down + left2,
     pc = (0,   0) + up + left1,   te = (150,   0) + up + left2,
     lr = (0,   0) + down + left1,   gb = (150,   0) + down + left2;


/* 
 * text outline: http://tex.stackexchange.com/questions/21548/outlining-filling-glyph-outline-with-text-in-tikz
 */

path[]  LU = texpath(Label("\texttt{\bfseries LU}", font_size_in_pt, align=Align));
path[]  LI = texpath(Label("\texttt{\bfseries LI}", font_size_in_pt, align=Align));
path[]  ST = texpath(Label("\texttt{\bfseries\underline{ST}}", font_size_in_pt, align=Align));
path[]  SP = texpath(Label("\texttt{\bfseries\underline{SP}}", font_size_in_pt, align=Align));
path[]  HT = texpath(Label("\texttt{\bfseries HT}", font_size_in_pt, align=Align));
path[]  SI = texpath(Label("\texttt{\bfseries SI}", font_size_in_pt, align=Align));
path[]  BL = texpath(Label("\texttt{\bfseries\underline{BL}}", font_size_in_pt, align=Align));
path[]  KI = texpath(Label("\texttt{\bfseries\underline{KI}}", font_size_in_pt, align=Align));
path[]  PC = texpath(Label("\texttt{\bfseries PC}", font_size_in_pt, align=Align));
path[]  TE = texpath(Label("\texttt{\bfseries TE}", font_size_in_pt, align=Align));
path[]  GB = texpath(Label("\texttt{\bfseries\underline{GB}}", font_size_in_pt, align=Align));
path[]  LR = texpath(Label("\texttt{\bfseries\underline{LR}}", font_size_in_pt, align=Align));


LU = shift(lu) * LU;
LI = shift(li) * LI;
ST = shift(st) * ST;
SP = shift(sp) * SP;
HT = shift(ht) * HT;
SI = shift(si) * SI;
BL = shift(bl) * BL;
KI = shift(ki) * KI;
PC = shift(pc) * PC;
TE = shift(te) * TE;
GB = shift(gb) * GB;
LR = shift(lr) * LR;


/*
 * draw now...
 */

draw(BIG_E, pen_e);

// left side
fill(LU, pen_yin);
fill(SP, pen_yin);
fill(HT, pen_yin);
fill(KI, pen_yin);
fill(PC, pen_yin);
fill(LR, pen_yin);

// right side
draw(LI, pen_yang);
draw(ST, pen_yang);
draw(SI, pen_yang);
draw(BL, pen_yang);
draw(TE, pen_yang);
draw(GB, pen_yang);

// 3 yin & 3 yang
pair shift1 = (20, 16);
pair shift2 = (20, 16);
label("太陰", sp + shift1, pen_text);
label("少陰", ki + shift1, pen_text);
label("厥陰", lr + shift1, pen_text);
label("陽明", st + shift2, pen_text);
label("太陽", bl + shift2, pen_text);
label("少陽", gb + shift2, pen_text);
