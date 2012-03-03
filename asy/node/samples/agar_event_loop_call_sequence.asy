import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


node AG_EventLoop = node("AG_EventLoop()", "");
node genericEventLoop = node("agDriverOps->genericEventLoop(agDriverSw)", "");
AG_EventLoop.attach(genericEventLoop);

node AG_OSD_GenericEventLoop = node("AG_OSD_GenericEventLoop()", "");
node outer_loop_start = node("for(;;)\{", "");
node outer_loop_stop = node("\}", "");
AG_OSD_GenericEventLoop.attach(outer_loop_start, outer_loop_stop);

node if_any_win_dirty = node("If any winow is dirty", "");
node if_any_key_down = node("If any key is down", "");
node if_any_timeout = node("If any timeout fires", "");
node AG_Delay = node("AG_Delay(1)", "");

outer_loop_start.attach(if_any_win_dirty, if_any_key_down, if_any_timeout, AG_Delay);

node AG_BeginRendering = node("OSDLinklist_BeginRendering()", "");
node window_loop_start = node("AG_FOREACH_WINDOW(win, drv)", "");
node AG_EndRendering = node("OSDLinklist_EndRendering()", "");
if_any_win_dirty.attach(AG_BeginRendering, window_loop_start, AG_EndRendering);

node AG_WindowDraw = node("AG_WindowDraw(win)", "");
window_loop_start.attach(AG_WindowDraw);

node if_window_visible = node("if(win->visible)", "");
AG_WindowDraw.attach(if_window_visible);

node OSDLinkList_RenderWindow = node("OSDLinklist_RenderWindow(win)", "");
if_window_visible.attach(OSDLinkList_RenderWindow);

node AG_WidgetDraw = node("AG_WidgetDraw(win)","");
OSDLinkList_RenderWindow.attach(AG_WidgetDraw);

node window_draw = node("Window::Draw()", "");
AG_WidgetDraw.attach(window_draw);

node AG_WindowUpdate = node("AG_WindowUpdate()", "");
node loop_draw = node("For each child: AG_WidgetDraw()", "");
window_draw.attach(AG_WindowUpdate, loop_draw);

node vbox_draw = node("Viewbox::Draw()", "");
loop_draw.attach(vbox_draw);

node AG_BeginUpdateViewRegion = node("AG_BeginUpdateViewRegion()", "");
node loop_draw2 = node("For each child: AG_WidgetDraw() ...", "");
node AG_EndUpdateViewRegion = node("AG_EndUpdateViewRegion()", "");
vbox_draw.attach(AG_BeginUpdateViewRegion, 
                 loop_draw2, 
				 AG_EndUpdateViewRegion);

node avl_osd_create_object = node("avl_osd_create_object(obj,\&obj_id)", "");
node SyncMirrorRegion = node("SyncMirrorRegion()", "");
AG_BeginUpdateViewRegion.attach(avl_osd_create_object, SyncMirrorRegion);


node AG_FlipViewRegions = node("AG_FlipViewRegions()", "");
AG_EndRendering.attach(AG_FlipViewRegions);


node avl_osd_show_object = node("avl_osd_show_object(obj_id)...", "");
node avl_osd_set_object_buffer_ptr = node("avl_osd_set_object_buffer_ptr(obj_id, buf)...", "");
node avl_osd_refresh_objects = node("avl_osd_refresh_objects()", "");
AG_FlipViewRegions.attach(avl_osd_show_object,
                          avl_osd_set_object_buffer_ptr,
						  avl_osd_refresh_objects);


//////////////////////////////////////////////////////


picture root = draw_tree(AG_EventLoop, style=TREE_STYLE_STEP, gene_gap=40);
attach(bbox(root, 2, 2, white), (0,0), SE);

picture root = draw_tree(AG_OSD_GenericEventLoop, style=TREE_STYLE_STEP, gene_gap=40);
attach(bbox(root, 2, 2, white), (0,-80), SE);
