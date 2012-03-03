import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


node AG_TextInit = node("AG_TextInit()", "");

node SLIST_INIT = node("SLIST_INIT(\&fonts)","");
node AG_SetCfgString = node("AG_SetCfgString(\"font-path\",...,\"/usr/local/share/agar/fonts\")","");
node AG_SetCfgString2 = node("AG_SetCfgString(\"font.face\",agDefaultFaceBitmap)","");
node AG_SetInt = node("AG_SetInt(agConfig,(\"font.size\"),(10))","");
node AG_SetUint = node("AG_SetUint(agConfig,(\"font.flags\"),(0))","");
node AG_FetchFont = node("font=AG_FetchFont(face=NULL,size=-1,flags=-1)", "");
node agDefaultFont = node("agDefaultFont=font","");
node agTextFontHeight = node("agTextFontHeight=font->height","");
node agTextFontAscent = node("agTextFontAscent=font->ascent","");
node agTextFontDescent = node("agTextFontDescent=font->descent","");
node agTextFontLineSkip = node("agTextFontLineSkip=font->lineskip","");
node curState = node("curState=0","");
node agTextState = node("agTextState=\&states[0]","");
node InitTextState = node("InitTextState()","");
node SetDefaultCharSet = node("SetDefaultCharSet()","");

AG_TextInit.attach(SLIST_INIT,
                   AG_SetCfgString,
				   AG_SetCfgString2,
				   AG_SetInt,
				   AG_SetUint,
				   AG_FetchFont,
				   agDefaultFont,
				   agTextFontHeight,
				   agTextFontAscent,
				   agTextFontDescent,
				   agTextFontLineSkip,
				   curState,
				   agTextState,
				   InitTextState,
				   SetDefaultCharSet);

node font_list_init = node("(\&fonts)->slh_first=0","");
SLIST_INIT.attach(font_list_init);


node get_font_face = node("AG_CopyCfgString(\"font.face\",name)","");
node if_match_found = node("if(matching font found for face/size/flags)","");
node else_match_found = node("else","");
node TryMalloc = node("font=TryMalloc(sizeof(AG_Font))","");
node AG_ObjectInit = node("AG_ObjectInit(font,&agFontClass)","");
node AG_ObjectSetNameS = node("AG_ObjectSetNameS(font, name)","");
node font_size = node("font->size=ptsize","");
node font_flags = node("font->flags=flags","");
node font_c0 = node("font->c0=0","");
node font_c1 = node("font->c1=0","");
node font_height = node("font->height=0","");
node font_ascent = node("font->ascent=0","");
node font_descent = node("font->descent=0","");
node font_lineskip = node("font->lineskip=0","");

node search_builtin_font = node("Search in built-in fonts","");

node AG_SetCfgString = node("AG_SetCfgString(\"bitmap_gb2312\",\"BITMAP_GB2312\")", "");
SetDefaultCharSet.attach(AG_SetCfgString);

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


picture root = draw_tree(AG_TextInit, style=TREE_STYLE_STEP, gene_gap=40);
attach(bbox(root, 2, 2, white), (0,0), SE);

