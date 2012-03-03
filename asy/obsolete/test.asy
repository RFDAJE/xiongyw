settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}"); 
texpreamble("\setCJKmainfont{SimSun}"); 
 
unitsize(1mm);
 
/* A3 size: 420x297mm
     left/right margin: 10mm*2
  top/bottom margin: 10, 7mm
 */
real width = 420;
real height = 297;
real margin10 = 10;
real margin7 = 7;
real space = 5;
 
int i;
 
draw((0,0)--(width, height), white+linewidth(0.01mm));
 
/* rows */
for(i = 0; i <= 280/5; ++i){
    draw((margin10,i*space+margin7)--(width-margin10, i*space+margin7), grey+linewidth(0.1mm));
}
 
/* columns */
for(i = 0; i <= 400/5; ++i){
    draw((i*space+margin10, margin7)--(i*space+margin10, height-margin10), grey+linewidth(0.1mm));
}
 
/* center line */
/* draw((width/2, 0)--(width/2, height), black+linewidth(0.5mm)); */
 
 
 
pair lowleft1 = (10, 227);
pair lowleft2 = (395, 227);
real rect_width=15;
real rect_height=25;
 
/*
filldraw(lowleft1--(lowleft1.x,lowleft1.y+rect_height)--(lowleft1.x+rect_width,lowleft1.y+rect_height)--(lowleft1.x+rect_width, lowleft1.y)--cycle,black);
label(Label(rotate(-90)*scale(1.2)*"\texttt{bruin}"), (22,240), white);
*/
 
filldraw(lowleft2--(lowleft2.x,lowleft2.y+rect_height)--(lowleft2.x+rect_width,lowleft2.y+rect_height)--(lowleft2.x+rect_width, lowleft2.y)--cycle,black);
label(Label(rotate(90)*scale(1.2)*"\texttt{bruin}"), (398,240), white);
