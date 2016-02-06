
settings.tex = "xelatex";
 
texpreamble("\usepackage{xeCJK}"); 
texpreamble("\setCJKmainfont{SimSun}"); 
 
unitsize(1mm);
 
/* B5 size: 182x257mm
   The binding holes are located on one side of the paper:
   - distance to the long side margin (from the center of the holes): 1/4 inch, i.e., 6.35mm
   - distance to the short side margin: 0mm
   - distance betw holes (center to center):  9.51852mm (totally 26 holes), ~ 3/8 inch
   - hole diameter: 3/16 inch. enlarge to 6mm
 */
real width = 182;
real height = 257;
real margin_left = 8;  // 
real margin_bott = 0;
real gap = 9.51852;
real radius = 3;

int nr_of_holes = 26;

int i;

/* stretch picture to b5 size */
draw((0,0)--(width, height), white+linewidth(0.01mm));
 
for(i = 0; i < nr_of_holes; ++ i){
	draw(circle((margin_left, margin_bott + gap * (i + 1)), radius), black+linewidth(0.1mm));
}
 
