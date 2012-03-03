//////////////////////////////////////////////////////////////
import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node AG_ObjectClass = node("AG_ObjectClass", "d");
node AG_DriverClass = node("AG_DriverClass", "d");
node AG_DriverSwClass = node("AG_DriverSwClass", "d");
node AG_WidgetClass = node("AG_WidgetClass", "d");

AG_ObjectClass.attach(AG_WidgetClass, AG_DriverClass);
AG_DriverClass.attach(AG_DriverSwClass);

picture root = draw_tree(AG_ObjectClass, style=TREE_STYLE_STEP, gene_gap=40);

//attach(root.fit(), (0,0), SE);
attach(bbox(root, 2, 2, white), (0,0), SE);
//////////////////////////////////////////////////////////////