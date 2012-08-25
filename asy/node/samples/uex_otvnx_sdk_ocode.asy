import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node ocode_09dc5008                   = node("MAIN/otvnx/sdk/ocode", "d");
node libuex_09dcd050                  = node("libuex", "d");
node nx_framework_09dd5110            = node("nx_framework", "d");
node dll_appmgr_09dd5168              = node("dll_appmgr", "d");
node lex_09dd5190                     = node("lex", "d");
ocode_09dc5008.attach(libuex_09dcd050);
ocode_09dc5008.attach(nx_framework_09dd5110);
ocode_09dc5008.attach(dll_appmgr_09dd5168);
ocode_09dc5008.attach(lex_09dd5190);
node doc_09dd5098                     = node("doc", "d");
node include_09dd50c0                 = node("include", "d");
node src_09dd50e8                     = node("src", "d");
libuex_09dcd050.attach(doc_09dd5098);
libuex_09dcd050.attach(include_09dd50c0);
libuex_09dcd050.attach(src_09dd50e8);
node internal_09dd5140                = node("internal", "d");
nx_framework_09dd5110.attach(internal_09dd5140);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(ocode_09dc5008);
attach(bbox(root, 2, 2, white), (0,0), SE);
