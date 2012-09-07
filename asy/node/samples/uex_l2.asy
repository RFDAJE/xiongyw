import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node MAIN_08b8e008                    = node("//OTV_UEX/NX/MAIN", "d");
node otvnx_08b96050                   = node("otvnx", "d");
node otvtarg_08bb30e0                 = node("otvtarg", "d");
node opentv_08c07568                  = node("opentv", "d");
node otvnet_08c0c308                  = node("otvnet", "d");
node otvmake_08beff98                 = node("otvmake", "d");
MAIN_08b8e008.attach(opentv_08c07568);
MAIN_08b8e008.attach(otvnx_08b96050);
MAIN_08b8e008.attach(otvnet_08c0c308);
MAIN_08b8e008.attach(otvtarg_08bb30e0);
MAIN_08b8e008.attach(otvmake_08beff98);

node sdk_08b9e098                     = node("sdk", "d");
node system_08bb10b0                  = node("system", "d");
node config_08bb2158                  = node("config", "d");
node apps_08bb2180                    = node("apps", "d");
otvnx_08b96050.attach(apps_08bb2180);
otvnx_08b96050.attach(sdk_08b9e098);
otvnx_08b96050.attach(system_08bb10b0);
otvnx_08b96050.attach(config_08bb2158);

node make_08bcc3b0                    = node("make", "d");
node config_08bcc3d8                  = node("config", "d");
node linux_xine_08bb3758              = node("linux_xine", "d");
node tch_sti7141_hot_08bb3108         = node("tch_sti7141_hot", "d");

otvtarg_08bb30e0.attach(make_08bcc3b0);
otvtarg_08bb30e0.attach(config_08bcc3d8);
otvtarg_08bb30e0.attach(linux_xine_08bb3758);
otvtarg_08bb30e0.attach(tch_sti7141_hot_08bb3108);

node make_08c087e8                    = node("make", "d");
node bin_08c08810                     = node("bin", "d");
node ocod_08c092b0                    = node("ocod", "d");
node config_08c09378                  = node("config", "d");
node src_08c093f0                     = node("src", "d");
opentv_08c07568.attach(src_08c093f0);
opentv_08c07568.attach(ocod_08c092b0);
opentv_08c07568.attach(bin_08c08810);
opentv_08c07568.attach(make_08c087e8);
opentv_08c07568.attach(config_08c09378);

node nx_08c0c330                      = node("nx", "d");
otvnet_08c0c308.attach(nx_08c0c330);

node nc_ref = node ("ref", "d");
node nc_hot = node ("hot", "d");
node nc_net_apps = node ("net_apps", "d");
node nc_config = node ("config", "d");
nx_08c0c330.attach(nc_ref, nc_hot, nc_net_apps, nc_config);



node config_parser_08beffc0           = node("config_parser", "d");
node make_08bf0090                    = node("make", "d");
node bin_08bf00b8                     = node("bin", "d");
node stylesheets_08bf0130             = node("stylesheets", "d");
node config_08bf0158                  = node("config", "d");
otvmake_08beff98.attach(bin_08bf00b8);
otvmake_08beff98.attach(make_08bf0090);
otvmake_08beff98.attach(config_08bf0158);
otvmake_08beff98.attach(stylesheets_08bf0130);
otvmake_08beff98.attach(config_parser_08beffc0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(MAIN_08b8e008);
attach(bbox(root, 2, 2, white), (0,0), SE);
