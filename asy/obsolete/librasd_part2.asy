
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


node N08c11008 = node("libra_sd.old--continued", "d");
node N08c19050 = node("scripts", "d");
node N08c21098 = node("ksymoops", "d");
N08c19050.attach(N08c21098);
node N08c210c0 = node("mod", "d");
N08c19050.attach(N08c210c0);
node N08c210e8 = node("genksyms", "d");
N08c19050.attach(N08c210e8);
node N08c21110 = node("basic", "d");
N08c19050.attach(N08c21110);
node N08c21138 = node("selinux", "d");
node N08c29180 = node("mdp", "d");
N08c21138.attach(N08c29180);
N08c19050.attach(N08c21138);
node N08c21160 = node("rt-tester", "d");
N08c19050.attach(N08c21160);
node N08c21188 = node("package", "d");
N08c19050.attach(N08c21188);
node N08c211b0 = node("kconfig", "d");
node N08c211d8 = node("lxdialog", "d");
N08c211b0.attach(N08c211d8);
N08c19050.attach(N08c211b0);
node N08c21200 = node("tracing", "d");
N08c19050.attach(N08c21200);
node N08c21228 = node("dtc", "d");
node N08c21250 = node("libfdt", "d");
N08c21228.attach(N08c21250);
N08c19050.attach(N08c21228);
N08c11008.attach(N08c19050);
node N08c21278 = node("application", "d");
node N08c212a0 = node("libra_hdtv", "d");
node N08c212c8 = node("misc", "d");
N08c212a0.attach(N08c212c8);
node N08c212f0 = node("include", "d");
N08c212a0.attach(N08c212f0);
node N08c21318 = node("res", "d");
node N08c21340 = node("image", "d");
node N08c21368 = node("setting", "d");
N08c21340.attach(N08c21368);
node N08c21390 = node("guide", "d");
N08c21340.attach(N08c21390);
node N08c213b8 = node("menu", "d");
node N08c213e0 = node("main_icons", "d");
N08c213b8.attach(N08c213e0);
N08c21340.attach(N08c213b8);
node N08c21408 = node("search", "d");
N08c21340.attach(N08c21408);
node N08c21430 = node("tvscreen", "d");
node N08c21458 = node("email", "d");
N08c21430.attach(N08c21458);
node N08c21480 = node("IDNO", "d");
N08c21430.attach(N08c21480);
node N08c214a8 = node("information", "d");
node N08c214d0 = node("icons", "d");
N08c214a8.attach(N08c214d0);
N08c21430.attach(N08c214a8);
node N08c214f8 = node("volume", "d");
N08c21430.attach(N08c214f8);
N08c21340.attach(N08c21430);
N08c21318.attach(N08c21340);
node N08c21520 = node("font", "d");
N08c21318.attach(N08c21520);
N08c212a0.attach(N08c21318);
node N08c21548 = node("main", "d");
N08c212a0.attach(N08c21548);
node N08c21570 = node("epg", "d");
N08c212a0.attach(N08c21570);
N08c21278.attach(N08c212a0);
node N08c21598 = node("dummy", "d");
node N08c215c0 = node("include", "d");
N08c21598.attach(N08c215c0);
N08c21278.attach(N08c21598);
node N08c215e8 = node("agar_test", "d");
node N08c21610 = node("include", "d");
N08c215e8.attach(N08c21610);
node N08c21638 = node("res", "d");
node N08c21660 = node("image", "d");
N08c21638.attach(N08c21660);
N08c215e8.attach(N08c21638);
N08c21278.attach(N08c215e8);
N08c11008.attach(N08c21278);
node N08c21688 = node("build", "d");
node N08c216b0 = node("scripts", "d");
node N08c216d8 = node("ksymoops", "d");
N08c216b0.attach(N08c216d8);
node N08c21700 = node("mod", "d");
N08c216b0.attach(N08c21700);
node N08c21728 = node("genksyms", "d");
N08c216b0.attach(N08c21728);
node N08c21750 = node("basic", "d");
N08c216b0.attach(N08c21750);
node N08c21778 = node("selinux", "d");
node N08c217a0 = node("mdp", "d");
N08c21778.attach(N08c217a0);
N08c216b0.attach(N08c21778);
node N08c217c8 = node("rt-tester", "d");
N08c216b0.attach(N08c217c8);
node N08c217f0 = node("package", "d");
N08c216b0.attach(N08c217f0);
node N08c21818 = node("kconfig", "d");
node N08c21840 = node("lxdialog", "d");
N08c21818.attach(N08c21840);
N08c216b0.attach(N08c21818);
node N08c21868 = node("tracing", "d");
N08c216b0.attach(N08c21868);
node N08c21890 = node("dtc", "d");
node N08c218b8 = node("libfdt", "d");
N08c21890.attach(N08c218b8);
N08c216b0.attach(N08c21890);
N08c21688.attach(N08c216b0);
node N08c218e0 = node("market", "d");
N08c21688.attach(N08c218e0);
node N08c21908 = node("lib", "d");
N08c21688.attach(N08c21908);
node N08c21930 = node("bin", "d");
N08c21688.attach(N08c21930);
N08c11008.attach(N08c21688);
node N08c21958 = node("bsp", "d");
node N08c21980 = node("peripherals", "d");
node N08c219a8 = node("flash", "d");
N08c21980.attach(N08c219a8);
node N08c219d0 = node("demod", "d");
node N08c219f8 = node("pc_sim", "d");
N08c219d0.attach(N08c219f8);
node N08c21a20 = node("avl_dvbs_plus", "d");
N08c219d0.attach(N08c21a20);
node N08c21a50 = node("avl3106", "d");
N08c219d0.attach(N08c21a50);
node N08c21a78 = node("avl1108", "d");
N08c219d0.attach(N08c21a78);
node N08c21aa0 = node("dummy", "d");
N08c219d0.attach(N08c21aa0);
node N08c21ac8 = node("avl1118", "d");
node N08c21af0 = node("src", "d");
N08c21ac8.attach(N08c21af0);
node N08c21b18 = node("patch_builder", "d");
node N08c21b48 = node("GenPatchHeaderFile", "d");
node N08c21b78 = node("GenPatchHeaderFile", "d");
N08c21b48.attach(N08c21b78);
N08c21b18.attach(N08c21b48);
N08c21ac8.attach(N08c21b18);
node N08c21ba8 = node("bsp", "d");
node N08c21bd0 = node("aardvark.net", "d");
N08c21ba8.attach(N08c21bd0);
node N08c21c00 = node("SoC", "d");
N08c21ba8.attach(N08c21c00);
N08c21ac8.attach(N08c21ba8);
N08c219d0.attach(N08c21ac8);
N08c21980.attach(N08c219d0);
node N08c21c28 = node("tuner", "d");
node N08c21c50 = node("RDA5810", "d");
N08c21c28.attach(N08c21c50);
node N08c21c78 = node("Sharp", "d");
N08c21c28.attach(N08c21c78);
node N08c21ca0 = node("RDA5812", "d");
N08c21c28.attach(N08c21ca0);
node N08c21cc8 = node("AV2020", "d");
N08c21c28.attach(N08c21cc8);
node N08c21cf0 = node("MAX2119", "d");
N08c21c28.attach(N08c21cf0);
node N08c21d18 = node("SharpT2093", "d");
N08c21c28.attach(N08c21d18);
node N08c21d40 = node("RDA5812_Lowgain", "d");
N08c21c28.attach(N08c21d40);
node N08c21d70 = node("SIS203", "d");
N08c21c28.attach(N08c21d70);
node N08c21d98 = node("CDT9FT225_70", "d");
N08c21c28.attach(N08c21d98);
node N08c21dc8 = node("SIS303", "d");
N08c21c28.attach(N08c21dc8);
node N08c21df0 = node("LW37", "d");
N08c21c28.attach(N08c21df0);
N08c21980.attach(N08c21c28);
node N08c21e18 = node("include", "d");
node N08c21e40 = node("flash", "d");
N08c21e18.attach(N08c21e40);
node N08c21e68 = node("demod", "d");
N08c21e18.attach(N08c21e68);
node N08c21e90 = node("tuner", "d");
N08c21e18.attach(N08c21e90);
node N08c21eb8 = node("front_panel", "d");
N08c21e18.attach(N08c21eb8);
N08c21980.attach(N08c21e18);
node N08c21ee0 = node("front_panel", "d");
N08c21980.attach(N08c21ee0);
N08c21958.attach(N08c21980);
node N08c21f08 = node("platform", "d");
node N08c21f30 = node("x86", "d");
node N08c21f58 = node("driver", "d");
node N08c21f80 = node("videoencoder", "d");
N08c21f58.attach(N08c21f80);
node N08c21fb0 = node("frontpanel", "d");
N08c21f58.attach(N08c21fb0);
node N08c21fd8 = node("gpio", "d");
N08c21f58.attach(N08c21fd8);
node N08c22000 = node("fp", "d");
N08c21f58.attach(N08c22000);
node N08c22028 = node("frontend", "d");
N08c21f58.attach(N08c22028);
node N08c22050 = node("mtd", "d");
N08c21f58.attach(N08c22050);
node N08c22078 = node("pvr", "d");
node N08c220a0 = node("vdec", "d");
N08c22078.attach(N08c220a0);
node N08c220c8 = node("cas", "d");
N08c22078.attach(N08c220c8);
node N08c220f0 = node("crypto", "d");
N08c22078.attach(N08c220f0);
node N08c22118 = node("ci_plus", "d");
N08c22078.attach(N08c22118);
node N08c22140 = node("adec", "d");
N08c22078.attach(N08c22140);
node N08c22168 = node("include", "d");
N08c22078.attach(N08c22168);
node N08c22190 = node("fs", "d");
N08c22078.attach(N08c22190);
node N08c221b8 = node("demux", "d");
N08c22078.attach(N08c221b8);
node N08c221e0 = node("prm", "d");
N08c22078.attach(N08c221e0);
N08c21f58.attach(N08c22078);
node N08c22208 = node("adec", "d");
N08c21f58.attach(N08c22208);
node N08c22230 = node("pcm", "d");
N08c21f58.attach(N08c22230);
node N08c22258 = node("vos", "d");
N08c21f58.attach(N08c22258);
node N08c22280 = node("viddecoder", "d");
N08c21f58.attach(N08c22280);
node N08c222a8 = node("demux", "d");
N08c21f58.attach(N08c222a8);
node N08c222d0 = node("osd", "d");
N08c21f58.attach(N08c222d0);
node N08c222f8 = node("ir", "d");
N08c21f58.attach(N08c222f8);
N08c21f30.attach(N08c21f58);
node N08c22320 = node("sys", "d");
node N08c22348 = node("utility", "d");
N08c22320.attach(N08c22348);
node N08c22370 = node("os", "d");
node N08c22398 = node("linux", "d");
N08c22370.attach(N08c22398);
node N08c223c0 = node("win32", "d");
N08c22370.attach(N08c223c0);
N08c22320.attach(N08c22370);
N08c21f30.attach(N08c22320);
N08c21f08.attach(N08c21f30);
node N08c223e8 = node("libra_sd", "d");
node N08c22410 = node("include", "d");
node N08c22438 = node("std", "d");
N08c22410.attach(N08c22438);
node N08c22460 = node("drivers", "d");
N08c22410.attach(N08c22460);
node N08c22488 = node("hal", "d");
N08c22410.attach(N08c22488);
node N08c224b0 = node("common", "d");
N08c22410.attach(N08c224b0);
node N08c224d8 = node("kernel", "d");
N08c22410.attach(N08c224d8);
N08c223e8.attach(N08c22410);
N08c21f08.attach(N08c223e8);
N08c21958.attach(N08c21f08);
N08c11008.attach(N08c21958);
picture root = draw_tree(N08c11008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
