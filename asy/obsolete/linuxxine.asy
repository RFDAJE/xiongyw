/* 
 * created(bruin, 2008-11-09): LinuxXine Directory structure
 *
 * $Id$
 */
import fontsize;
import "node.asy" as node;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             %\usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             %\newcommand{\myfrac}[2]{#1\!/\!#2}
             %\newcommand{\cwave}{бл}
             %\newcommand{\song}{\CJKfamily{song}}
             %\newcommand{\fs}{\CJKfamily{fs}}
             %\newcommand{\hei}{\CJKfamily{hei}}
             %\newcommand{\kai}{\CJKfamily{kai}}
             %\AtBeginDocument{\begin{CJK*}{GBK}{hei}}
             %\AtEndDocument{\clearpage\end{CJK*}}"
            );

/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);




/* ################ directory tree ################ */

real   font_size = 10;      /* font size */

string dir = "d";
string file = "f";

/* 
 * sample node draw function to draw folder 
 * icon around directory names, as shown below:
 *
 *          _______
 *         /       \
 *        +------------------+
 *        |                  |
 *        | mydirectoryname  |
 *        |                  |
 *        +------------------+
 */
picture dir_draw_func(node p)
{
	picture pic;
	real mini_h = font_size; 
	real margin = 2 ; /* h & v margins */
  pair min, max;

  label(pic, "\texttt{"+p.text+"}");
  
  
   /* get the text dimension */
   min = min(pic);
   max = max(pic);
   
   /* make sure the height is at least min_h */
   if((max.y - min.y) < mini_h){
       real delta = (mini_h - (max.y - min.y)) / 2;
       max = (max.x, max.y + delta);
       min = (min.x, min.y - delta);
   }
   
   /* take margin into account */
   min -= (margin, margin);
   max += (margin, margin);
   
   /* draw the box */
   draw(pic, min--(min.x, max.y)--max--(max.x, min.y)--cycle,  p.priv == dir? defaultpen : invisible);

   /* draw the folder part */
   draw(pic, (min.x, max.y)--(min.x+2, max.y+2)--(min.x+8, max.y+2)--(min.x+10, max.y), p.priv == dir? defaultpen : invisible);

   return pic;
}


node dir_etc                     = node("$\cdots$", "d");
node file_etc                    = node("$\cdots$", "f");

/* the root (CO21007) */
node root   = node("CO21007", "d");

node opentv       = node("opentv", "d");
node otvnet       = node("otvnet", "d");
node otvtarg      = node("otvtarg", "d");

root.attach(opentv,
               otvnet,
               otvtarg);

/* root/opentv */
node opentv_src           = node("src", "d");
node opentv_external      = node("external", "d");
node opentv_ocod          = node("ocod", "d");
node opentv_coverity      = node("coverity", "d");
node opentv_test          = node("test", "d");
node opentv_bin           = node("bin", "d");
node opentv_make          = node("make", "d");

opentv.attach(opentv_src,
              opentv_external,
              opentv_ocod,
              opentv_coverity,
              opentv_test,
              opentv_bin,
              opentv_make);
              
/* root/opentv/external */
node ext_intoto     = node("Intoto", "d");
node ext_opensrc    = node("opensrc", "d");
node ext_thirdparty = node("thirdparty", "d");

opentv_external.attach(ext_intoto,
                       ext_opensrc,
                       ext_thirdparty);
                       
/* root/opentv/external/opensrc */
node libjpeg         = node("libjpeg", "d");
node libpng          = node("libpng", "d");
node zlib            = node("zlib", "d");

ext_opensrc.attach(libjpeg, 
                   libpng,
                   zlib);
                   
/* root/opentv/external/thirdparty */
node monotype   = node("monotype", "d");
ext_thirdparty.attach(monotype);

/* root/otvnet */
node generic        = node("generic", "d");
node target_decoder = node("target_decoder", "d");
node demo           = node("demo", "d");
node ausnp_pvr      = node("ausnp_pvr", "d");
node foxtel_skynz_np= node("foxtel_skynz_np", "d");
node ucnp_pvr       = node("UCNP_PVR", "d");
node kauai          = node("kauai", "d");

