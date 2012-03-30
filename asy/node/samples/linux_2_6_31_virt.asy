import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node virt_093d1008                    = node("linux-2.6.31/virt", "d");
node kvm_093d9050                     = node("kvm", "d");
virt_093d1008.attach(kvm_093d9050);
node kvm_main_c_093e1098              = node("kvm_main.c", "f");
node kvm_trace_c_093e10c0             = node("kvm_trace.c", "f");
node iommu_c_093e10e8                 = node("iommu.c", "f");
node ioapic_c_093e1110                = node("ioapic.c", "f");
node ioapic_h_093e1138                = node("ioapic.h", "f");
node irq_comm_c_093e1160              = node("irq_comm.c", "f");
node iodev_h_093e1188                 = node("iodev.h", "f");
node coalesced_mmio_h_093e11b0        = node("coalesced_mmio.h", "f");
node coalesced_mmio_c_093e11e0        = node("coalesced_mmio.c", "f");
kvm_093d9050.attach(kvm_main_c_093e1098);
kvm_093d9050.attach(kvm_trace_c_093e10c0);
kvm_093d9050.attach(iommu_c_093e10e8);
kvm_093d9050.attach(ioapic_c_093e1110);
kvm_093d9050.attach(ioapic_h_093e1138);
kvm_093d9050.attach(irq_comm_c_093e1160);
kvm_093d9050.attach(iodev_h_093e1188);
kvm_093d9050.attach(coalesced_mmio_h_093e11b0);
kvm_093d9050.attach(coalesced_mmio_c_093e11e0);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(virt_093d1008);
attach(bbox(root, 2, 2, white), (0,0), SE);
