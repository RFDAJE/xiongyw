
import fontsize;
import "node.asy" as node;

settings.tex = "xelatex";
 

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimSun}");


/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);




/* ################ directory tree ################ */

real   font_size = 10;      /* font size */

string dir = "d";
string file = "f";

/* 
 * sample node draw function to draw folder 
 * icon around directory names, as shown below:
 *
 *          _______
 *         /       \
 *        +------------------+
 *        |                  |
 *        | mydirectoryname  |
 *        |                  |
 *        +------------------+
 */
picture dir_draw_func(node p)
{
	picture pic;
	real mini_h = font_size; 
	real margin = 2 ; /* h & v margins */
  pair min, max;

  label(pic, "\texttt{"+p.text+"}");
  
  
   /* get the text dimension */
   min = min(pic);
   max = max(pic);
   
   /* make sure the height is at least min_h */
   if((max.y - min.y) < mini_h){
       real delta = (mini_h - (max.y - min.y)) / 2;
       max = (max.x, max.y + delta);
       min = (min.x, min.y - delta);
   }
   
   /* take margin into account */
   min -= (margin, margin);
   max += (margin, margin);
   
   /* draw the box */
   draw(pic, min--(min.x, max.y)--max--(max.x, min.y)--cycle,  p.priv == dir? defaultpen : invisible);

   /* draw the folder part */
   draw(pic, (min.x, max.y)--(min.x+2, max.y+2)--(min.x+8, max.y+2)--(min.x+10, max.y), p.priv == dir? defaultpen : invisible);

   return pic;
}


node dir_etc                     = node("$\cdots$", "d");
node file_etc                    = node("$\cdots$", "f");node N09cf6008 = node("../dirtree", "d");

node N0954e008 = node("mtos_v2", "d");
node N09556050 = node("products", "d");
node N0955e098 = node("librasd", "d");
N09556050.attach(N0955e098);
N0954e008.attach(N09556050);
node N09556078 = node("sys", "d");
node N095560a0 = node("arch", "d");
node N095560c8 = node("arm", "d");
node N095560f0 = node("arm926ejs", "d");
N095560c8.attach(N095560f0);
N095560a0.attach(N095560c8);
N09556078.attach(N095560a0);
node N09556118 = node("common", "d");
node N09556140 = node("wrapper", "d");
node N09556168 = node("mtos", "d");
N09556140.attach(N09556168);
N09556118.attach(N09556140);
node N09556190 = node("common", "d");
N09556118.attach(N09556190);
N09556078.attach(N09556118);
node N095561b8 = node("os", "d");
node N095561e0 = node("mtos_sd", "d");
node N09556208 = node("Ports", "d");
node N09556230 = node("ARM", "d");
node N09556258 = node("Generic", "d");
N09556230.attach(N09556258);
N09556208.attach(N09556230);
N095561e0.attach(N09556208);
node N09556280 = node("mem", "d");
N095561e0.attach(N09556280);
node N095562a8 = node("Source", "d");
N095561e0.attach(N095562a8);
N095561b8.attach(N095561e0);
N09556078.attach(N095561b8);
N0954e008.attach(N09556078);
picture root = draw_tree(N0954e008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);