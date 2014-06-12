import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node customise_095ad008               = node("NETUI/client/customise", "d");
node platform_095b5050                = node("platform", "d");
node DataMappers_js_095bd1d0          = node("DataMappers.js", "f");
node operator_095bd200                = node("operator", "d");
node KeyMap_NET_js_095bd260           = node("KeyMap_NET.js", "f");
node BaseKeyMap_NET_js_095bd290       = node("BaseKeyMap_NET.js", "f");
customise_095ad008.attach(platform_095b5050);
customise_095ad008.attach(operator_095bd200);
customise_095ad008.attach(KeyMap_NET_js_095bd260);
customise_095ad008.attach(BaseKeyMap_NET_js_095bd290);
customise_095ad008.attach(DataMappers_js_095bd1d0);
node system_095bd098                  = node("system", "d");
node btv_095bd0c0                     = node("btv", "d");
platform_095b5050.attach(btv_095bd0c0);
platform_095b5050.attach(system_095bd098);
node Scan_js_095c50e0                 = node("Scan.js", "f");
node Network_js_095c5108              = node("Network.js", "f");
system_095bd098.attach(Scan_js_095c50e0);
system_095bd098.attach(Network_js_095c5108);
node PVRManager_js_095bd0e8           = node("PVRManager.js", "f");
node EPGEventFactory_js_095bd118      = node("EPGEventFactory.js", "f");
node RecordingFactory_js_095bd148     = node("RecordingFactory.js", "f");
node EPG_js_095bd178                  = node("EPG.js", "f");
node Reminders_js_095bd1a0            = node("Reminders.js", "f");
btv_095bd0c0.attach(PVRManager_js_095bd0e8);
btv_095bd0c0.attach(RecordingFactory_js_095bd148);
btv_095bd0c0.attach(Reminders_js_095bd1a0);
btv_095bd0c0.attach(EPG_js_095bd178);
btv_095bd0c0.attach(EPGEventFactory_js_095bd118);
node NETUsageIdManager_js_095bd228    = node("NETUsageIdManager.js", "f");
operator_095bd200.attach(NETUsageIdManager_js_095bd228);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(customise_095ad008);
attach(bbox(root, 2, 2, white), (0,0), SE);
