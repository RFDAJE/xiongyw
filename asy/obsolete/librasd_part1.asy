
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



node N093c4008 = node("libra_sd.old", "d");
node N093cc058 = node("tools", "d");
node N093d40a0 = node("create_flash_bin", "d");
node N093dc0f0 = node("src", "d");
N093d40a0.attach(N093dc0f0);
N093cc058.attach(N093d40a0);
node N093d40d0 = node("resource_generator", "d");
node N093d4100 = node("Cygwin_GCC", "d");
node N093d4128 = node("src", "d");
N093d4100.attach(N093d4128);
N093d40d0.attach(N093d4100);
node N093d4150 = node("src", "d");
N093d40d0.attach(N093d4150);
N093cc058.attach(N093d40d0);
node N093d4178 = node("new_bmp", "d");
node N093d41a0 = node("256", "d");
N093d4178.attach(N093d41a0);
N093cc058.attach(N093d4178);
N093c4008.attach(N093cc058);
node N093d41c8 = node("boards", "d");
N093c4008.attach(N093d41c8);
node N093d41f0 = node("middleware", "d");
node N093d4218 = node("terminal", "d");
node N093d4240 = node("console", "d");
node N093d4268 = node("test", "d");
N093d4240.attach(N093d4268);
N093d4218.attach(N093d4240);
node N093d4290 = node("log", "d");
N093d4218.attach(N093d4290);
N093d41f0.attach(N093d4218);
node N093d42b8 = node("utility", "d");
node N093d42e0 = node("sts_update", "d");
node N093d4308 = node("ui", "d");
N093d42e0.attach(N093d4308);
node N093d4330 = node("dummy", "d");
N093d42e0.attach(N093d4330);
N093d42b8.attach(N093d42e0);
node N093d4358 = node("robot", "d");
N093d42b8.attach(N093d4358);
node N093d4380 = node("sys_config", "d");
node N093d43a8 = node("ui", "d");
N093d4380.attach(N093d43a8);
node N093d43d0 = node("dummy", "d");
N093d4380.attach(N093d43d0);
N093d42b8.attach(N093d4380);
N093d41f0.attach(N093d42b8);
node N093d43f8 = node("facility", "d");
node N093d4420 = node("frontend", "d");
N093d43f8.attach(N093d4420);
node N093d4448 = node("transfer", "d");
N093d43f8.attach(N093d4448);
node N093d4470 = node("interface", "d");
N093d43f8.attach(N093d4470);
node N093d4498 = node("nvram", "d");
N093d43f8.attach(N093d4498);
N093d41f0.attach(N093d43f8);
node N093d44c0 = node("misc", "d");
node N093d44e8 = node("jpeg", "d");
N093d44c0.attach(N093d44e8);
node N093d4510 = node("gif", "d");
N093d44c0.attach(N093d4510);
N093d41f0.attach(N093d44c0);
node N093d4538 = node("media", "d");
node N093d4560 = node("pvrplayer", "d");
N093d4538.attach(N093d4560);
node N093d4588 = node("mplayer", "d");
node N093d45b0 = node("stream", "d");
node N093d45d8 = node("librtsp", "d");
N093d45b0.attach(N093d45d8);
node N093d4600 = node("freesdp", "d");
N093d45b0.attach(N093d4600);
node N093d4628 = node("realrtsp", "d");
N093d45b0.attach(N093d4628);
N093d4588.attach(N093d45b0);
node N093d4650 = node("libmenu", "d");
N093d4588.attach(N093d4650);
node N093d4678 = node("libvo", "d");
N093d4588.attach(N093d4678);
node N093d46a0 = node("osdep", "d");
N093d4588.attach(N093d46a0);
node N093d46c8 = node("sub", "d");
N093d4588.attach(N093d46c8);
node N093d46f0 = node("libmpcodecs", "d");
N093d4588.attach(N093d46f0);
node N093d4718 = node("libmpdemux", "d");
N093d4588.attach(N093d4718);
node N093d4740 = node("input", "d");
N093d4588.attach(N093d4740);
node N093d4768 = node("libass", "d");
N093d4588.attach(N093d4768);
node N093d4790 = node("libao2", "d");
N093d4588.attach(N093d4790);
node N093d47b8 = node("libaf", "d");
N093d4588.attach(N093d47b8);
N093d4538.attach(N093d4588);
node N093d47e0 = node("mediaplayer", "d");
N093d4538.attach(N093d47e0);
N093d41f0.attach(N093d4538);
node N093d4808 = node("include", "d");
node N093d4830 = node("terminal", "d");
N093d4808.attach(N093d4830);
node N093d4858 = node("utility", "d");
N093d4808.attach(N093d4858);
node N093d4880 = node("service", "d");
N093d4808.attach(N093d4880);
node N093d48a8 = node("facility", "d");
node N093d48d0 = node("gui", "d");
node N093d48f8 = node("win", "d");
N093d48d0.attach(N093d48f8);
node N093d4920 = node("gfx", "d");
N093d48d0.attach(N093d4920);
node N093d4948 = node("control", "d");
N093d48d0.attach(N093d4948);
node N093d4970 = node("common", "d");
N093d48d0.attach(N093d4970);
N093d48a8.attach(N093d48d0);
N093d4808.attach(N093d48a8);
node N093d4998 = node("misc", "d");
N093d4808.attach(N093d4998);
node N093d49c0 = node("librawidget", "d");
N093d4808.attach(N093d49c0);
node N093d49e8 = node("monitor", "d");
N093d4808.attach(N093d49e8);
node N093d4a10 = node("manager", "d");
N093d4808.attach(N093d4a10);
node N093d4a38 = node("oc", "d");
N093d4808.attach(N093d4a38);
node N093d4a60 = node("dvb", "d");
N093d4808.attach(N093d4a60);
N093d41f0.attach(N093d4808);
node N093d4a88 = node("librawidget", "d");
N093d41f0.attach(N093d4a88);
node N093d4ab0 = node("monitor", "d");
N093d41f0.attach(N093d4ab0);
node N093d4ad8 = node("thirdpart", "d");
node N093d4b00 = node("cas", "d");
node N093d4b28 = node("kingvon", "d");
node N093d4b50 = node("include", "d");
N093d4b28.attach(N093d4b50);
node N093d4b78 = node("src", "d");
N093d4b28.attach(N093d4b78);
node N093d4ba0 = node("lib", "d");
N093d4b28.attach(N093d4ba0);
N093d4b00.attach(N093d4b28);
node N093d4bc8 = node("cdm", "d");
N093d4b00.attach(N093d4bc8);
N093d4ad8.attach(N093d4b00);
node N093d4bf0 = node("dbc", "d");
node N093d4c18 = node("cct", "d");
node N093d4c40 = node("ui", "d");
N093d4c18.attach(N093d4c40);
node N093d4c68 = node("include", "d");
node N093d4c90 = node("db_ui", "d");
N093d4c68.attach(N093d4c90);
N093d4c18.attach(N093d4c68);
N093d4bf0.attach(N093d4c18);
node N093d4cb8 = node("dummy", "d");
N093d4bf0.attach(N093d4cb8);
N093d4ad8.attach(N093d4bf0);
N093d41f0.attach(N093d4ad8);
node N093d4ce0 = node("dvb", "d");
node N093d4d08 = node("parser", "d");
N093d4ce0.attach(N093d4d08);
node N093d4d30 = node("service", "d");
node N093d4d58 = node("player", "d");
N093d4d30.attach(N093d4d58);
node N093d4d80 = node("hangup", "d");
N093d4d30.attach(N093d4d80);
node N093d4da8 = node("search", "d");
N093d4d30.attach(N093d4da8);
N093d4ce0.attach(N093d4d30);
node N093d4dd0 = node("manager", "d");
N093d4ce0.attach(N093d4dd0);
node N093d4df8 = node("database", "d");
N093d4ce0.attach(N093d4df8);
N093d41f0.attach(N093d4ce0);
N093c4008.attach(N093d41f0);
node N093d4e20 = node("code_style", "d");
N093c4008.attach(N093d4e20);
node N093d4e48 = node("include", "d");
node N093d4e70 = node("linux", "d");
N093d4e48.attach(N093d4e70);
node N093d4e98 = node("config", "d");
node N093d4ec0 = node("terminal", "d");
N093d4e98.attach(N093d4ec0);
node N093d4ee8 = node("app", "d");
node N093d4f10 = node("final", "d");
N093d4ee8.attach(N093d4f10);
N093d4e98.attach(N093d4ee8);
node N093d4f38 = node("cas", "d");
N093d4e98.attach(N093d4f38);
node N093d4f60 = node("dbc", "d");
N093d4e98.attach(N093d4f60);
node N093d4f88 = node("host", "d");
node N093d4fb0 = node("buildroot", "d");
N093d4f88.attach(N093d4fb0);
N093d4e98.attach(N093d4f88);
node N093d4fd8 = node("libra", "d");
node N093d5000 = node("os", "d");
N093d4fd8.attach(N093d5000);
N093d4e98.attach(N093d4fd8);
node N093d5028 = node("avl", "d");
node N093d5050 = node("cfg", "d");
node N093d5078 = node("agar", "d");
N093d5050.attach(N093d5078);
node N093d50a0 = node("flash", "d");
node N093d50c8 = node("size", "d");
node N093d50f0 = node("1m", "d");
N093d50c8.attach(N093d50f0);
N093d50a0.attach(N093d50c8);
node N093d5118 = node("head", "d");
node N093d5140 = node("download", "d");
node N093d5168 = node("time", "d");
node N093d5190 = node("date", "d");
N093d5168.attach(N093d5190);
N093d5140.attach(N093d5168);
N093d5118.attach(N093d5140);
N093d50a0.attach(N093d5118);
N093d5050.attach(N093d50a0);
node N093d51b8 = node("terminal", "d");
N093d5050.attach(N093d51b8);
node N093d51e0 = node("app", "d");
node N093d5208 = node("cct", "d");
node N093d5230 = node("solution", "d");
node N093d5258 = node("no", "d");
N093d5230.attach(N093d5258);
N093d5208.attach(N093d5230);
N093d51e0.attach(N093d5208);
N093d5050.attach(N093d51e0);
node N093d5280 = node("frontend", "d");
node N093d52a8 = node("lnb", "d");
node N093d52d0 = node("gpio", "d");
N093d52a8.attach(N093d52d0);
N093d5280.attach(N093d52a8);
N093d5050.attach(N093d5280);
node N093d52f8 = node("demod", "d");
node N093d5320 = node("high", "d");
node N093d5348 = node("lock", "d");
N093d5320.attach(N093d5348);
N093d52f8.attach(N093d5320);
N093d5050.attach(N093d52f8);
node N093d5370 = node("front", "d");
node N093d5398 = node("panel", "d");
N093d5370.attach(N093d5398);
N093d5050.attach(N093d5370);
node N093d53c0 = node("loader", "d");
node N093d53e8 = node("def", "d");
node N093d5410 = node("software", "d");
node N093d5438 = node("version", "d");
N093d5410.attach(N093d5438);
N093d53e8.attach(N093d5410);
node N093d5460 = node("hardware", "d");
node N093d5488 = node("id", "d");
N093d5460.attach(N093d5488);
N093d53e8.attach(N093d5460);
node N093d54b0 = node("loader", "d");
node N093d54d8 = node("version", "d");
N093d54b0.attach(N093d54d8);
N093d53e8.attach(N093d54b0);
node N093d5500 = node("manufacture", "d");
node N093d5528 = node("id", "d");
N093d5500.attach(N093d5528);
N093d53e8.attach(N093d5500);
node N093d5550 = node("stb", "d");
node N093d5578 = node("id", "d");
N093d5550.attach(N093d5578);
N093d53e8.attach(N093d5550);
node N093d55a0 = node("model", "d");
node N093d55c8 = node("id", "d");
N093d55a0.attach(N093d55c8);
N093d53e8.attach(N093d55a0);
N093d53c0.attach(N093d53e8);
N093d5050.attach(N093d53c0);
node N093d55f0 = node("tuner", "d");
N093d5050.attach(N093d55f0);
node N093d5618 = node("driver", "d");
node N093d5640 = node("frontend", "d");
N093d5618.attach(N093d5640);
N093d5050.attach(N093d5618);
node N093d5668 = node("left", "d");
node N093d5690 = node("circular", "d");
node N093d56b8 = node("output", "d");
N093d5690.attach(N093d56b8);
N093d5668.attach(N093d5690);
N093d5050.attach(N093d5668);
node N093d56e0 = node("serial", "d");
N093d5050.attach(N093d56e0);
node N093d5708 = node("tdx", "d");
node N093d5730 = node("signal", "d");
node N093d5758 = node("info", "d");
N093d5730.attach(N093d5758);
N093d5708.attach(N093d5730);
N093d5050.attach(N093d5708);
node N093d5780 = node("console", "d");
N093d5050.attach(N093d5780);
node N093d57a8 = node("factory", "d");
node N093d57d0 = node("reset", "d");
node N093d57f8 = node("default", "d");
N093d57d0.attach(N093d57f8);
N093d57a8.attach(N093d57d0);
N093d5050.attach(N093d57a8);
node N093d5820 = node("outside", "d");
N093d5050.attach(N093d5820);
node N093d5848 = node("debug", "d");
N093d5050.attach(N093d5848);
node N093d5870 = node("monitor", "d");
N093d5050.attach(N093d5870);
node N093d5898 = node("libra", "d");
N093d5050.attach(N093d5898);
node N093d58c0 = node("release", "d");
N093d5050.attach(N093d58c0);
node N093d58e8 = node("antares", "d");
node N093d5910 = node("frontend", "d");
node N093d5938 = node("driver", "d");
node N093d5960 = node("advbs", "d");
N093d5938.attach(N093d5960);
N093d5910.attach(N093d5938);
N093d58e8.attach(N093d5910);
N093d5050.attach(N093d58e8);
N093d5028.attach(N093d5050);
N093d4e98.attach(N093d5028);
node N093d5988 = node("platform", "d");
N093d4e98.attach(N093d5988);
node N093d59b0 = node("gui", "d");
node N093d59d8 = node("driver", "d");
N093d59b0.attach(N093d59d8);
node N093d5a00 = node("lib", "d");
node N093d5a28 = node("avl", "d");
N093d5a00.attach(N093d5a28);
N093d59b0.attach(N093d5a00);
N093d4e98.attach(N093d59b0);
N093d4e48.attach(N093d4e98);
node N093d5a50 = node("asm-x86", "d");
N093d4e48.attach(N093d5a50);
node N093d5a78 = node("asm", "d");
N093d4e48.attach(N093d5a78);
N093c4008.attach(N093d4e48);
node N093d5aa0 = node("boot_loader", "d");
N093c4008.attach(N093d5aa0);
node N093d5ac8 = node("doc", "d");
node N093d5af0 = node("images", "d");
N093d5ac8.attach(N093d5af0);
N093c4008.attach(N093d5ac8);
node N093d5b18 = node("lib", "d");
node N093d5b40 = node("third_party_libs", "d");
N093d5b18.attach(N093d5b40);
node N093d5b70 = node("gui", "d");
node N093d5b98 = node("avl_gui", "d");
node N093d5bc0 = node("win", "d");
N093d5b98.attach(N093d5bc0);
node N093d5be8 = node("driver", "d");
N093d5b98.attach(N093d5be8);
node N093d5c10 = node("control", "d");
node N093d5c38 = node("custom", "d");
N093d5c10.attach(N093d5c38);
N093d5b98.attach(N093d5c10);
node N093d5c60 = node("font", "d");
N093d5b98.attach(N093d5c60);
node N093d5c88 = node("common", "d");
N093d5b98.attach(N093d5c88);
N093d5b70.attach(N093d5b98);
node N093d5cb0 = node("font", "d");
N093d5b70.attach(N093d5cb0);
N093d5b18.attach(N093d5b70);
N093c4008.attach(N093d5b18);
node N093d5cd8 = node("bin", "d");
N093c4008.attach(N093d5cd8);
node N093d5d00 = node("main", "d");
N093c4008.attach(N093d5d00);
picture root = draw_tree(N093c4008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
