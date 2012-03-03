
settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}"); 
texpreamble("\setCJKmainfont{SimSun}"); 
 
unitsize(1mm);
 
/* A4 size: 210x297mm
     left/right margin: 10mm*2
  top/bottom margin: 13.5mm*2
 */
real width = 210;
real height = 297;
real margin10 = 10;
real margin8 = 13.5;
real space = 5;
 
int i;
 
draw((0,0)--(width, height), white+linewidth(0.01mm));
 
/* rows */
for(i = 0; i <= 270/5; ++i){
    draw((margin10,i*space+margin8)--(width-margin10, i*space+margin8), grey+linewidth(0.1mm));
}
 
/* columns */
for(i = 0; i <= 190/5; ++i){
    draw((i*space+margin10, margin8)--(i*space+margin10, height-margin8), grey+linewidth(0.1mm));
}
 
 

pair lowleft2 = (155, 3.5);
real rect_width=20;
real rect_height=10;
 
 
filldraw(lowleft2--(lowleft2.x,lowleft2.y+rect_height)--(lowleft2.x+rect_width,lowleft2.y+rect_height)--(lowleft2.x+rect_width, lowleft2.y)--cycle,black);
label(Label("\texttt{bruin}"), (165,11), white);
