/* created(bruin, 2007-02-01): illustrate 7-tone scale.
 *
 * $Id: scale7.asy 2 2007-03-22 12:54:39Z Administrator $
 */

import graph;
import fontsize;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             \usepackage{CJK}
             \usepackage{musixtex}    
             \newcommand{\song}{\CJKfamily{song}}
             \newcommand{\fs}{\CJKfamily{fs}}
             \newcommand{\hei}{\CJKfamily{hei}}
             \newcommand{\kai}{\CJKfamily{kai}}
             \AtBeginDocument{\begin{CJK*}{GBK}{hei}}
             \AtEndDocument{\clearpage\end{CJK*}}"
            );

unitsize(10);

real re=2, mi=4, fa=5, sol=7, la=9, si=11, do2=12;
real yscale=2.4;  // lower the picture height
real note_size = 7;
real cent_size = 5;
real name_below=1;
real cent_below=0.8;

/* steps */
draw((0,0)--(2,0));
draw((2,0)--(4,0)--(4,re/yscale)--(2,re/yscale)--cycle);
draw((4,0)--(6,0)--(6,mi/yscale)--(4,mi/yscale)--cycle);
draw((6,0)--(8,0)--(8,fa/yscale)--(6,fa/yscale)--cycle);
draw((8,0)--(10,0)--(10,sol/yscale)--(8,sol/yscale)--cycle);
draw((10,0)--(12,0)--(12,la/yscale)--(10,la/yscale)--cycle);
draw((12,0)--(14,0)--(14,si/yscale)--(12,si/yscale)--cycle);
draw((14,0)--(16,0)--(16,do2/yscale)--(14,do2/yscale)--cycle);

/* names */
label("do",  (1,-name_below),  N, fontsize(note_size));
label("re",  (3,-name_below),  N, fontsize(note_size));
label("mi",  (5,-name_below),  N, fontsize(note_size));
label("fa",  (7,-name_below),  N, fontsize(note_size));
label("sol", (9,-name_below),  N, fontsize(note_size));
label("la",  (11,-name_below), N, fontsize(note_size));
label("si",  (13,-name_below), N, fontsize(note_size));
label("do",  (15,-name_below), N, fontsize(note_size));

/* cent */
label("0" ,  (1, 0), N, fontsize(cent_size));
label("200", (3,re/yscale-cent_below), N, fontsize(cent_size));
label("400", (5,mi/yscale-cent_below), N, fontsize(cent_size));
label("500", (7,fa/yscale-cent_below), N, fontsize(cent_size));
label("700", (9,sol/yscale-cent_below), N, fontsize(cent_size));
label("900", (11,la/yscale-cent_below), N, fontsize(cent_size));
label("1100", (13,si/yscale-cent_below), N, fontsize(cent_size));
label("1200", (15,do2/yscale-cent_below), N, fontsize(cent_size));

/* staff 
picture staff;
label(staff, "\begin{music}
\generalmeter{}%\meterfrac{4}{4}}
\startextract\NOtes \sk\wh{cdefghij}\sk\enotes\endextract
\end{music}",(0,0));

*/
