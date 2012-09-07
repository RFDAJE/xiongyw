import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node nx_09273008                      = node("otvnet/nx", "d");
node ref_0927b050                     = node("ref", "d");
node net_apps_09283c20                = node("net_apps", "d");
node config_09285220                  = node("config", "d");
node hot_09285248                     = node("hot", "d");
nx_09273008.attach(ref_0927b050);
nx_09273008.attach(hot_09285248);
nx_09273008.attach(net_apps_09283c20);
nx_09273008.attach(config_09285220);



node apps_09283258                    = node("apps", "d");
node ocode_09283168                   = node("ocode", "d");
node native_09283968                  = node("native", "d");
node builtin_fonts_09283098           = node("builtin_fonts", "d");
node translation_092830c8             = node("translation", "d");
node config_092831b8                  = node("config", "d");
ref_0927b050.attach(apps_09283258);
ref_0927b050.attach(ocode_09283168);
ref_0927b050.attach(native_09283968);
ref_0927b050.attach(builtin_fonts_09283098);
ref_0927b050.attach(translation_092830c8);
ref_0927b050.attach(config_092831b8);

/*
node test_appmgr18_09283c48           = node("test_appmgr18", "d");
node test_textdirection_09283c78      = node("test_textdirection", "d");
node test_translation_09283d20        = node("test_translation", "d");
node test_appmgr17_09283e78           = node("test_appmgr17", "d");
node test_teaser_09283ea8             = node("test_teaser", "d");
node JCAbasic_dll_app_092840e8        = node("JCAbasic_dll_app", "d");
node grid_09284168                    = node("grid", "d");
node test_appmgr9_09284190            = node("test_appmgr9", "d");
node test_appmgr20_092841c0           = node("test_appmgr20", "d");
node test_ait_092841f0                = node("test_ait", "d");
node test_nxnp_092842b8               = node("test_nxnp", "d");
node app_launcher_092842e0            = node("app_launcher", "d");
node test_hdmi_092843b0               = node("test_hdmi", "d");
node basic_dll_app_09284428           = node("basic_dll_app", "d");
node test_png_slideshow_092844a8      = node("test_png_slideshow", "d");
node prm_test_app_09284500            = node("prm_test_app", "d");
node test_appmgr2_092847e0            = node("test_appmgr2", "d");
node test_appmgr16_09284810           = node("test_appmgr16", "d");
node test_appmgr3_09284840            = node("test_appmgr3", "d");
node nx_tests_09284870                = node("nx_tests", "d");
node asu_example_092849d8             = node("asu_example", "d");
node test_appmgr6_09284a50            = node("test_appmgr6", "d");
node config_09284a80                  = node("config", "d");
node test_appmgr4_09284aa8            = node("test_appmgr4", "d");
node test_appmgr7_09284ad8            = node("test_appmgr7", "d");
node test_pmon_09284b08               = node("test_pmon", "d");
node test_appmgr11_09284bd0           = node("test_appmgr11", "d");
node test_otv_dll_09284c00            = node("test_otv_dll", "d");
node test_appmgr5_09284c30            = node("test_appmgr5", "d");
node graphx_benchmark_test_09284c60   = node("graphx_benchmark_test", "d");
node test_appmgr10_09284c98           = node("test_appmgr10", "d");
node pvr2_test_09284cc8               = node("pvr2_test", "d");
node test_util_09284e40               = node("test_util", "d");
node test_appmgr8_09284f08            = node("test_appmgr8", "d");
node test_appmgr15_09284f38           = node("test_appmgr15", "d");
node test_lifecycle_09284f68          = node("test_lifecycle", "d");
node http_download_09285010           = node("http_download", "d");
node test_appmgr_09285090             = node("test_appmgr", "d");
node test_appmgr19_092850b8           = node("test_appmgr19", "d");
node test_fontspacing_092850e8        = node("test_fontspacing", "d");
node test_appmgr13_09285190           = node("test_appmgr13", "d");
node test_appmgr14_092851c0           = node("test_appmgr14", "d");
node test_appmgr12_092851f0           = node("test_appmgr12", "d");
net_apps_09283c20.attach(test_appmgr18_09283c48);
net_apps_09283c20.attach(test_textdirection_09283c78);
net_apps_09283c20.attach(test_translation_09283d20);
net_apps_09283c20.attach(test_appmgr17_09283e78);
net_apps_09283c20.attach(test_teaser_09283ea8);
net_apps_09283c20.attach(JCAbasic_dll_app_092840e8);
net_apps_09283c20.attach(grid_09284168);
net_apps_09283c20.attach(test_appmgr9_09284190);
net_apps_09283c20.attach(test_appmgr20_092841c0);
net_apps_09283c20.attach(test_ait_092841f0);
net_apps_09283c20.attach(test_nxnp_092842b8);
net_apps_09283c20.attach(app_launcher_092842e0);
net_apps_09283c20.attach(test_hdmi_092843b0);
net_apps_09283c20.attach(basic_dll_app_09284428);
net_apps_09283c20.attach(test_png_slideshow_092844a8);
net_apps_09283c20.attach(prm_test_app_09284500);
net_apps_09283c20.attach(test_appmgr2_092847e0);
net_apps_09283c20.attach(test_appmgr16_09284810);
net_apps_09283c20.attach(test_appmgr3_09284840);
net_apps_09283c20.attach(nx_tests_09284870);
net_apps_09283c20.attach(asu_example_092849d8);
net_apps_09283c20.attach(test_appmgr6_09284a50);
net_apps_09283c20.attach(config_09284a80);
net_apps_09283c20.attach(test_appmgr4_09284aa8);
net_apps_09283c20.attach(test_appmgr7_09284ad8);
net_apps_09283c20.attach(test_pmon_09284b08);
net_apps_09283c20.attach(test_appmgr11_09284bd0);
net_apps_09283c20.attach(test_otv_dll_09284c00);
net_apps_09283c20.attach(test_appmgr5_09284c30);
net_apps_09283c20.attach(graphx_benchmark_test_09284c60);
net_apps_09283c20.attach(test_appmgr10_09284c98);
net_apps_09283c20.attach(pvr2_test_09284cc8);
net_apps_09283c20.attach(test_util_09284e40);
net_apps_09283c20.attach(test_appmgr8_09284f08);
net_apps_09283c20.attach(test_appmgr15_09284f38);
net_apps_09283c20.attach(test_lifecycle_09284f68);
net_apps_09283c20.attach(http_download_09285010);
net_apps_09283c20.attach(test_appmgr_09285090);
net_apps_09283c20.attach(test_appmgr19_092850b8);
net_apps_09283c20.attach(test_fontspacing_092850e8);
net_apps_09283c20.attach(test_appmgr13_09285190);
net_apps_09283c20.attach(test_appmgr14_092851c0);
net_apps_09283c20.attach(test_appmgr12_092851f0);
*/

node builtin_fonts_09285270           = node("builtin_fonts", "d");
node translation_09285720             = node("translation", "d");
node ocode_092857e8                   = node("ocode", "d");
node config_09285868                  = node("config", "d");
node apps_09285908                    = node("apps", "d");
node native_09286238                  = node("native", "d");
hot_09285248.attach(apps_09285908);
hot_09285248.attach(ocode_092857e8);
hot_09285248.attach(native_09286238);
hot_09285248.attach(builtin_fonts_09285270);
hot_09285248.attach(translation_09285720);
hot_09285248.attach(config_09285868);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(nx_09273008);
attach(bbox(root, 2, 2, white), (0,0), SE);
