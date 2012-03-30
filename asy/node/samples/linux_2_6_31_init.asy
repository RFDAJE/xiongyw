import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node init_09007008                    = node("linux-2.6.31/init", "d");
node noinitramfs_c_0900f050           = node("noinitramfs.c", "f");
node do_mounts_md_c_0900f080          = node("do_mounts_md.c", "f");
node calibrate_c_0900f0b0             = node("calibrate.c", "f");
node initramfs_c_0900f0d8             = node("initramfs.c", "f");
node Makefile_0900f100                = node("Makefile", "f");
node do_mounts_c_0900f128             = node("do_mounts.c", "f");
node do_mounts_initrd_c_0900f150      = node("do_mounts_initrd.c", "f");
node Kconfig_0900f180                 = node("Kconfig", "f");
node do_mounts_rd_c_0900f1a8          = node("do_mounts_rd.c", "f");
node do_mounts_h_0900f1d8             = node("do_mounts.h", "f");
node version_c_0900f200               = node("version.c", "f");
node main_c_0900f228                  = node("main.c", "f");
init_09007008.attach(main_c_0900f228);
init_09007008.attach(calibrate_c_0900f0b0);
init_09007008.attach(noinitramfs_c_0900f050);
init_09007008.attach(initramfs_c_0900f0d8);
init_09007008.attach(do_mounts_h_0900f1d8);
init_09007008.attach(do_mounts_c_0900f128);
init_09007008.attach(do_mounts_initrd_c_0900f150);
init_09007008.attach(do_mounts_md_c_0900f080);
init_09007008.attach(do_mounts_rd_c_0900f1a8);
init_09007008.attach(version_c_0900f200);
init_09007008.attach(Kconfig_0900f180);
init_09007008.attach(Makefile_0900f100);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(init_09007008);
attach(bbox(root, 2, 2, white), (0,0), SE);
