import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");

/* agar-1.4.1/demos/chinese/main.c */

//node AG_ = node("AG_()", "");

node main = node("main()", "");
node AG_InitCore = node("Agar_InitCore(\"agar-chinese-demo\", flags)", "");
node AG_InitGraphics = node("AG_InitGraphics()", "");
node AG_FetchFont = node("AG_FetchFont()", "");
node AG_SetDefaultFont = node("AG_SetDefaultFont()", "");
node AG_TextMsg = node("AG_TextMsg()", "");
node AG_EventLoop = node("AG_EventLoop()", "");
node AG_Destroy = node("AG_Destroy()", "");
main.attach(AG_InitCore, AG_InitGraphics, AG_FetchFont, AG_SetDefaultFont, AG_TextMsg, AG_EventLoop, AG_Destroy);



node AG_InitClassTbl = node("AG_InitClassTbl()", "");
node AG_RegisterClass = node("AG_RegisterClass(\&agConfigClass)", "");
node AG_SetTimeOps = node("AG_SetTimeOps()", "");
node AG_DataSourceInitSubsystem = node("AG_DataSourceInitSubsystem()", "");
node agConfig_malloc = node("agConfig=TryMalloc(sizeof(AG_Config))", "");
node AG_ConfigInit = node("AG_ConfigInit(agconfig, flags)", "");

AG_InitCore.attach(AG_InitClassTbl, AG_RegisterClass, AG_SetTimeOps, AG_DataSourceInitSubsystem, agConfig_malloc, AG_ConfigInit);

node malloc1 = node("agNamespaceTbl=Malloc()", "");
node malloc2 = node("agModuleDirs=Malloc()", "");
node AG_RegisterNamespace = node("AG_RegisterNamespace(\"Agar\", \"AG_\", \"http://libagar.org\")", "");
node InitClass = node("InitClass(\&agObjectClass, \"AG_Object\", \"\")", "");
node agClassTree = node("agClassTree=\&agObjectClass", "");
node agClassTbl = node("AG_TblNew(256, 0)", "");
node AG_InitPointer = node("AG_InitPointer(\&V, \&agObjectClass)", "");
node AG_TblInsert = node("AG_TblInsert(agClassTbl, \"AG_Object\", \&V)", "");
node AG_MutexInitRecursive = node("AG_MutexInitRecursive(\&agClassLock)", "");
AG_InitClassTbl.attach(malloc1, malloc2, AG_RegisterNamespace, InitClass, agClassTree, agClassTbl,AG_InitPointer, AG_TblInsert, AG_MutexInitRecursive);


node AG_InitGUIGlobals = node("AG_InitGUIGlobals()", "");
node dc = node("dc=agDriverList[i]", "");
node AG_DriverOpen = node("drv=AG_DriverOpen(dc)", "");
node openvideo = node("drv->openVideo()", "");
node AG_InitGUI = node("AG_InitGUI(0)", "");
node agDriverOps = node("agDriverOps=dc", "");
node agDriverSw = node("agDriverSw=drv", "");

AG_InitGraphics.attach(AG_InitGUIGlobals, dc, AG_DriverOpen, openvideo, AG_InitGUI, agDriverOps, agDriverSw);

node AG_ObjectNew = node("drv=AG_ObjectNew(dc)", "");
node dc_open = node("dc->open(drv)", "");
node AG_ObjectSetName = node("AG_ObjectSetName(drv,name)", "");
node AG_ObjectAttach = node("AG_ObjectAttach(\&agDrivers,drv)", "");
AG_DriverOpen.attach(AG_ObjectNew, dc_open, AG_ObjectSetName, AG_ObjectAttach);


node AG_RegisterClass2 = node("AG_RegisterClass(\&agDriverClass)", "");
node AG_RegisterClass3 = node("AG_RegisterClass(\&agDriverSwClass)", "");
node AG_RegisterClass4 = node("AG_RegisterClass(\&agInputDeviceClass)", "");
node AG_RegisterClass41 = node("AG_RegisterClass(\&agKeyboardClass)", "");
node AG_RegisterClass5 = node("Loop: AG_RegisterClass(agDriverList[i])", "");
node AG_InitGlobalKeys = node("AG_InitGlobalKeys()", "");
node AG_LabelInitFormats = node("AG_LabelInitFormats()", "");
node AG_PixelFormatRGBA = node("agSurfaceFmt=AG_PixelFormatRGBA(16,0x7C00,0x03E0,0x001F,0x8000)", "");
node AG_ObjectInitStatic = node("AG_ObjectInitStatic(\&agDrivers, \&agObjectClass)", "");
node AG_ObjectInitStatic2 = node("AG_ObjectInitStatic(\&agInputDevices, \&agObjectClass)", "");

AG_InitGUIGlobals.attach(AG_RegisterClass2, AG_RegisterClass3, AG_RegisterClass4, AG_RegisterClass41, AG_RegisterClass5, AG_InitGlobalKeys, AG_LabelInitFormats, AG_PixelFormatRGBA, AG_ObjectInitStatic, AG_ObjectInitStatic2);

node agDriverList = node("agDriverOSDLinkList", "");
AG_RegisterClass5.attach(agDriverList);

node AG_RegisterClass6 = node("Loop: AG_RegisterClass(agGUIClasses[i])", "");
node AG_ColorsInit = node("AG_ColorsInit()", "");
node AG_TextInit = node("AG_TextInit()", "");
node AG_InitWindowSystem = node("AG_InitWindowSystem()", "");
node AG_InitAppMenu = node("AG_InitAppMenu()", "");
node agar_input_init = node("agar_input_init()", "");

AG_InitGUI.attach(AG_RegisterClass6, AG_ColorsInit, AG_TextInit, AG_InitWindowSystem, AG_InitAppMenu, agar_input_init);

node agGUIClasses = node("agWidgetClass,agWindowClass,agFontClass,agBoxClass...agViewboxClass", "");
AG_RegisterClass6.attach(agGUIClasses);




/*
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
node AG_ = node("AG_()", "");
*/


picture root = draw_tree(main, style=TREE_STYLE_STEP, gene_gap=40);
//attach(root.fit(), (0,0), SE);
attach(bbox(root, 2, 2, white), (0,0), SE);
