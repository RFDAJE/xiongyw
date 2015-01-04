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

pen pen_e = linewidth(300) + black + linecap(1); // 0: square cap, 1: roundcap, 2: extendcap
pen pen_yin = linewidth(1) + black;
pen pen_yang = linewidth(1) + red;
pen pen_text = fontsize(240) + black;

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
path[]  BIG_E = (0,0)..(75,-20)..(150,0)^^(0,100)..(75,80)..(150,100)^^(0,200)..(75,180)..(150,200)^^(0,0)--(0,200);


/*
 * 各种坐标
 */
pair taiyin   = (0, 200);
pair shaoyin  = (0, 100);
pair jueyin   = (0, 0);
pair yangming = (150, 200);
pair taiyang  = (150, 100); 
pair shaoyang = (150, 0);

pair shouyin  = ( 10,   0);    // 手阴
pair zuyin    = ( 10, -30);    // 足阴
pair shouyang = (-50,   0);    // 手阳
pair zuyang   = (-50, -30);    // 足阳


pair lu = shouyin + taiyin;
pair li = shouyang + yangming;
pair st = zuyang + yangming;
pair sp = zuyin + taiyin;
pair ht = shouyin + shaoyin;
pair si = shouyang + taiyang;
pair bl = zuyang + taiyang;
pair ki = zuyin + shaoyin;
pair pc = shouyin + jueyin; 
pair te = shouyang + shaoyang;
pair gb = zuyang + shaoyang;
pair lr = zuyin + jueyin;


/* 
 * text outline: http://tex.stackexchange.com/questions/21548/outlining-filling-glyph-outline-with-text-in-tikz
 */

path[]  LU = texpath(Label("\texttt{\bfseries LU}", font_size_in_pt, align=Align));
path[]  LI = texpath(Label("\texttt{\bfseries LI}", font_size_in_pt, align=Align));
path[]  ST = texpath(Label("\texttt{\bfseries ST}", font_size_in_pt, align=Align));
path[]  SP = texpath(Label("\texttt{\bfseries SP}", font_size_in_pt, align=Align));
path[]  HT = texpath(Label("\texttt{\bfseries HT}", font_size_in_pt, align=Align));
path[]  SI = texpath(Label("\texttt{\bfseries SI}", font_size_in_pt, align=Align));
path[]  BL = texpath(Label("\texttt{\bfseries BL}", font_size_in_pt, align=Align));
path[]  KI = texpath(Label("\texttt{\bfseries KI}", font_size_in_pt, align=Align));
path[]  PC = texpath(Label("\texttt{\bfseries PC}", font_size_in_pt, align=Align));
path[]  TE = texpath(Label("\texttt{\bfseries TE}", font_size_in_pt, align=Align));
path[]  GB = texpath(Label("\texttt{\bfseries GB}", font_size_in_pt, align=Align));
path[]  LR = texpath(Label("\texttt{\bfseries LR}", font_size_in_pt, align=Align));
//path[]  LR = texpath(Label("\texttt{\bfseries\underline{LR}}", font_size_in_pt, align=Align));


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
pair shift1 = (-25, 0);
pair shift2 = (25, 0);
label("太陰濕土", taiyin + shift1, pen_text);
label("少陰君火", shaoyin + shift1, pen_text);
label("厥陰風木", jueyin + shift1, pen_text);
label("陽明燥金", yangming + shift2, pen_text);
label("太陽寒水", taiyang + shift2, pen_text);
label("少陽相火", shaoyang + shift2, pen_text);

