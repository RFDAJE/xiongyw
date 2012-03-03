

import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
 

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");  /* 若使用汉子，文本要用 utf8 编码--xelatex要求 */
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}"); 
/* texpreamble("\setmonofont[Path=../fonts/]{monaco.ttf}"); */



node root   = node("root", "d");
node kid1 = node("kid1", "d");
node kid2 = node("kiiid2", "d");
node kid3 = node("kiddd3", "d");
node kid4 = node("kkid4", "d");
root.attach(kid1, kid2);
root.attach(kid3, kid4);

node kid11 = node("kkid11", "d");
node kid12 = node("kiiid12", "d");
node kid13 = node("kidddd13", "d");

node kid21 = node("kid21", "d");
node kid22 = node("kid22", "d");

node kid31 = node("kidddd31", "d");

kid1.attach(kid11, kid12, kid13);
kid2.attach(kid21, kid22);
kid3.attach(kid31);

node kid311 = node("kid311", "d");
node kid312 = node("kid312", "d");
kid31.attach(kid311, kid312);




picture root = draw_call_sequence(root);
attach(bbox(root, 2, 2, white), (0,0), SE);
