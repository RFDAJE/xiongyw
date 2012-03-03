import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");

node librasd = node("librasd", "d");
node make = node("make", "d");
node bootloader = node("bootloader", "d");
node N09cad0e0 = node("options.mak", "f");
bootloader.attach(N09cad0e0);
node N09cad138 = node("modules.mak", "f");
bootloader.attach(N09cad138);
node N09cad108 = node("ld_script.ld", "f");
bootloader.attach(N09cad108);
node Makefile = node("Makefile", "f");
node N09ca50e8 = node("demo", "d");
node N09ca5110 = node("options.mak", "f");
N09ca50e8.attach(N09ca5110);
node N09ca5168 = node("modules.mak", "f");
N09ca50e8.attach(N09ca5168);
node N09ca5138 = node("ld_script.ld", "f");
N09ca50e8.attach(N09ca5138);
node src = node("src", "d");
node app = node("app", "d");
node N09ca5208 = node("bootloader", "d");
node N09ca5230 = node("common", "d");
node N09ca5258 = node("main.c", "f");
N09ca5230.attach(N09ca5258);
node N09ca5280 = node("shell.c", "f");
N09ca5230.attach(N09ca5280);
node N09ca52a8 = node("misc.c", "f");
N09ca5230.attach(N09ca52a8);
node N09ca52d0 = node("avl_util.c", "f");
N09ca5230.attach(N09ca52d0);
node N09ca52f8 = node("avl_util.h", "f");
N09ca5230.attach(N09ca52f8);
node N09ca5320 = node("Vector_gnu.S", "f");
N09ca5230.attach(N09ca5320);
node N09ca5350 = node("shell.h", "f");
N09ca5230.attach(N09ca5350);
node N09ca5378 = node("map.h", "f");
N09ca5230.attach(N09ca5378);
node N09ca53a0 = node("demo", "d");
node mware = node("mware", "d");
node N09ca53f0 = node("bsp", "d");
node N09ca5418 = node("peripherials", "d");
N09ca53f0.attach(N09ca5418);
node N09ca5448 = node("platform", "d");
node N09ca5470 = node("yyyy-mm-dd", "d");
node N09ca5498 = node("include", "d");
N09ca5470.attach(N09ca5498);
node N09ca54c0 = node("lib", "d");
N09ca5470.attach(N09ca54c0);
N09ca5448.attach(N09ca5470);
N09ca53f0.attach(N09ca5448);

librasd.attach(src, make);
src.attach(app, mware, N09ca53f0);
app.attach(N09ca5230, N09ca53a0, N09ca5208);
make.attach(N09ca50e8, bootloader, Makefile);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(librasd);
//attach(root.fit(), (0,0), SE);
attach(bbox(root, 2, 2, white), (0,0), SE);
