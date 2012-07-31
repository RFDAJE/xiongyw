import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node otvnx_08c4e008                   = node("MAIN/otvnx", "d");
node sdk_08c56050                     = node("sdk", "d");
node system_08c69068                  = node("system", "d");
node config_08c6a110                  = node("config", "d");
node apps_08c6a138                    = node("apps", "d");
otvnx_08c4e008.attach(apps_08c6a138);
otvnx_08c4e008.attach(sdk_08c56050);
otvnx_08c4e008.attach(system_08c69068);
otvnx_08c4e008.attach(config_08c6a110);


node misc_08c661d8                    = node("misc", "d");
node ocode_08c663c8                   = node("ocode", "d");
node config_08c68a48                  = node("config", "d");
node make_08c66378                    = node("make", "d");
node tools_08c68a70                   = node("tools", "d");
sdk_08c56050.attach(ocode_08c663c8);
sdk_08c56050.attach(misc_08c661d8);
sdk_08c56050.attach(tools_08c68a70);
sdk_08c56050.attach(config_08c68a48);
sdk_08c56050.attach(make_08c66378);

node templates_08c69090               = node("templates", "d");
node include_08c6a0e8                 = node("include", "d");
node ocode_08c690b8                   = node("ocode", "d");
node native_08c69130                  = node("native", "d");
node config_08c69108                  = node("config", "d");
system_08c69068.attach(templates_08c69090);
system_08c69068.attach(include_08c6a0e8);
system_08c69068.attach(ocode_08c690b8);
system_08c69068.attach(native_08c69130);
system_08c69068.attach(config_08c69108);


node nx_popup_08c6a160                = node("nx_popup", "d");
node nx_menu_08c6a228                 = node("nx_menu", "d");
node nx_mailbox_08c6a2f0              = node("nx_mailbox", "d");
node nx_live_player_08c6a3b8          = node("nx_live_player", "d");
node nx_background_08c6a4b0           = node("nx_background", "d");
node nx_foreground_08c6a580           = node("nx_foreground", "d");
node nx_volume_08c6a650               = node("nx_volume", "d");
node nx_installation_08c6a718         = node("nx_installation", "d");
node nx_grid_08c6a810                 = node("nx_grid", "d");
node browser_launcher_08c6ab90        = node("browser_launcher", "d");
node nx_settings_08c6abc0             = node("nx_settings", "d");
node nx_tests_08c6ad28                = node("nx_tests", "d");
node resources_08c6ada0               = node("resources", "d");
node config_08c6adc8                  = node("config", "d");
node nx_quickset_08c6adf0             = node("nx_quickset", "d");
node nx_pvr_08c6aee0                  = node("nx_pvr", "d");
node include_08c6b070                 = node("include", "d");
apps_08c6a138.attach(include_08c6b070);
apps_08c6a138.attach(resources_08c6ada0);
apps_08c6a138.attach(nx_popup_08c6a160);
apps_08c6a138.attach(nx_menu_08c6a228);
apps_08c6a138.attach(nx_mailbox_08c6a2f0);
apps_08c6a138.attach(nx_live_player_08c6a3b8);
apps_08c6a138.attach(nx_background_08c6a4b0);
apps_08c6a138.attach(nx_foreground_08c6a580);
apps_08c6a138.attach(nx_volume_08c6a650);
apps_08c6a138.attach(nx_installation_08c6a718);
apps_08c6a138.attach(nx_grid_08c6a810);
apps_08c6a138.attach(nx_settings_08c6abc0);
apps_08c6a138.attach(nx_tests_08c6ad28);
apps_08c6a138.attach(nx_quickset_08c6adf0);
apps_08c6a138.attach(nx_pvr_08c6aee0);
apps_08c6a138.attach(browser_launcher_08c6ab90);
apps_08c6a138.attach(config_08c6adc8);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(otvnx_08c4e008);
attach(bbox(root, 2, 2, white), (0,0), SE);
