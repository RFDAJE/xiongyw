/*
 * created(bruin, 2015-01-06)
 *
 */

settings.tex = "xelatex";

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{arialuni.ttf}");
/* 
 * treat the following also as CJK
 *
 * http://www.unicode.org/charts/PDF/U2460.pdf: Enclosed Alphanumerics
 * http://www.unicode.org/charts/PDF/U2600.pdf: Miscellaneous Symbols
 * http://www.unicode.org/charts/PDF/U2700.pdf: Dingbats
 */
texpreamble("\xeCJKsetcharclass{\"2460}{\"27BF}{1}");


import math;
import fontsize;
import "../../asy/misc.asy" as misc;


circular_annotate(currentpicture, 100, 150, 
                  new string[]{"木", "火", "土", "金", "水"}, 
//                  new string[]{" ", " ", " ", " ", " "}, 
                  angular_shift=0, 
                  bend_text=false,
                  draw_r1=true, 
                  draw_r2=true, 
                  draw_delim=true,
                  text_colors=array(5, black),
                  fill_colors=new pen[]{lightgreen, lightred, white, lightyellow, lightgray});

//circular_annotate(1.5, 2.0, new string[]{"甘", "苦", "酸", "辛", "苦", "咸", "辛", "甘", "咸", "酸"}, draw_r1=true, draw_r2=true, draw_delim=true);
