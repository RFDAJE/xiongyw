

import fontsize;
import "node.asy" as node;

settings.tex = "xelatex";
 

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimSun}");


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
node file_etc                    = node("$\cdots$", "f");node N09cf6008 = node("../dirtree", "d");

node N09f4a008 = node("CO20100", "d");
node N09f52050 = node("bin", "d");
N09f4a008.attach(N09f52050);
node N09f52078 = node("ocod", "d");
node N09f5a0c0 = node("olib", "d");
N09f52078.attach(N09f5a0c0);
node N09f5a0e8 = node("cstartup", "d");
N09f52078.attach(N09f5a0e8);
node N09f5a110 = node("include", "d");
N09f52078.attach(N09f5a110);
node N09f5a138 = node("libgcc2.60", "d");
N09f52078.attach(N09f5a138);
N09f4a008.attach(N09f52078);
node N09f520a0 = node("make", "d");
N09f4a008.attach(N09f520a0);
node N09f520c8 = node("src", "d");
node N09f520f0 = node("browserglue", "d");
N09f520c8.attach(N09f520f0);
node N09f52118 = node("modem", "d");
N09f520c8.attach(N09f52118);
node N09f52140 = node("truecolor_hw16", "d");
N09f520c8.attach(N09f52140);
node N09f52170 = node("attribute", "d");
N09f520c8.attach(N09f52170);
node N09f52198 = node("dvbst", "d");
N09f520c8.attach(N09f52198);
node N09f521c0 = node("dvbrc", "d");
N09f520c8.attach(N09f521c0);
node N09f521e8 = node("farcir_q", "d");
N09f520c8.attach(N09f521e8);
node N09f52210 = node("encnone", "d");
N09f520c8.attach(N09f52210);
node N09f52238 = node("authnone", "d");
N09f520c8.attach(N09f52238);
node N09f52260 = node("fileman", "d");
N09f520c8.attach(N09f52260);
node N09f52288 = node("genhandle", "d");
N09f520c8.attach(N09f52288);
node N09f522b0 = node("rsa_cmp", "d");
N09f520c8.attach(N09f522b0);
node N09f522d8 = node("rsa_algae", "d");
N09f520c8.attach(N09f522d8);
node N09f52300 = node("sched", "d");
N09f520c8.attach(N09f52300);
node N09f52328 = node("svl", "d");
N09f520c8.attach(N09f52328);
node N09f52350 = node("fns_include", "d");
N09f520c8.attach(N09f52350);
node N09f52378 = node("rectutil", "d");
N09f520c8.attach(N09f52378);
node N09f523a0 = node("locale", "d");
N09f520c8.attach(N09f523a0);
node N09f523c8 = node("who", "d");
N09f520c8.attach(N09f523c8);
node N09f523f0 = node("interp", "d");
N09f520c8.attach(N09f523f0);
node N09f52418 = node("rsa_keys", "d");
N09f520c8.attach(N09f52418);
node N09f52440 = node("appstor", "d");
N09f520c8.attach(N09f52440);
node N09f52468 = node("debtrace", "d");
N09f520c8.attach(N09f52468);
node N09f52490 = node("dvb_si", "d");
N09f520c8.attach(N09f52490);
node N09f524b8 = node("blkmove", "d");
N09f520c8.attach(N09f524b8);
node N09f524e0 = node("uniconv", "d");
N09f520c8.attach(N09f524e0);
node N09f52508 = node("session_mgr", "d");
N09f520c8.attach(N09f52508);
node N09f52530 = node("streaming_indexer", "d");
N09f520c8.attach(N09f52530);
node N09f52560 = node("unisprintf", "d");
N09f520c8.attach(N09f52560);
node N09f52588 = node("ppplink", "d");
N09f520c8.attach(N09f52588);
node N09f525b0 = node("fep", "d");
N09f520c8.attach(N09f525b0);
node N09f525d8 = node("ieeefp", "d");
N09f520c8.attach(N09f525d8);
node N09f52600 = node("sf_transport", "d");
N09f520c8.attach(N09f52600);
node N09f52630 = node("gpinfo", "d");
N09f520c8.attach(N09f52630);
node N09f52658 = node("module", "d");
N09f520c8.attach(N09f52658);
node N09f52680 = node("gdboserl", "d");
N09f520c8.attach(N09f52680);
node N09f526a8 = node("osd", "d");
N09f520c8.attach(N09f526a8);
node N09f526d0 = node("gdbousck", "d");
N09f520c8.attach(N09f526d0);
node N09f526f8 = node("atsc_si", "d");
N09f520c8.attach(N09f526f8);
node N09f52720 = node("omm", "d");
N09f520c8.attach(N09f52720);
node N09f52748 = node("fns_rrinclude", "d");
N09f520c8.attach(N09f52748);
node N09f52778 = node("socket", "d");
N09f520c8.attach(N09f52778);
node N09f527a0 = node("popup", "d");
N09f520c8.attach(N09f527a0);
node N09f527c8 = node("md5", "d");
N09f520c8.attach(N09f527c8);
node N09f527f0 = node("legalese", "d");
N09f520c8.attach(N09f527f0);
node N09f52818 = node("scartsw", "d");
N09f520c8.attach(N09f52818);
node N09f52840 = node("tltxt", "d");
N09f520c8.attach(N09f52840);
node N09f52868 = node("resource", "d");
N09f520c8.attach(N09f52868);
node N09f52890 = node("svscale", "d");
N09f520c8.attach(N09f52890);
node N09f528b8 = node("ramfsys", "d");
N09f520c8.attach(N09f528b8);
node N09f528e0 = node("trackdb", "d");
N09f520c8.attach(N09f528e0);
node N09f52908 = node("pvr", "d");
N09f520c8.attach(N09f52908);
node N09f52930 = node("rtsp", "d");
N09f520c8.attach(N09f52930);
node N09f52958 = node("eits", "d");
N09f520c8.attach(N09f52958);
node N09f52980 = node("app_ocod", "d");
N09f520c8.attach(N09f52980);
node N09f529a8 = node("docsis_scm", "d");
N09f520c8.attach(N09f529a8);
node N09f529d0 = node("sysquery", "d");
N09f520c8.attach(N09f529d0);
node N09f529f8 = node("crypto", "d");
N09f520c8.attach(N09f529f8);
node N09f52a20 = node("epg", "d");
N09f520c8.attach(N09f52a20);
node N09f52a48 = node("display", "d");
N09f520c8.attach(N09f52a48);
node N09f52a70 = node("si", "d");
N09f520c8.attach(N09f52a70);
node N09f52a98 = node("decomp", "d");
N09f520c8.attach(N09f52a98);
node N09f52ac0 = node("dns", "d");
N09f520c8.attach(N09f52ac0);
node N09f52ae8 = node("crc_calc", "d");
N09f520c8.attach(N09f52ae8);
node N09f52b10 = node("rtclock", "d");
N09f520c8.attach(N09f52b10);
node N09f52b38 = node("bc_source", "d");
N09f520c8.attach(N09f52b38);
node N09f52b60 = node("cmod_ser", "d");
N09f520c8.attach(N09f52b60);
node N09f52b88 = node("crptold", "d");
node N09f52bb0 = node("crptnone", "d");
N09f52b88.attach(N09f52bb0);
node N09f52bd8 = node("crptotv", "d");
N09f52b88.attach(N09f52bd8);
N09f520c8.attach(N09f52b88);
node N09f52c00 = node("linkmgr", "d");
N09f520c8.attach(N09f52c00);
node N09f52c28 = node("ebn_otvstack", "d");
N09f520c8.attach(N09f52c28);
node N09f52c58 = node("manager", "d");
N09f520c8.attach(N09f52c58);
node N09f52c80 = node("truecolor_nonhw", "d");
N09f520c8.attach(N09f52c80);
node N09f52cb0 = node("string", "d");
N09f520c8.attach(N09f52cb0);
node N09f52cd8 = node("fns_ppp", "d");
N09f520c8.attach(N09f52cd8);
node N09f52d00 = node("mpeg2stk", "d");
N09f520c8.attach(N09f52d00);
node N09f52d28 = node("error", "d");
N09f520c8.attach(N09f52d28);
node N09f52d50 = node("fns_dhcp", "d");
N09f520c8.attach(N09f52d50);
node N09f52d78 = node("btree", "d");
N09f520c8.attach(N09f52d78);
node N09f52da0 = node("sgmr", "d");
N09f520c8.attach(N09f52da0);
node N09f52dc8 = node("unistr", "d");
N09f520c8.attach(N09f52dc8);
node N09f52df0 = node("iptuner", "d");
N09f520c8.attach(N09f52df0);
node N09f52e18 = node("crc32", "d");
N09f520c8.attach(N09f52e18);
node N09f52e40 = node("vkeyboard", "d");
N09f520c8.attach(N09f52e40);
node N09f52e68 = node("subtbl", "d");
N09f520c8.attach(N09f52e68);
node N09f52e90 = node("rsa_mem", "d");
N09f520c8.attach(N09f52e90);
node N09f52eb8 = node("ocodemon", "d");
N09f520c8.attach(N09f52eb8);
node N09f52ee0 = node("malloc", "d");
N09f520c8.attach(N09f52ee0);
node N09f52f08 = node("gdbonone", "d");
N09f520c8.attach(N09f52f08);
node N09f52f30 = node("smartcrd", "d");
N09f520c8.attach(N09f52f30);
node N09f52f58 = node("rsa_asn1src", "d");
N09f520c8.attach(N09f52f58);
node N09f52f80 = node("streamhdl", "d");
N09f520c8.attach(N09f52f80);
node N09f52fa8 = node("http", "d");
N09f520c8.attach(N09f52fa8);
node N09f52fd0 = node("tltxt_glue", "d");
N09f520c8.attach(N09f52fd0);
node N09f52ff8 = node("keyboard", "d");
N09f520c8.attach(N09f52ff8);
node N09f53020 = node("wakeup", "d");
N09f520c8.attach(N09f53020);
node N09f53048 = node("sfs", "d");
N09f520c8.attach(N09f53048);
node N09f53070 = node("security", "d");
N09f520c8.attach(N09f53070);
node N09f53098 = node("userprof", "d");
N09f520c8.attach(N09f53098);
node N09f530c0 = node("fns_stack", "d");
N09f520c8.attach(N09f530c0);
node N09f530e8 = node("xsi", "d");
N09f520c8.attach(N09f530e8);
node N09f53110 = node("rs_com", "d");
N09f520c8.attach(N09f53110);
node N09f53138 = node("memory", "d");
N09f520c8.attach(N09f53138);
node N09f53160 = node("fns_mcast", "d");
N09f520c8.attach(N09f53160);
node N09f53188 = node("svs_glue", "d");
N09f520c8.attach(N09f53188);
node N09f531b0 = node("putcraw", "d");
N09f520c8.attach(N09f531b0);
node N09f531d8 = node("rsa_asn1_inc", "d");
N09f520c8.attach(N09f531d8);
node N09f53208 = node("iptv", "d");
N09f520c8.attach(N09f53208);
node N09f53230 = node("vkeyboardglue", "d");
N09f520c8.attach(N09f53230);
node N09f53260 = node("cmod_com", "d");
N09f520c8.attach(N09f53260);
node N09f53288 = node("font16_glue", "d");
N09f520c8.attach(N09f53288);
node N09f532b0 = node("image_glue", "d");
N09f520c8.attach(N09f532b0);
node N09f532d8 = node("eventbrk", "d");
N09f520c8.attach(N09f532d8);
node N09f53300 = node("rtdrv", "d");
N09f520c8.attach(N09f53300);
node N09f53328 = node("avserv", "d");
N09f520c8.attach(N09f53328);
node N09f53350 = node("measure", "d");
N09f520c8.attach(N09f53350);
node N09f53378 = node("hdcp", "d");
N09f520c8.attach(N09f53378);
node N09f533a0 = node("resman", "d");
N09f520c8.attach(N09f533a0);
node N09f533c8 = node("fns_utils", "d");
N09f520c8.attach(N09f533c8);
node N09f533f0 = node("program", "d");
N09f520c8.attach(N09f533f0);
node N09f53418 = node("dsm", "d");
N09f520c8.attach(N09f53418);
node N09f53440 = node("recdest", "d");
N09f520c8.attach(N09f53440);
node N09f53468 = node("toolbox", "d");
N09f520c8.attach(N09f53468);
node N09f53490 = node("gdbosol", "d");
N09f520c8.attach(N09f53490);
node N09f534b8 = node("dvbpld", "d");
N09f520c8.attach(N09f534b8);
node N09f534e0 = node("hdmi", "d");
N09f520c8.attach(N09f534e0);
node N09f53508 = node("bitstreamglue", "d");
node N09f53538 = node("include", "d");
N09f53508.attach(N09f53538);
N09f520c8.attach(N09f53508);
node N09f53560 = node("handle", "d");
N09f520c8.attach(N09f53560);
node N09f53588 = node("rsa_include", "d");
N09f520c8.attach(N09f53588);
node N09f535b0 = node("natapp", "d");
N09f520c8.attach(N09f535b0);
node N09f535d8 = node("brdcast", "d");
N09f520c8.attach(N09f535d8);
node N09f53600 = node("rsa_algs", "d");
N09f520c8.attach(N09f53600);
node N09f53628 = node("uniuims", "d");
N09f520c8.attach(N09f53628);
node N09f53650 = node("credential", "d");
N09f520c8.attach(N09f53650);
node N09f53678 = node("pld", "d");
N09f520c8.attach(N09f53678);
node N09f536a0 = node("vkbfep", "d");
N09f520c8.attach(N09f536a0);
node N09f536c8 = node("main_tab", "d");
N09f520c8.attach(N09f536c8);
node N09f536f0 = node("prginfo", "d");
N09f520c8.attach(N09f536f0);
node N09f53718 = node("stornforw", "d");
N09f520c8.attach(N09f53718);
node N09f53740 = node("util", "d");
N09f520c8.attach(N09f53740);
node N09f53768 = node("recmed", "d");
N09f520c8.attach(N09f53768);
node N09f53790 = node("pld_glue", "d");
N09f520c8.attach(N09f53790);
node N09f537b8 = node("cir_q", "d");
N09f520c8.attach(N09f537b8);
node N09f537e0 = node("fmfile", "d");
N09f520c8.attach(N09f537e0);
node N09f53808 = node("rsa_libinc", "d");
N09f520c8.attach(N09f53808);
node N09f53830 = node("cmod_mdm", "d");
N09f520c8.attach(N09f53830);
node N09f53858 = node("http_mod_dl", "d");
N09f520c8.attach(N09f53858);
node N09f53880 = node("cpprotect", "d");
N09f520c8.attach(N09f53880);
node N09f538a8 = node("include", "d");
N09f520c8.attach(N09f538a8);
node N09f538d0 = node("image", "d");
N09f520c8.attach(N09f538d0);
node N09f538f8 = node("rsb", "d");
N09f520c8.attach(N09f538f8);
node N09f53920 = node("efemgr", "d");
N09f520c8.attach(N09f53920);
node N09f53948 = node("vod_ifc", "d");
N09f520c8.attach(N09f53948);
node N09f53970 = node("cstack", "d");
N09f520c8.attach(N09f53970);
node N09f53998 = node("streamer", "d");
N09f520c8.attach(N09f53998);
node N09f539c0 = node("relocate", "d");
N09f520c8.attach(N09f539c0);
node N09f539e8 = node("rsa_bhapi_inc", "d");
N09f520c8.attach(N09f539e8);
node N09f53a18 = node("ssl", "d");
N09f520c8.attach(N09f53a18);
node N09f53a40 = node("rawstk", "d");
N09f520c8.attach(N09f53a40);
node N09f53a68 = node("authrsa", "d");
N09f520c8.attach(N09f53a68);
node N09f53a90 = node("genclient", "d");
N09f520c8.attach(N09f53a90);
node N09f53ab8 = node("graphics", "d");
N09f520c8.attach(N09f53ab8);
node N09f53ae0 = node("sprintf", "d");
N09f520c8.attach(N09f53ae0);
node N09f53b08 = node("rsa_algae_inc", "d");
N09f520c8.attach(N09f53b08);
node N09f53b38 = node("pipeline", "d");
N09f520c8.attach(N09f53b38);
node N09f53b60 = node("otime", "d");
N09f520c8.attach(N09f53b60);
node N09f53b88 = node("pkg_glue", "d");
N09f520c8.attach(N09f53b88);
node N09f53bb0 = node("xyman", "d");
N09f520c8.attach(N09f53bb0);
node N09f53bd8 = node("connectivity_security", "d");
N09f520c8.attach(N09f53bd8);
node N09f53c10 = node("eefilsys", "d");
N09f520c8.attach(N09f53c10);
node N09f53c38 = node("pb_source", "d");
N09f520c8.attach(N09f53c38);
node N09f53c60 = node("copyrite", "d");
N09f520c8.attach(N09f53c60);
node N09f53c88 = node("psi_si", "d");
N09f520c8.attach(N09f53c88);
node N09f53cb0 = node("system", "d");
N09f520c8.attach(N09f53cb0);
node N09f53cd8 = node("dvbinfo", "d");
N09f520c8.attach(N09f53cd8);
node N09f53d00 = node("vkbenh", "d");
N09f520c8.attach(N09f53d00);
node N09f53d28 = node("xsocket", "d");
N09f520c8.attach(N09f53d28);
node N09f53d50 = node("cmodule", "d");
N09f520c8.attach(N09f53d50);
node N09f53d78 = node("ethernet", "d");
N09f520c8.attach(N09f53d78);
node N09f53da0 = node("gendest", "d");
N09f520c8.attach(N09f53da0);
node N09f53dc8 = node("dest_glue", "d");
N09f520c8.attach(N09f53dc8);
node N09f53df0 = node("rsa_support", "d");
N09f520c8.attach(N09f53df0);
node N09f53e18 = node("gnplink", "d");
N09f520c8.attach(N09f53e18);
node N09f53e40 = node("rsa_bsrc_inc", "d");
N09f520c8.attach(N09f53e40);
node N09f53e70 = node("modemsvc", "d");
N09f520c8.attach(N09f53e70);
node N09f53e98 = node("mhp_glue", "d");
N09f520c8.attach(N09f53e98);
node N09f53ec0 = node("fonts", "d");
N09f520c8.attach(N09f53ec0);
node N09f53ee8 = node("appman", "d");
N09f520c8.attach(N09f53ee8);
node N09f53f10 = node("gdboraw", "d");
N09f520c8.attach(N09f53f10);
node N09f53f38 = node("serieslinkmgr", "d");
N09f520c8.attach(N09f53f38);
node N09f53f68 = node("unigraphics", "d");
N09f520c8.attach(N09f53f68);
node N09f53f90 = node("pbmed", "d");
N09f520c8.attach(N09f53f90);
node N09f53fb8 = node("uims", "d");
N09f520c8.attach(N09f53fb8);
node N09f53fe0 = node("gdbosun", "d");
N09f520c8.attach(N09f53fe0);
node N09f54008 = node("fns_config", "d");
N09f520c8.attach(N09f54008);
node N09f54030 = node("fns_routing", "d");
N09f520c8.attach(N09f54030);
node N09f54058 = node("truecolor_hw32", "d");
N09f520c8.attach(N09f54058);
node N09f54088 = node("vod_source", "d");
N09f520c8.attach(N09f54088);
node N09f540b0 = node("vod_medium", "d");
N09f520c8.attach(N09f540b0);
N09f4a008.attach(N09f520c8);
picture root = draw_tree(N09f4a008, dir_draw_func, style=TREE_STYLE_FLAT, gene_gap=40, show_collapse_icon=true);
attach(root.fit(), (0,0), SE);
