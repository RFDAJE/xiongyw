import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node include_08082008                 = node("linux-2.6.31/include", "d");
node video_0808a050                   = node("video", "d");
node acpi_0808a078                    = node("acpi", "d");
node net_0808a0a0                     = node("net", "d");
node trace_0808a2d0                   = node("trace", "d");
node asm_generic_0808a320             = node("asm-generic", "d");
node rdma_0808a370                    = node("rdma", "d");
node pcmcia_0808a398                  = node("pcmcia", "d");
node xen_0808a3c0                     = node("xen", "d");
node math_emu_0808a438                = node("math-emu", "d");
node mtd_0808a460                     = node("mtd", "d");
node rxrpc_0808a488                   = node("rxrpc", "d");
node media_0808a4b0                   = node("media", "d");
node keys_0808a4d8                    = node("keys", "d");
node linux_0808a500                   = node("linux", "d");
node sound_0808aac0                   = node("sound", "d");
node drm_0808aae8                     = node("drm", "d");
node scsi_0808ab38                    = node("scsi", "d");
node crypto_0808ab88                  = node("crypto", "d");
include_08082008.attach(asm_generic_0808a320);
include_08082008.attach(linux_0808a500);
include_08082008.attach(video_0808a050);
include_08082008.attach(sound_0808aac0);
include_08082008.attach(scsi_0808ab38);
include_08082008.attach(acpi_0808a078);
include_08082008.attach(net_0808a0a0);
include_08082008.attach(mtd_0808a460);
include_08082008.attach(pcmcia_0808a398);
include_08082008.attach(trace_0808a2d0);
include_08082008.attach(rdma_0808a370);
include_08082008.attach(xen_0808a3c0);
include_08082008.attach(math_emu_0808a438);
include_08082008.attach(rxrpc_0808a488);
include_08082008.attach(media_0808a4b0);
include_08082008.attach(keys_0808a4d8);
include_08082008.attach(drm_0808aae8);
include_08082008.attach(crypto_0808ab88);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(include_08082008);
attach(bbox(root, 2, 2, white), (0,0), SE);
