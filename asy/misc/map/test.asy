/* created(bruin, 2008-05-16): library for drawing maps.
   $Id$
 */
 
import "map.asy" as map;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs,bm}
             \usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             %\newcommand{\myfrac}[2]{#1\!/\!#2}
             %\newcommand{\cwave}{бл}
             \newcommand{\song}{\CJKfamily{song}}
             \newcommand{\fs}{\CJKfamily{fs}}
             \newcommand{\hei}{\CJKfamily{hei}}
             \newcommand{\kai}{\CJKfamily{kai}}
             \AtBeginDocument{\begin{CJK*}{GBK}{hei}}
             \AtEndDocument{\clearpage\end{CJK*}}"
            );

include "water.dat";
include "roads.dat";

size(10000, 0, true);
//unitsize(0, 0);







triple cam = 10*EARTH_RADIUS*mydir(40, 116.3);
currentprojection=orthographic(cam); 


  
draw_track(track_tongzihe_w, 50, false, RIVER);
draw_track(track_tongzihe_s, 50, false, RIVER);
draw_track(track_tongzihe_e, 50, false, RIVER);
draw_track(track_tongzihe_n, 50, false, RIVER);

draw_track(track_kunming_lake1, 0, true, LAKE);


draw_track(track_ring2, 25, true, URBAN_EXPRESS);
draw_track(track_ring3, 25, true, URBAN_EXPRESS);
draw_track(track_ring4, 30, true, URBAN_EXPRESS);
draw_track(track_ring5, 30, true, URBAN_EXPRESS);

draw_track(track_badaling, 35, false, EXPRESSWAY);
