import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node security_0968d008                = node("linux-2.6.31/security", "d");
node tomoyo_09695050                  = node("tomoyo", "d");
node smack_09695078                   = node("smack", "d");
node keys_096950a0                    = node("keys", "d");
node integrity_096950c8               = node("integrity", "d");
node selinux_096950f0                 = node("selinux", "d");
security_0968d008.attach(keys_096950a0);
security_0968d008.attach(smack_09695078);
security_0968d008.attach(tomoyo_09695050);
security_0968d008.attach(selinux_096950f0);
security_0968d008.attach(integrity_096950c8);

node ima_0969d110                     = node("ima", "d");
integrity_096950c8.attach(ima_0969d110);

node include_09695118                 = node("include", "d");
node ss_09695140                      = node("ss", "d");
selinux_096950f0.attach(ss_09695140);
selinux_096950f0.attach(include_09695118);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(security_0968d008);
attach(bbox(root, 2, 2, white), (0,0), SE);
