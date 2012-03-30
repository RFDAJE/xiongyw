import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node arch_09351008                    = node("linux-2.6.31/arch", "d");
node sh_09359050                      = node("sh", "d");
node mips_09361ba0                    = node("mips", "d");
node um_09363018                      = node("um", "d");
node mn10300_09363478                 = node("mn10300", "d");
node sparc_093637b0                   = node("sparc", "d");
node m68knommu_09363968               = node("m68knommu", "d");
node parisc_09363cd8                  = node("parisc", "d");
node ia64_09363e68                    = node("ia64", "d");
node microblaze_093643b8              = node("microblaze", "d");
node m68k_09364570                    = node("m68k", "d");
node h8300_09364958                   = node("h8300", "d");
node arm_09364c00                     = node("arm", "d");
node frv_09366968                     = node("frv", "d");
node powerpc_09366ab0                 = node("powerpc", "d");
node alpha_09367258                   = node("alpha", "d");
node x86_093673e8                     = node("x86", "d");
node m32r_09367910                    = node("m32r", "d");
node s390_09367cd0                    = node("s390", "d");
node cris_09367f50                    = node("cris", "d");
node xtensa_09368608                  = node("xtensa", "d");
node avr32_09368b10                   = node("avr32", "d");
node blackfin_09368e80                = node("blackfin", "d");
arch_09351008.attach(arm_09364c00);
arch_09351008.attach(x86_093673e8);
arch_09351008.attach(ia64_09363e68);
arch_09351008.attach(mips_09361ba0);
arch_09351008.attach(powerpc_09366ab0);
arch_09351008.attach(alpha_09367258);
arch_09351008.attach(sparc_093637b0);
arch_09351008.attach(sh_09359050);
arch_09351008.attach(avr32_09368b10);
arch_09351008.attach(blackfin_09368e80);
arch_09351008.attach(m68k_09364570);
arch_09351008.attach(m68knommu_09363968);
arch_09351008.attach(um_09363018);
arch_09351008.attach(mn10300_09363478);
arch_09351008.attach(parisc_09363cd8);
arch_09351008.attach(microblaze_093643b8);
arch_09351008.attach(h8300_09364958);
arch_09351008.attach(frv_09366968);
arch_09351008.attach(m32r_09367910);
arch_09351008.attach(s390_09367cd0);
arch_09351008.attach(cris_09367f50);
arch_09351008.attach(xtensa_09368608);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(arch_09351008);
attach(bbox(root, 2, 2, white), (0,0), SE);
