import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node sound_08260008                   = node("linux-2.6.31/sound", "d");
node sh_08268050                      = node("sh", "d");
node mips_08268078                    = node("mips", "d");
node sparc_082680a0                   = node("sparc", "d");
node soc_082680c8                     = node("soc", "d");
node parisc_082680f0                  = node("parisc", "d");
node oss_08268118                     = node("oss", "d");
node synth_08268168                   = node("synth", "d");
node arm_082681b8                     = node("arm", "d");
node ppc_082681e0                     = node("ppc", "d");
node core_08268208                    = node("core", "d");
node pcmcia_082682a8                  = node("pcmcia", "d");
node i2c_08268320                     = node("i2c", "d");
node drivers_08268370                 = node("drivers", "d");
node aoa_08268460                     = node("aoa", "d");
node spi_08268550                     = node("spi", "d");
node usb_08268578                     = node("usb", "d");
node isa_082685f0                     = node("isa", "d");
node pci_082687a8                     = node("pci", "d");
node atmel_08268b90                   = node("atmel", "d");
sound_08260008.attach(aoa_08268460);
sound_08260008.attach(arm_082681b8);
sound_08260008.attach(atmel_08268b90);
sound_08260008.attach(core_08268208);
sound_08260008.attach(drivers_08268370);
sound_08260008.attach(i2c_08268320);
sound_08260008.attach(isa_082685f0);
sound_08260008.attach(mips_08268078);
sound_08260008.attach(oss_08268118);
sound_08260008.attach(pci_082687a8);
sound_08260008.attach(ppc_082681e0);
sound_08260008.attach(pcmcia_082682a8);
sound_08260008.attach(parisc_082680f0);
sound_08260008.attach(spi_08268550);
sound_08260008.attach(sparc_082680a0);
sound_08260008.attach(soc_082680c8);
sound_08260008.attach(synth_08268168);
sound_08260008.attach(sh_08268050);
sound_08260008.attach(usb_08268578);


//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(sound_08260008);
attach(bbox(root, 2, 2, white), (0,0), SE);
