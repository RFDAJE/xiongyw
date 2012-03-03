import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


node AG_TextMsg = node("AG_TextMsg()", "");
node AG_TextMsgS = node("AG_TextMsgS()", "");

AG_TextMsg.attach(AG_TextMsgS);

node AG_WindowNew = node("win=AG_WindowNew()", "");
node AG_WindowSetPadding = node("AG_WindowSetPadding()", "");
node AG_WindowSetGeometry = node("AG_WindowSetGeometry(win,0,0,720,576)", "");
node AG_ViewboxNew = node("vbox=AG_ViewboxNew(win,0,0,720,576)", "");
node AG_LabelNewS = node("label=AG_LabelNewS()","");
node AG_ViewboxMove = node("AG_ViewboxMove(vbox,label,30,25)","");
node AG_ButtonNewFn = node("btn=AG_ButtonNewFn()","");
node AG_ViewboxMove2 = node("AG_ViewboxMove(vbox,btn,30,100)","");
node AG_SurfaceFromBMPData = node("surf=AG_SurfaceFromBMPData()","");
node AG_PixmapFromSurface = node("pix=AG_PixmapFromSurface(vbox,0,surf)","");
node AG_ViewboxMove3 = node("AG_ViewboxMove(vbox,pix,100,50)","");
node AG_WidgetFocus = node("AG_WidgetFocus(btn)","");
node AG_WindowShow = node("AG_WindowShow(win)","");

AG_TextMsgS.attach(AG_WindowNew, 
                   AG_WindowSetPadding,
				   AG_WindowSetGeometry,
				   AG_ViewboxNew,
				   AG_LabelNewS,
				   AG_ViewboxMove,
				   AG_ButtonNewFn,
				   AG_ViewboxMove2,
				   AG_SurfaceFromBMPData,
				   AG_PixmapFromSurface,
				   AG_ViewboxMove3,
				   AG_WidgetFocus,
				   AG_WindowShow);
				   
node AG_PostEvent = node("AG_PostEvent(win, \"widget-shown\")","");
node win_visible_plusplus = node("win->visible++","");

AG_WindowShow.attach(AG_PostEvent, win_visible_plusplus);

node PropagateEvent = node("For each child: PropagateEvent()", "");
node Window_Shown = node("Window::Shown(evt)","");

AG_PostEvent.attach(PropagateEvent, Window_Shown);

node PropagateEvent2 = node("Recusively call PropagateEvent() ...", "");
node AG_ForwardEvent = node("AG_ForwardEvent()", "");

PropagateEvent.attach(PropagateEvent2, AG_ForwardEvent);

node Vbox_Shown = node("Viewbox::Shown(evt)", "");
AG_ForwardEvent.attach(Vbox_Shown);

node AG_WidgetSizeAlloc = node("AG_WidgetSizeAlloc()","");
node AG_WidgetUpdateCoords = node("AG_WidgetUpdateCoords()","");
node AG_PostEvent2 = node("AG_PostEvent(win,\"window-shown\")","");
node AG_PostEvent3 = node("AG_PostEvent(win,\"window-gainfocus\")","");
node AG_WindowSetGeometryAligned = node("AG_WindowSetGeometryAligned()","");
node win_dirty = node("win->dirty=1","");

Window_Shown.attach(AG_WidgetSizeAlloc,
                    AG_WidgetUpdateCoords,
					AG_PostEvent2,
					AG_PostEvent3,
					AG_WindowSetGeometryAligned,
					win_dirty);


					
node AG_ViewRegionCreate = node("AG_ViewRegionCreate()","");
Vbox_Shown.attach(AG_ViewRegionCreate);


node obj_mgmt = node("malloc(sizeof(OSD_OBJECT_MANAGE_T))","");
node initialize_obj_mgmt = node("Initialize obj_mgmt and obj_mgmt->OSDObject...","");
node AVL_MEMALIGN_DMA = node("obj_mgmt->OSDObject.bitmap.data=AVL_MEMALIGN_DMA(64,buf_sz)","");
node InitViewRegionOSDObjAttr = node("InitViewRegionOSDObjAttr()", "");

AG_ViewRegionCreate.attach(obj_mgmt, initialize_obj_mgmt, AVL_MEMALIGN_DMA, InitViewRegionOSDObjAttr);


/*
node  = node("","");
node  = node("","");
node  = node("","");
node  = node("","");
node  = node("","");
node  = node("","");
node  = node("","");
node  = node("","");
*/

//////////////////////////////////////////////////////


picture root = draw_tree(AG_TextMsg, style=TREE_STYLE_STEP, gene_gap=40);
attach(bbox(root, 2, 2, white), (0,0), SE);

