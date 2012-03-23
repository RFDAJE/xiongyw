import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node kernel_09b90008                  = node("linux-2.6.31/kernel", "d");
node power_09b98050                   = node("power", "d");
node trace_09b98078                   = node("trace", "d");
node gcov_09b980a0                    = node("gcov", "d");
node time_09b980c8                    = node("time", "d");
node irq_09b980f0                     = node("irq", "d");
kernel_09b90008.attach(power_09b98050);
kernel_09b90008.attach(trace_09b98078);
kernel_09b90008.attach(gcov_09b980a0);
kernel_09b90008.attach(time_09b980c8);
kernel_09b90008.attach(irq_09b980f0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(kernel_09b90008);
attach(bbox(root, 2, 2, white), (0,0), SE);
