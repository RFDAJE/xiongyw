import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node linux_2_6_31_08611008            = node("linux-2.6.31", "d");
node kernel_08619058                  = node("kernel", "d");
node virt_08619080                    = node("virt", "d");
node include_086190d0                 = node("include", "d");
node net_08619ca8                     = node("net", "d");
node init_0861a680                    = node("init", "d");
node block_0861a6a8                   = node("block", "d");
node mm_0861a6d0                      = node("mm", "d");
node security_0861a6f8                = node("security", "d");
node fs_0861a860                      = node("fs", "d");
node lib_0861b440                     = node("lib", "d");
node firmware_0861b520                = node("firmware", "d");
node ipc_0861ba28                     = node("ipc", "d");
node drivers_0861ba50                 = node("drivers", "d");
node Documentation_0861fea0           = node("Documentation", "d");
node usr_08629238                     = node("usr", "d");
node scripts_08629260                 = node("scripts", "d");
node arch_08629490                    = node("arch", "d");
node sound_08639ae8                   = node("sound", "d");
node tools_0863a858                   = node("tools", "d");
node samples_0863a978                 = node("samples", "d");
node crypto_0863aa70                  = node("crypto", "d");

linux_2_6_31_08611008.attach(include_086190d0);
linux_2_6_31_08611008.attach(arch_08629490);
linux_2_6_31_08611008.attach(kernel_08619058);
linux_2_6_31_08611008.attach(mm_0861a6d0);
linux_2_6_31_08611008.attach(init_0861a680);
linux_2_6_31_08611008.attach(ipc_0861ba28);
linux_2_6_31_08611008.attach(block_0861a6a8);
linux_2_6_31_08611008.attach(fs_0861a860);
linux_2_6_31_08611008.attach(net_08619ca8);
linux_2_6_31_08611008.attach(drivers_0861ba50);
linux_2_6_31_08611008.attach(security_0861a6f8);
linux_2_6_31_08611008.attach(crypto_0863aa70);
linux_2_6_31_08611008.attach(sound_08639ae8);
linux_2_6_31_08611008.attach(lib_0861b440);
linux_2_6_31_08611008.attach(firmware_0861b520);
linux_2_6_31_08611008.attach(usr_08629238);
linux_2_6_31_08611008.attach(scripts_08629260);
linux_2_6_31_08611008.attach(tools_0863a858);
linux_2_6_31_08611008.attach(samples_0863a978);
linux_2_6_31_08611008.attach(virt_08619080);
linux_2_6_31_08611008.attach(Documentation_0861fea0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(linux_2_6_31_08611008);
attach(bbox(root, 2, 2, white), (0,0), SE);
