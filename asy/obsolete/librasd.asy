

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

node N09308008 = node("librasd", "d");
node N09310050 = node("tools", "d");
N09308008.attach(N09310050);
node N09310078 = node("make", "d");
N09308008.attach(N09310078);
node N093100a0 = node("doc", "d");
N09308008.attach(N093100a0);
node N093100c8 = node("out", "d");
node N09318110 = node("app", "d");
node N09320158 = node("dummy", "d");
N09318110.attach(N09320158);
node N09320180 = node("main", "d");
N09318110.attach(N09320180);
N093100c8.attach(N09318110);
node N09318138 = node("mware", "d");
node N09318160 = node("terminal", "d");
node N09318188 = node("console", "d");
N09318160.attach(N09318188);
node N093181b0 = node("log", "d");
N09318160.attach(N093181b0);
N09318138.attach(N09318160);
node N093181d8 = node("utility", "d");
node N09318200 = node("sts_update", "d");
node N09318228 = node("dummy", "d");
N09318200.attach(N09318228);
N093181d8.attach(N09318200);
node N09318250 = node("sys_config", "d");
node N09318278 = node("dummy", "d");
N09318250.attach(N09318278);
N093181d8.attach(N09318250);
N09318138.attach(N093181d8);
node N093182a0 = node("facility", "d");
node N093182c8 = node("frontend", "d");
N093182a0.attach(N093182c8);
node N093182f0 = node("transfer", "d");
N093182a0.attach(N093182f0);
node N09318318 = node("interface", "d");
N093182a0.attach(N09318318);
node N09318340 = node("nvram", "d");
N093182a0.attach(N09318340);
N09318138.attach(N093182a0);
node N09318368 = node("misc", "d");
node N09318390 = node("gif", "d");
N09318368.attach(N09318390);
N09318138.attach(N09318368);
node N093183b8 = node("monitor", "d");
N09318138.attach(N093183b8);
node N093183e0 = node("thirdpart", "d");
node N09318408 = node("dbc", "d");
node N09318430 = node("dummy", "d");
N09318408.attach(N09318430);
N093183e0.attach(N09318408);
N09318138.attach(N093183e0);
node N09318458 = node("dvb", "d");
node N09318480 = node("parser", "d");
N09318458.attach(N09318480);
node N093184a8 = node("service", "d");
node N093184d0 = node("player", "d");
N093184a8.attach(N093184d0);
node N093184f8 = node("hangup", "d");
N093184a8.attach(N093184f8);
node N09318520 = node("search", "d");
N093184a8.attach(N09318520);
N09318458.attach(N093184a8);
node N09318548 = node("manager", "d");
N09318458.attach(N09318548);
node N09318570 = node("database", "d");
N09318458.attach(N09318570);
N09318138.attach(N09318458);
N093100c8.attach(N09318138);
node N09318598 = node("bsp", "d");
node N093185c0 = node("peripherals", "d");
node N093185e8 = node("demod", "d");
node N09318610 = node("avl_dvbs_plus", "d");
N093185e8.attach(N09318610);
N093185c0.attach(N093185e8);
node N09318640 = node("tuner", "d");
node N09318668 = node("Sharp", "d");
N09318640.attach(N09318668);
N093185c0.attach(N09318640);
N09318598.attach(N093185c0);
N093100c8.attach(N09318598);
N09308008.attach(N093100c8);
node N09318690 = node("src", "d");
node N093186b8 = node("app", "d");
node N093186e0 = node("include", "d");
N093186b8.attach(N093186e0);
node N09318708 = node("dummy", "d");
N093186b8.attach(N09318708);
node N09318730 = node("main", "d");
N093186b8.attach(N09318730);
N09318690.attach(N093186b8);
node N09318758 = node("include", "d");
N09318690.attach(N09318758);
node N09318780 = node("thirdparty", "d");
N09318690.attach(N09318780);
node N093187a8 = node("mware", "d");
node N093187d0 = node("terminal", "d");
node N093187f8 = node("console", "d");
node N09318820 = node("test", "d");
N093187f8.attach(N09318820);
N093187d0.attach(N093187f8);
node N09318848 = node("log", "d");
N093187d0.attach(N09318848);
N093187a8.attach(N093187d0);
node N09318870 = node("utility", "d");
node N09318898 = node("sts_update", "d");
node N093188c0 = node("dummy", "d");
N09318898.attach(N093188c0);
N09318870.attach(N09318898);
node N093188e8 = node("sys_config", "d");
node N09318910 = node("dummy", "d");
N093188e8.attach(N09318910);
N09318870.attach(N093188e8);
N093187a8.attach(N09318870);
node N09318938 = node("facility", "d");
node N09318960 = node("frontend", "d");
N09318938.attach(N09318960);
node N09318988 = node("transfer", "d");
N09318938.attach(N09318988);
node N093189b0 = node("interface", "d");
N09318938.attach(N093189b0);
node N093189d8 = node("nvram", "d");
N09318938.attach(N093189d8);
N093187a8.attach(N09318938);
node N09318a00 = node("misc", "d");
node N09318a28 = node("jpeg", "d");
N09318a00.attach(N09318a28);
node N09318a50 = node("gif", "d");
N09318a00.attach(N09318a50);
N093187a8.attach(N09318a00);
node N09318a78 = node("include", "d");
node N09318aa0 = node("terminal", "d");
N09318a78.attach(N09318aa0);
node N09318ac8 = node("utility", "d");
N09318a78.attach(N09318ac8);
node N09318af0 = node("service", "d");
N09318a78.attach(N09318af0);
node N09318b18 = node("facility", "d");
node N09318b40 = node("gui", "d");
node N09318b68 = node("win", "d");
N09318b40.attach(N09318b68);
node N09318b90 = node("gfx", "d");
N09318b40.attach(N09318b90);
node N09318bb8 = node("control", "d");
N09318b40.attach(N09318bb8);
node N09318be0 = node("common", "d");
N09318b40.attach(N09318be0);
N09318b18.attach(N09318b40);
N09318a78.attach(N09318b18);
node N09318c08 = node("misc", "d");
N09318a78.attach(N09318c08);
node N09318c30 = node("librawidget", "d");
N09318a78.attach(N09318c30);
node N09318c58 = node("monitor", "d");
N09318a78.attach(N09318c58);
node N09318c80 = node("manager", "d");
N09318a78.attach(N09318c80);
node N09318ca8 = node("oc", "d");
N09318a78.attach(N09318ca8);
node N09318cd0 = node("dvb", "d");
N09318a78.attach(N09318cd0);
N093187a8.attach(N09318a78);
node N09318cf8 = node("monitor", "d");
N093187a8.attach(N09318cf8);
node N09318d20 = node("thirdpart", "d");
node N09318d48 = node("dbc", "d");
node N09318d70 = node("dummy", "d");
N09318d48.attach(N09318d70);
N09318d20.attach(N09318d48);
N093187a8.attach(N09318d20);
node N09318d98 = node("dvb", "d");
node N09318dc0 = node("parser", "d");
N09318d98.attach(N09318dc0);
node N09318de8 = node("service", "d");
node N09318e10 = node("player", "d");
N09318de8.attach(N09318e10);
node N09318e38 = node("hangup", "d");
N09318de8.attach(N09318e38);
node N09318e60 = node("search", "d");
N09318de8.attach(N09318e60);
N09318d98.attach(N09318de8);
node N09318e88 = node("manager", "d");
N09318d98.attach(N09318e88);
node N09318eb0 = node("database", "d");
N09318d98.attach(N09318eb0);
N093187a8.attach(N09318d98);
N09318690.attach(N093187a8);
node N09318ed8 = node("bsp", "d");
node N09318f00 = node("peripherals", "d");
node N09318f28 = node("demod", "d");
node N09318f50 = node("avl_dvbs_plus", "d");
N09318f28.attach(N09318f50);
N09318f00.attach(N09318f28);
node N09318f80 = node("tuner", "d");
node N09318fa8 = node("Sharp", "d");
N09318f80.attach(N09318fa8);
N09318f00.attach(N09318f80);
node N09318fd0 = node("include", "d");
node N09318ff8 = node("flash", "d");
N09318fd0.attach(N09318ff8);
node N09319020 = node("demod", "d");
N09318fd0.attach(N09319020);
node N09319048 = node("tuner", "d");
N09318fd0.attach(N09319048);
node N09319070 = node("front_panel", "d");
N09318fd0.attach(N09319070);
N09318f00.attach(N09318fd0);
N09318ed8.attach(N09318f00);
node N09319098 = node("platform", "d");
node N093190c0 = node("libs", "d");
N09319098.attach(N093190c0);
node N093190e8 = node("include", "d");
node N09319110 = node("arch", "d");
N093190e8.attach(N09319110);
node N09319138 = node("std", "d");
N093190e8.attach(N09319138);
node N09319160 = node("products", "d");
N093190e8.attach(N09319160);
node N09319188 = node("drivers", "d");
N093190e8.attach(N09319188);
node N093191b0 = node("common", "d");
N093190e8.attach(N093191b0);
node N093191d8 = node("kernel", "d");
N093190e8.attach(N093191d8);
N09319098.attach(N093190e8);
node N09319200 = node("ld-script", "d");
N09319098.attach(N09319200);
N09318ed8.attach(N09319098);
N09318690.attach(N09318ed8);
N09308008.attach(N09318690);
picture root = draw_tree(N09308008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
