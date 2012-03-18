import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");



node Embedded_Debugging_Setup_003e3e80 = node("Embedded Debugging Setup", "d");
node Host_003e47b0                    = node("Host", "d");
node H2E_003e4460                     = node("Host to Emulator", "f");
node Emulator_003e2920                = node("Emulator", "d");
node E2T_003e3ec8                     = node("Emulator to Target", "f");
node Target_003e4f90                  = node("Target", "d");
Embedded_Debugging_Setup_003e3e80.attach(Host_003e47b0);
Embedded_Debugging_Setup_003e3e80.attach(H2E_003e4460);
Embedded_Debugging_Setup_003e3e80.attach(Emulator_003e2920);
Embedded_Debugging_Setup_003e3e80.attach(E2T_003e3ec8);
Embedded_Debugging_Setup_003e3e80.attach(Target_003e4f90);


node IDE_003e4c38                     = node("IDE", "d");
node Gdb_Frontend_003e4840            = node("Gdb Frontend", "d");
node Gdb_003e4810                     = node("Gdb", "d");
node Gdb_Server_003e4b90              = node("Gdb_Server", "d");
Host_003e47b0.attach(IDE_003e4c38);
Host_003e47b0.attach(Gdb_Frontend_003e4840);
Host_003e47b0.attach(Gdb_003e4810);
Host_003e47b0.attach(Gdb_Server_003e4b90);

node ADS_003e4c68                     = node("ADS", "d");
node RVDS_003e4f00                    = node("RVDS", "d");
IDE_003e4c38.attach(ADS_003e4c68);
IDE_003e4c38.attach(RVDS_003e4f00);

node DDD_003e4878                     = node("DDD", "d");
node Eclipse_Plugin_003e48a8          = node("Eclipse Plugin", "d");
node Insight_003e4b60                 = node("Insight", "d");
Gdb_Frontend_003e4840.attach(DDD_003e4878);
Gdb_Frontend_003e4840.attach(Eclipse_Plugin_003e48a8);
Gdb_Frontend_003e4840.attach(Insight_003e4b60);

node J_Link_Gdb_Server_003e4bc8       = node("J-Link Gdb Server", "d");
node OpenOCD_003e4c08                 = node("OpenOCD", "d");
Gdb_Server_003e4b90.attach(J_Link_Gdb_Server_003e4bc8);
Gdb_Server_003e4b90.attach(OpenOCD_003e4c08);





node Parallel_Interface_003e4490      = node("Parallel", "f");
node Twist_Pair_003e4748              = node("Twist Pair", "f");
node USB_003e4780                     = node("USB", "f");
H2E_003e4460.attach(Parallel_Interface_003e4490);
H2E_003e4460.attach(Twist_Pair_003e4748);
H2E_003e4460.attach(USB_003e4780);


node BDI1000_003e2958                 = node("BDI1000/2000/3000", "d");
node RealView_003e43e0                = node("RealView ICE", "d");
node Wiggler_003e4430                 = node("Wiggler", "d");
node J_Link_003e2a18                  = node("J-Link", "d");
node H_Link_003e29e8                  = node("H-Link", "d");
node U_Link_003e4400                  = node("U-Link", "d");
Emulator_003e2920.attach(BDI1000_003e2958);
Emulator_003e2920.attach(H_Link_003e29e8);
Emulator_003e2920.attach(J_Link_003e2a18);
Emulator_003e2920.attach(RealView_003e43e0);
Emulator_003e2920.attach(U_Link_003e4400);
Emulator_003e2920.attach(Wiggler_003e4430);



node JTAG_003e3ee8                    = node("JTAG", "f");
node SWD_003e28f0                     = node("SWD", "f");
E2T_003e3ec8.attach(JTAG_003e3ee8);
E2T_003e3ec8.attach(SWD_003e28f0);



node ARM_003e47e0                     = node("ARM", "d");
node MIPS_003e4f30                    = node("MIPS", "d");
node PPC_003e4f60                     = node("PPC", "d");
Target_003e4f90.attach(ARM_003e47e0);
Target_003e4f90.attach(MIPS_003e4f30);
Target_003e4f90.attach(PPC_003e4f60);







//change the following to draw_call_sequence() to produce call sequence.
picture root = draw_dir_tree(Embedded_Debugging_Setup_003e3e80);
attach(bbox(root, 2, 2, white), (0,0), SE);