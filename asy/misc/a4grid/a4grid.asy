/*
 * asy -noV -f pdf a4grid.asy
 */

settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}"); 
texpreamble("\setCJKmainfont{SimSun}"); 
 
unitsize(1mm);
 
/* A4 size (portrait layout): 210x297mm  */
real width = 210;
real height = 297;
/* left/right margin size */
real h_margin = 10; 
/* top/bottom margin size */
real v_margin = 13.5;
/* square grid size */
real space = 5;

pen grid_pen = grey + linewidth(0.25);
 
int i;

/* 
 * 1. use a white line to stretch the picture to A4 size 
 */
draw((0,0)--(width, height), white+linewidth(0.01mm));


/*
 * 2. draw the grid 
 */
 
/* rows: horizontal lines */
for(i = 0; i <= (height-2*v_margin)/space; ++i){
    draw((h_margin,i*space+v_margin)--(width-h_margin, i*space+v_margin), grid_pen);
}
 
/* columns: vertical lines */
for(i = 0; i <= (width-2*h_margin)/space; ++i){
    draw((i*space+h_margin, v_margin)--(i*space+h_margin, height-v_margin), grid_pen);
}
 

/*
 * 3. label in a black rectangle
 */ 
/* rectangle size */
real rect_width=20;
real rect_height=8;
/* upleft point of the rect */
pair upleft = (155, 13.42);
 
filldraw(upleft--(upleft.x,upleft.y-rect_height)--(upleft.x+rect_width,upleft.y-rect_height)--(upleft.x+rect_width, upleft.y)--cycle,black);
label(Label("\texttt{bruin}"), (upleft.x + 10, upleft.y - 4), white);
