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
                  new string[]{"酸", "辛", "苦", "鹹", "辛", "甘", "鹹", "酸", "甘", "苦"}, 
                  angular_shift=-360/20 * 7, 
                  bend_text=false,
                  draw_r1=true, 
                  draw_r2=true, 
                  draw_delim=true,
                  text_colors=array(10, black),
                  fill_colors=new pen[]{white, lightgreen, gray, lightred, lightgreen, 
                                       lightyellow, lightred, white, lightyellow, gray});

circular_annotate(currentpicture, 150, 200,
                  new string[]{"體\ 木\ 用", "體\ 火\ 用", "體\ 土\ 用", "體\ 金\ 用", "體\ 水\ 用"}, 
                  angular_shift=-360/20 * 6, 
                  bend_text=true,
                  draw_r1=true, 
                  draw_r2=true, 
                  draw_delim=true,
                  text_colors=array(5, black),
                  fill_colors=new pen[]{lightgreen, lightred, lightyellow, white, gray});

circular_annotate(currentpicture, 200, 250,
                  new string[]{"化甘", "痞", "化酸", "滯", "化苦", "燥", "化辛", "逆", "化鹹", "煩"}, 
                  angular_shift=-360/20 * 6, 
                  bend_text=false,
                  draw_r1=true, 
                  draw_r2=false, 
                  draw_delim=false);



circular_annotate(currentpicture, 240, 290,
                  new string[]{" ", "除", " ", "除", " ", "除", " ", "除", " ", "除"}, 
                  angular_shift=-360/20 * 6, 
                  bend_text=false,
                  draw_r1=false, 
                  draw_r2=false, 
                  draw_delim=false);

circular_annotate(currentpicture, 300, 350,
                  new string[]{"用陽進為補，其數七，火數也", "體陰退為瀉，其數六，水數也"}, 
                  angular_shift=-90, 
                  bend_text=true,
                  draw_r1=false, 
                  draw_r2=false, 
                  draw_delim=false);


draw(arc((0,0), 300, 270-45, 90+45, CW), arrow=Arrow);
draw(arc((0,0), 300, 270+45, 90-45, CCW), arrow=Arrow);
