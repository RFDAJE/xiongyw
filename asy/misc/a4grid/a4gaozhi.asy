
settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}"); 
texpreamble("\setCJKmainfont{SimSun}"); 
 
unitsize(1mm);
 
/* A4 size: 210x297mm
     left margin: 20mm
     bottom margin: 30mm
	 char grid size: 8x8mm
	 line gap: 3mm
 */
real width = 210;
real height = 297;
real margin20 = 20;
real margin30 = 30;
real gridsize = 8;
real linegap = 3;
real err_width = 20; /* correction area */

/* total chars per page: 21*19=399 */
int rows = 21;
int cols = 19;

int i, j;
 
draw((0,0)--(width, height), white+linewidth(0.01mm));
 
/* grid */
for(i = 0; i < rows; ++i){
	real lineheight = gridsize + linegap;
	real linewidth = gridsize * cols;

    draw((margin20, margin30 + i * lineheight)--(margin20 + linewidth, margin30 + i * lineheight), black+linewidth(0.1mm));
	
	draw((margin20, margin30 + i * lineheight + gridsize)--(margin20 + linewidth, margin30 + i * lineheight + gridsize), black+linewidth(0.1mm));
	for(j = 1; j < cols; ++j){
	    draw((margin20 + j * gridsize, margin30 + i * lineheight)--(margin20 + j * gridsize, margin30 + i * lineheight + gridsize), black+linewidth(0.1mm));
    }
}
 
/* bounding box */
real boxwidth = gridsize * cols + err_width;
real boxheight = rows * (gridsize + linegap) - linegap;

draw((margin20, margin30)--(margin20, margin30 + boxheight)--(margin20+boxwidth, margin30+boxheight)--(margin20+boxwidth, margin30)--cycle, black+linewidth(0.4mm));


draw((margin20 + gridsize * cols, margin30)--(margin20 + gridsize * cols, margin30 + boxheight), black + linewidth(0.1mm)); 

label("$21\times19=399$", (40, 20));
label("五（4）班\hspace{5mm}熊开元", (40, 270));
label("第\hspace{8mm}/\hspace{8mm}页", (170, 270));


