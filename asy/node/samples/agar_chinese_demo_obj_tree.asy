//////////////////////////////////////////////////////////////
//&agDrivers=0x0059f9c4, agDriverSw=0x013a3c80
//agDrivers.root=0x0059f9c4. root->cls->hier=AG_Object
//agDriverSw->root=0x0059f9c4, root->cls->hier=AG_Object
import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node N00664ac0 = node("AG_Object: Root Object", "");
node N00664b9c = node("AG_Object: InputDevices", "");
node N0139e9a0 = node("AG_Keyboard: AG_Keyboard \#0", "");
N00664b9c.attach(N0139e9a0);
N00664ac0.attach(N00664b9c);
node N0139fbf8 = node("AG_DriverOSDLinklist: OSDLinklist1", "");
node N0138acd0 = node("AG_Window: generic", "");
node N01388af8 = node("AG_Viewbox: AG_Viewbox \#0", "");
node N013819f8 = node("AG_Label: AG_Label \#0", "");
N01388af8.attach(N013819f8);
node N01380690 = node("AG_Button: AG_Button \#0", "");
node N0137dcd8 = node("AG_Label: AG_Label \#0", "");
N01380690.attach(N0137dcd8);
N01388af8.attach(N01380690);
node N0137bf60 = node("AG_Pixmap: AG_Pixmap \#0", "");
N01388af8.attach(N0137bf60);
N0138acd0.attach(N01388af8);
N0139fbf8.attach(N0138acd0);
N00664ac0.attach(N0139fbf8);
picture root = draw_tree(N00664ac0, style=TREE_STYLE_STEP, gene_gap=40);


attach(bbox(root, 2, 2, white), (0,0), SE);

//////////////////////////////////////////////////////////////