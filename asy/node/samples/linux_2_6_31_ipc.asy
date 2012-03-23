import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node ipc_09f1f008                     = node("linux-2.6.31/ipc", "d");
node shm_c_09f27050                   = node("shm.c", "f");
node msgutil_c_09f27078               = node("msgutil.c", "f");
node mqueue_c_09f270a0                = node("mqueue.c", "f");
node util_h_09f270c8                  = node("util.h", "f");
node ipc_sysctl_c_09f270f0            = node("ipc_sysctl.c", "f");
node compat_c_09f27120                = node("compat.c", "f");
node compat_mq_c_09f27148             = node("compat_mq.c", "f");
node namespace_c_09f27170             = node("namespace.c", "f");
node msg_c_09f27198                   = node("msg.c", "f");
node Makefile_09f271c0                = node("Makefile", "f");
node ipcns_notifier_c_09f271e8        = node("ipcns_notifier.c", "f");
node mq_sysctl_c_09f27218             = node("mq_sysctl.c", "f");
node sem_c_09f27240                   = node("sem.c", "f");
node util_c_09f27268                  = node("util.c", "f");
ipc_09f1f008.attach(sem_c_09f27240);
ipc_09f1f008.attach(shm_c_09f27050);
ipc_09f1f008.attach(msg_c_09f27198);
ipc_09f1f008.attach(msgutil_c_09f27078);
ipc_09f1f008.attach(mqueue_c_09f270a0);
ipc_09f1f008.attach(util_h_09f270c8);
ipc_09f1f008.attach(util_c_09f27268);
ipc_09f1f008.attach(compat_c_09f27120);
ipc_09f1f008.attach(compat_mq_c_09f27148);
ipc_09f1f008.attach(namespace_c_09f27170);
ipc_09f1f008.attach(ipcns_notifier_c_09f271e8);
ipc_09f1f008.attach(ipc_sysctl_c_09f270f0);
ipc_09f1f008.attach(mq_sysctl_c_09f27218);
ipc_09f1f008.attach(Makefile_09f271c0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(ipc_09f1f008);
attach(bbox(root, 2, 2, white), (0,0), SE);
