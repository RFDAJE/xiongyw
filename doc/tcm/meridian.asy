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

pen pen_e = linewidth(400) + black + linecap(2);
pen pen_yin = linewidth(1) + black;
pen pen_yang = linewidth(1) + red;
pen pen_text = fontsize(240) + lightgrey;

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
pair up = (0, 10), down = (0, -20);
pair left1 = (-5, 0), left2 = (-50, 0);
pair lu = (0, 200) + up + left1,   li = (150, 200) + up + left2,
     sp = (0, 200) + down + left1, st = (150, 200) + down + left2,
     ht = (0, 100) + up + left1,   si = (150, 100) + up + left2,
     ki = (0, 100) + down + left1, bl = (150, 100) + down + left2,
     pc = (0,   0) + up + left1,   te = (150,   0) + up + left2,
     lr = (0,   0) + down + left1, gb = (150,   0) + down + left2;


/* 
 * text outline: http://tex.stackexchange.com/questions/21548/outlining-filling-glyph-outline-with-text-in-tikz
 */

path[]  LU = texpath(Label("平旦 \texttt{\bfseries LU}", font_size_in_pt, align=Align));
path[]  LI = texpath(Label("日出 \texttt{\bfseries LI}", font_size_in_pt, align=Align));
path[]  ST = texpath(Label("食時 \texttt{\bfseries ST}", font_size_in_pt, align=Align));
path[]  SP = texpath(Label("隅中 \texttt{\bfseries SP}", font_size_in_pt, align=Align));
path[]  HT = texpath(Label("日中 \texttt{\bfseries HT}", font_size_in_pt, align=Align));
path[]  SI = texpath(Label("日昳 \texttt{\bfseries SI}", font_size_in_pt, align=Align));
path[]  BL = texpath(Label("晡時 \texttt{\bfseries BL}", font_size_in_pt, align=Align));
path[]  KI = texpath(Label("日入 \texttt{\bfseries KI}", font_size_in_pt, align=Align));
path[]  PC = texpath(Label("黄昏 \texttt{\bfseries PC}", font_size_in_pt, align=Align));
path[]  TE = texpath(Label("人定 \texttt{\bfseries TE}", font_size_in_pt, align=Align));
path[]  GB = texpath(Label("夜半 \texttt{\bfseries GB}", font_size_in_pt, align=Align));
path[]  LR = texpath(Label("雞鳴 \texttt{\bfseries LR}", font_size_in_pt, align=Align));
//path[]  LR = texpath(Label("雞鳴 \texttt{\bfseries\underline{LR}}", font_size_in_pt, align=Align));


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
/*
draw(LI, pen_yang);
draw(ST, pen_yang);
draw(SI, pen_yang);
draw(BL, pen_yang);
draw(TE, pen_yang);
draw(GB, pen_yang);
*/
fill(LI, pen_yang);
fill(ST, pen_yang);
fill(SI, pen_yang);
fill(BL, pen_yang);
fill(TE, pen_yang);
fill(GB, pen_yang);

// 3 yin & 3 yang
pair shift1 = (30, 20);
pair shift2 = (30, 20);
label("太陰", sp + shift1, pen_text);
label("少陰", ki + shift1, pen_text);
label("厥陰", lr + shift1, pen_text);
label("陽明", st + shift2, pen_text);
label("太陽", bl + shift2, pen_text);
label("少陽", gb + shift2, pen_text);
