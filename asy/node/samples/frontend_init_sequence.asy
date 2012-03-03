import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


node avl_frontend_init = node("avl_frontend_init()", "");
node avl_frontend_initialize = node("avl_frontend_initialize()", "");
node avl_frontend_open = node("avl_frontend_open(FE_BOARD_ADTMB, 0)", "");
avl_frontend_init.attach(avl_frontend_initialize, avl_frontend_open);

node adtmb_frontend_attach = node("adtmb_frontend_attach()", "");
avl_frontend_initialize.attach(adtmb_frontend_attach);

node op_adtmb_op = node("*op = \&adtmb_op", "");
adtmb_frontend_attach.attach(op_adtmb_op);

node fe_probe = node("fe_probe()", "");
node avl_mutex_lock = node("avl_mutex_lock()", "");
node op_init = node("op->init()", "");
node avl_mutex_unlock = node("avl_mutex_unlock()", "");
avl_frontend_open.attach(fe_probe, avl_mutex_lock, op_init, avl_mutex_unlock);

node adtmb_init = node("adtmb_init()", "");
op_init.attach(adtmb_init);

node AVL63X1_IBSP_Initialize = node("AVL63X1_IBSP_Initialize()", "");
node AVL63X1_reset = node("AVL63X1_reset(): empty function", "");
node AVL63X1_demod_init = node("AVL63X1_demod_init()", "");
node AVL63X1_init_tuner = node("AVL63X1_init_tuner()", "");
adtmb_init.attach(AVL63X1_IBSP_Initialize, 
                  AVL63X1_reset, 
				  AVL63X1_demod_init, 
				  AVL63X1_init_tuner);

node avl_i2c_open  = node("avl_i2c_open(I2C_BUS_2)", "");
AVL63X1_IBSP_Initialize.attach(avl_i2c_open);

node config_i2c_slave_addr = node("Config I2C slave address", "");
node AVL63X1_Initialize = node("AVL63X1_Initialize()", "");
node AVL63X1_SetAnalogAGC_Pola = node("AVL63X1_SetAnalogAGC_Pola()", "");
node AVL63X1_DriveIFAGC = node("AVL63X1_DriveIFAGC()", "");
node AVL63X1_SetMPEG_Mode = node("AVL63X1_SetMPEG_Mode()", "");
node AVL63X1_DriveMpegOutput = node("AVL63X1_DriveMpegOutput()", "");
AVL63X1_demod_init.attach(config_i2c_slave_addr, 
                          AVL63X1_Initialize, 
						  AVL63X1_SetAnalogAGC_Pola, 
						  AVL63X1_DriveIFAGC, 
						  AVL63X1_SetMPEG_Mode, 
						  AVL63X1_DriveMpegOutput);



node Init_ChipObject_63X1 = node("Init_ChipObject_63X1()", "");
node reset_demod_by_i2c = node("Reset Demod through I2C", "");
node IBase_Initialize_63X1 = node("IBase_Initialize_63X1()", "");
node AVL63X1_ISP_Delay = node("AVL63X1_ISP_Delay(300)", "");
node AVL63X1_CheckChipReady = node("AVL63X1_CheckChipReady()", "");
node IRx_Initialize_63X1 = node("IRx_Initialize_63X1()", "");
AVL63X1_Initialize.attach(Init_ChipObject_63X1, 
                          reset_demod_by_i2c, 
						  IBase_Initialize_63X1, 
						  AVL63X1_ISP_Delay, 
						  AVL63X1_CheckChipReady, 
						  IRx_Initialize_63X1);

node i2c_send_0 = node("II2C_Write32_63X1(0x38fffc, 0)", "");
node delay1 = node("AVL63X1_IBSP_Delay(1)", "");
node i2c_send_1 = node("II2C_Write32_63X1(0x38fffc, 1)", "");
node delay2 = node("AVL63X1_IBSP_Delay(1)", "");
reset_demod_by_i2c.attach(i2c_send_0,
                          delay1,
						  i2c_send_1,
						  delay2);						  
						  
node reset_c306 = node("Reset C306", "");
node config_pll = node("Config PLL", "");
node download_dtmb_fireware = node("Download DTMB Firmware", "");
node enable_c306 = node("Enable C306", "");
IBase_Initialize_63X1.attach(reset_c306, config_pll, download_dtmb_fireware, enable_c306);

picture root = draw_tree(avl_frontend_init, style=TREE_STYLE_STEP, gene_gap=40);
attach(bbox(root, 2, 2, white), (0,0), SE);

