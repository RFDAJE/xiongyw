import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node opendreambox_0a032008            = node("opendreambox-20120523", "d");
node meta_opendreambox_0a03a058       = node("meta-opendreambox", "d");
node meta_bsp_0a04be38                = node("meta-bsp", "d");
node bitbake_0a04c6f8                 = node("bitbake", "d");
node scripts_0a04c720                 = node("scripts", "d");
node openembedded_core_0a04c748       = node("openembedded-core", "d");
node doc_0a04c778                     = node("doc", "d");
node meta_openembedded_0a04c7a0       = node("meta-openembedded", "d");
node conf_0a04c7d0                    = node("conf", "d");
opendreambox_0a032008.attach(conf_0a04c7d0);
opendreambox_0a032008.attach(bitbake_0a04c6f8);
opendreambox_0a032008.attach(openembedded_core_0a04c748);
opendreambox_0a032008.attach(meta_openembedded_0a04c7a0);
opendreambox_0a032008.attach(meta_opendreambox_0a03a058);
opendreambox_0a032008.attach(meta_bsp_0a04be38);
opendreambox_0a032008.attach(scripts_0a04c720);
opendreambox_0a032008.attach(doc_0a04c778);

node recipes_extended_0a0420a8        = node("recipes-extended", "d");
node recipes_devtools_0a04a2e0        = node("recipes-devtools", "d");
node classes_0a04a560                 = node("classes", "d");
node recipes_connectivity_0a04a588    = node("recipes-connectivity", "d");
node recipes_multimedia_0a04ab68      = node("recipes-multimedia", "d");
node recipes_qt_0a04b1f0              = node("recipes-qt", "d");
node recipes_support_0a04b2c0         = node("recipes-support", "d");
node recipes_kernel_0a04b428          = node("recipes-kernel", "d");
node conf_0a04b4f0                    = node("conf", "d");
node recipes_dreambox_0a04b540        = node("recipes-dreambox", "d");
node recipes_core_0a04bb18            = node("recipes-core", "d");
meta_opendreambox_0a03a058.attach(conf_0a04b4f0);
meta_opendreambox_0a03a058.attach(classes_0a04a560);
meta_opendreambox_0a03a058.attach(recipes_core_0a04bb18);
meta_opendreambox_0a03a058.attach(recipes_extended_0a0420a8);
meta_opendreambox_0a03a058.attach(recipes_devtools_0a04a2e0);
meta_opendreambox_0a03a058.attach(recipes_connectivity_0a04a588);
meta_opendreambox_0a03a058.attach(recipes_multimedia_0a04ab68);
meta_opendreambox_0a03a058.attach(recipes_qt_0a04b1f0);
meta_opendreambox_0a03a058.attach(recipes_support_0a04b2c0);
meta_opendreambox_0a03a058.attach(recipes_kernel_0a04b428);
meta_opendreambox_0a03a058.attach(recipes_dreambox_0a04b540);

node common_0a04c118                  = node("common", "d");
node dm500hd_0a04c448                 = node("dm500hd", "d");
node dm800_0a04be60                   = node("dm800", "d");
node dm800se_0a04bfc0                 = node("dm800se", "d");
node dm7020hd_0a04c5a0                = node("dm7020hd", "d");
node dm8000_0a04c2f0                  = node("dm8000", "d");
meta_bsp_0a04be38.attach(common_0a04c118);
meta_bsp_0a04be38.attach(dm500hd_0a04c448);
meta_bsp_0a04be38.attach(dm800_0a04be60);
meta_bsp_0a04be38.attach(dm800se_0a04bfc0);
meta_bsp_0a04be38.attach(dm7020hd_0a04c5a0);
meta_bsp_0a04be38.attach(dm8000_0a04c2f0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(opendreambox_0a032008);
attach(bbox(root, 2, 2, white), (0,0), SE);
