import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


node AG_ObjectNew = node("AG_ObjectNew(parent, name, cls)", "");
node TryMalloc = node("obj=TryMalloc(cls->size)", "");
node AG_ObjectInit = node("AG_ObjectInit(obj, cls)", "");
node AG_ObjectSetNameS = node("AG_ObjectSetNameS()", "");
node AG_ObjectAttach = node("AG_ObjectAttach(parent, obj)", "");
AG_ObjectNew.attach(TryMalloc, AG_ObjectInit, AG_ObjectSetNameS, AG_ObjectAttach);

node TAILQ_INIT = node("TAILQ_INIT(deps)", "");
node TAILQ_INIT2 = node("TAILQ_INIT(children)", "");
node TAILQ_INIT3 = node("TAILQ_INIT(events)", "");
node TAILQ_INIT4 = node("TAILQ_INIT(timeouts)", "");
node AG_ObjectGetInheritHier = node("AG_ObjectGetInheritHier(obj, hier[], \&nhier)", "");
node call_hier_init = node("Loop: hier[i]->init(obj)", "");

AG_ObjectInit.attach(TAILQ_INIT, TAILQ_INIT2, TAILQ_INIT3, TAILQ_INIT4, AG_ObjectGetInheritHier, call_hier_init);

//picture root = draw_call_sequence(AG_ObjectNew);
picture root = draw_tree(AG_ObjectNew, style=TREE_STYLE_STEP, gene_gap=40);
//attach(root.fit(), (0,0), SE);
attach(bbox(root, 2, 2, white), (0,0), SE);

