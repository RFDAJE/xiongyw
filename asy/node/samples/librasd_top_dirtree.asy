import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");

node librasd = node("librasd", "d");
node make = node("make", "d");
node doc = node("doc", "d");
node tools = node("tools", "d");
node src = node("src", "d");
node app = node("app", "d");
node mware = node("mware", "d");
node bsp = node("bsp", "d");
node peripherals = node("peripherals", "d");
node platform = node("platform", "d");

librasd.attach(src, make, doc, tools);

bsp.attach(peripherals, platform);

src.attach(app, mware, bsp);



//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(librasd);
//attach(root.fit(), (0,0), SE);
attach(bbox(root, 2, 2, white), (0,0), SE);