otvnet.attach(generic,
              target_decoder,
              demo,
              ausnp_pvr,
              foxtel_skynz_np,
              ucnp_pvr,
              kauai);
              
/* root/otvtarg */              
node linux_xine    = node("linux_xine", "d");
otvtarg.attach(linux_xine);

/* root/otvtarg/linux_xine */
node linux_xine_src        = node("src", "d");
node linux_xine_share      = node("share", "d");
node linux_xine_make       = node("make", "d");
node linux_xine_pkg        = node("pkg", "d");
node linux_xine_ocod       = node("ocod", "d");
node linux_xine_obj        = node("obj", "d");
node linux_xine_exe        = node("exe", "d");
node linux_xine_setenv     = node("setenv", "f");

linux_xine.attach(linux_xine_src,
                  linux_xine_share,
                  linux_xine_make,
                  linux_xine_pkg,
                  linux_xine_ocod,
                  linux_xine_obj,
                  linux_xine_exe,
                  linux_xine_setenv);
                  
/* root/otvtarg/linux_xine/exe */                  
node exe_bin      = node("bin", "d");
node exe_lib      = node("lib", "d");
node loader       = node("loader", "f");
node linuxxine_xml= node("linuxxine.xml", "f");

linux_xine_exe.attach(exe_bin,
                      exe_lib,
                      loader,
                      linuxxine_xml);
                      
                      
/********* draw the root tree *******/                             
//picture root = draw_tree(root, dir_draw_func, style=TREE_STYLE_STEP, level=6, gene_gap=40, show_collapse_icon=true);
picture root = draw_tree(root, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
shipout("linuxxine.eps");
erase(currentpicture);




/*
 * the following contains more details under "otvtarg/linux_xine/..." 
 */                      
                      
                      
                      
/* root/otvtarg/linux_xine/exe/bin */
node xine_config   = node("xine-config", "f");
exe_bin.attach(xine_config);

/* root/otvtarg/linux_xine/lib */
node pkgconfig     = node("pkgconfig", "d");
node exe_lib_xine  = node("xine", "d");
node libxine_so    = node("libxine.so", "f");
node libxine_so1   = node("libxine.so.1", "f");
node libxine_la    = node("libxine.la", "f");
exe_lib.attach(exe_lib_xine,
               pkgconfig,
               libxine_so,
               libxine_so1,
               libxine_la);
               
/* root/otvtarg/linux_xine/lib/pkgconfig */
node libxine_pc    = node("libxine.pc", "f");
pkgconfig.attach(libxine_pc);

/* root/otvtarg/linux_xine/lib/xine */
node plugins       = node("plugins", "d");
node v1_1_6        = node("1.1.6", "d");
exe_lib_xine.attach(plugins);
plugins.attach(v1_1_6);








/* root/otvtarg/linux_xine/lib/xine/plugins/1.1.6 */
node vidix     = node("vidix", "d");
node post      = node("post", "d");
node xineplug_inp      = node("xineplug_inp_*.so", "f");
node xineplug_dmx      = node("xineplug_dmx_*.so", "f");
node xineplug_decode   = node("xineplug_decode_*.so", "f");
node xineplug_ao       = node("xineplug_ao_*.so", "f");
node xineplug_vo       = node("xineplug_vo_*.so", "f");
node mime_types        = node("mime.types", "f");

v1_1_6.attach(vidix,
              post,
              xineplug_inp,
              xineplug_dmx,
              xineplug_decode,
              xineplug_ao,
              xineplug_vo,
              mime_types);

/* root/otvtarg/linux_xine/lib/xine/plugins/1.1.6/vidix */
node xine_vid_card_drvs   = node("*_vid.so", "f");
vidix.attach(xine_vid_card_drvs);

/* root/otvtarg/linux_xine/lib/xine/plugins/1.1.6/post */
node xineplug_post = node("xineplug_post_*.so", "f");
post.attach(xineplug_post);                                                       




