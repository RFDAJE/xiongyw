/* 
 * created(bruin, 2008-11-09): LinuxXine Directory structure
 *
 * $Id$
 */
import fontsize;
import "node.asy" as node;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             %\usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             %\newcommand{\myfrac}[2]{#1\!/\!#2}
             %\newcommand{\cwave}{бл}
             %\newcommand{\song}{\CJKfamily{song}}
             %\newcommand{\fs}{\CJKfamily{fs}}
             %\newcommand{\hei}{\CJKfamily{hei}}
             %\newcommand{\kai}{\CJKfamily{kai}}
             %\AtBeginDocument{\begin{CJK*}{GBK}{hei}}
             %\AtEndDocument{\clearpage\end{CJK*}}"
            );

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
node file_etc                    = node("$\cdots$", "f");

node N09478008 = node("dirtree", "d")
node N09480050 = node("tree.h", "f")
N09478008.attach(N09480050)
node N09480078 = node("dirtree.c", "f")
N09478008.attach(N09480078)
node N094800a0 = node("a.out", "f")
N09478008.attach(N094800a0)
node N094800c8 = node("tree.c", "f")
N09478008.attach(N094800c8)
node N094800f0 = node("dirtree.o", "f")
N09478008.attach(N094800f0)
node N09480118 = node("tree.o", "f")
N09478008.attach(N09480118)
                      
                      
/********* draw the root tree *******/                             
picture root = draw_tree(N09478008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
shipout("dirtree.eps");
erase(currentpicture);



