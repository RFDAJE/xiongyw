/* created(bruin, 2007-05-08): call sequence in SKPTV demo build using S3 CLTV
 *
 * last modfied(bruin, 2007-05-08)
 * $Id$
 */

import fontsize;

texpreamble("\usepackage{amssymb,amsmath,mathrsfs}
             %\usepackage{CJK}
             %\newcommand{\myfrac}[2]{\,$\mathrm{{^{#1}}\!\!\diagup\!\!{_{#2}}}$\,}
             %\newcommand{\myfrac}[2]{#1\!/\!#2}
             %\newcommand{\cwave}{бл}
             %\newcommand{\song}{\CJKfamily{song}}
             %\newcommand{\fs}{\CJKfamily{fs}}
             %\newcommand{\hei}{\CJKfamily{hei}}
             %\newcommand{\kai}{\CJKfamily{kai}}
             %\AtBeginDocument{\begin{CJK*}{GBK}{hei}}
             %\AtEndDocument{\clearpage\end{CJK*}}"
            );

/* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);

real   font_size = 10;      /* font size */
real   connect_width = 2font_size;  /* connection betw. callee and caller */
pair   se=0.000001SE;         /* used for alignment for picture attach() */

defaultpen(/*font("cmr12") + */fontsize(font_size));
pen line_pen = linewidth(0.8) + black + linecap(0); /* square cap */
pen name_pen = linewidth(0.1) + black + fontsize(font_size);

/* st/s3/otv/tmm */
string st = "st";
string s3 = "s3";
string otv = "otv";
string tmm = "tmm";

/* match the color with the diagram in original SRS document by martin */
pen fill_pen_st  = rgb(153, 204, 255);
pen fill_pen_s3  = rgb(204, 153, 255);
pen fill_pen_otv = rgb(204, 255, 204);
pen fill_pen_tmm = white;


/* function: a node in call tree */
struct function{
	string   func_name;
	string   impl_by;   /* name of the company to implement this func */

	function   called_by;
	function   calls;    /* first child; null if leaf */
	function   lsib;   /* left sibling; null if first calls */
	function   rsib;   /* right sibling; null if last calls */
	

	/* default constructor for function */
	static function function(string func_name, string impl_by){
	
		function p = new function;
		/* function name may contains '_' which is reserved by Tex */
		p.func_name = replace(func_name, "_", "\_"); 
		p.impl_by = impl_by;
		
		p.called_by = null;
		p.calls = null;
		p.lsib = null;
		p.rsib = null;
		
		return p;
	}

	bool calls(function called,  function lsib=null){     /* the left sibling of this calls; null if the 1st calls */
	                
		called.called_by = this;
		called.lsib = lsib;
		
		if(called.lsib != null){
			lsib.rsib = called;
		}
		else{
			this.calls = called;
			/* we suppose it's also the first calls of the called_by */
			if(called.called_by != null)
				called.called_by.calls = called;
		}
		
		return true;
	}
};

picture draw_function(function p){
	picture pic;
	filltype fill;

	if(p.impl_by == st){
		fill = FillDraw(fill_pen_st);
	}else if(p.impl_by == s3){
		fill = FillDraw(fill_pen_s3);
	}else if(p.impl_by == otv){
		fill = FillDraw(fill_pen_otv);
	}else if(p.impl_by == tmm){
		//fill = Fill(ymargin=1, fill_pen_tmm);
		fill=FillDraw(fill_pen_tmm);
	}else{
		fill = NoFill;
	}
	
/*	
	label(pic, 
	    //minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox["+format("%d", (int)width)+"bp][s]{"+p.func_name + p.given_name + "}\\[2pt]\tiny" + p.born_at + "бл" + p.dead_at, width), 
	    //  (p.born_at == question && p.dead_at == question)?
	    //  minipage(((p.sex!=true)?"\kai":"\hei")+"\makebox[\textwidth][s]{"+p.func_name + p.given_name + "}"                                            , width) :
	      "\texttt{"+p.func_name+"}", 
	      (0, 0), 
	      name_pen,
	      fill);
*/
	draw(pic, "\texttt{"+p.func_name+"}", box,(0,0),1,black,fill);

	return pic;
}

/* get the picture size */
pair pic_size(picture pic){
	pair min, max;
	//min = min(bbox(pic));
	//max = max(bbox(pic));
	min = min(pic);
	max = max(pic);
	//write(min);
	//write(max);
	pair size=(max.x - min.x, max.y - min.y);
	return size;
}

/* get the frame size */
pair frame_size(frame f){
	pair max=max(f);
	pair min=min(f);
	pair size=(max.x - min.x, max.y - min.y);
	return size;
}

picture draw_tree(function root){

	picture pic, self, spouse;
	function calls;

	if(root != null){
	
		self = draw_function(root);
		attach(pic, self.fit(), (0, 0), se);

		//real xgap = width*2;
		real xgap = pic_size(self).x + connect_width;
		real ygap = 0;
		for(calls = root.calls; calls != null; calls = calls.rsib){

			/* draw connection lines */			
			pair self_right = (pic_size(self).x, - font_size / 2);
			pair middle = self_right + (connect_width/2, 0);
			draw(pic, self_right--middle--(middle+(0,ygap))--(self_right+(connect_width,ygap)), line_pen);
			
			/* draw calls pic and attach it */
			picture k = draw_tree(calls);
			attach(pic, k.fit(), (xgap, ygap), se);
			
			
			ygap -= pic_size(k).y + 6;
		}

	}
	
	return pic;
}

/* legend in the lower left corner of the picture */
void add_legend(picture pic){
	real y = -pic_size(pic).y - 30;
  label(pic, "Legend:\quad", (0,y+2), 0.001SE, NoFill);

	draw(pic, "\texttt{\quad THOMSON\quad}",        box, (8font_size,y),  2, black, FillDraw(fill_pen_tmm));
	draw(pic, "\texttt{\quad ST: STAPI/OS21\quad}", box, (18font_size,y), 2, black, FillDraw(fill_pen_st));
	draw(pic, "\texttt{\quad S3: CLTV\quad}",       box, (28font_size,y), 2, black, FillDraw(fill_pen_s3));
	draw(pic, "\texttt{\quad OTV: CORE/NP\quad}",   box, (38font_size,y), 2, black, FillDraw(fill_pen_otv));

	label(pic, "\texttt{func(*)}: to be customized or needs customized parameter(s).", (4font_size,y-20), 0.001SE, NoFill);
	label(pic, "\texttt{func(?)}: the call is optional or customizable.", (4font_size,y-30), 0.001SE, NoFill);
	label(pic, "\texttt{func(!)}: a separate task been forked to execute this function", (4font_size,y-40), 0.001SE, NoFill);
	label(pic, "\texttt{func(;)}: the func been called in a loop", (4font_size,y-50), 0.001SE, NoFill);
	label(pic, "\texttt{func(;;)}: the func been called in an infinite loop", (4font_size,y-60), 0.001SE, NoFill);
	//label(pic, "\texttt{func()=>}: the function forks other task(s)", (4font_size,y-50), 0.001SE, NoFill);
}

void add_legend_2(picture pic){
	real y = -pic_size(pic).y - 30;

  label(pic, "Legend:\quad", (0,y+2), 0.001SE, NoFill);
  
	draw(pic, "\texttt{\quad THOMSON\quad}",        box, (8font_size,y),  2, black, FillDraw(fill_pen_tmm));
	draw(pic, "\texttt{\quad ST: STAPI/OS21\quad}", box, (18font_size,y), 2, black, FillDraw(fill_pen_st));
	draw(pic, "\texttt{\quad S3: CLTV\quad}",       box, (28font_size,y), 2, black, FillDraw(fill_pen_s3));
	draw(pic, "\texttt{\quad OTV: CORE/NP\quad}",   box, (38font_size,y), 2, black, FillDraw(fill_pen_otv));
}

/* ################ functions and calls ################ */
function misc                     = function.function("......", "unknown");

function main                     = function.function("main()", "tmm");
function board_init               = function.function("board_init()", "tmm");
function task_priority_set        = function.function("task_priority_set()", "st");
function control_task_main        = function.function("control_task_main(!)", "otv");
function STAL_KPI_KernelMonitor  = function.function("STAL_KPI_KernelMonitor()", "s3");

main.calls(board_init);
main.calls(task_priority_set, board_init);
main.calls(control_task_main, task_priority_set);
main.calls(STAL_KPI_KernelMonitor, control_task_main);


function STAL_Init                = function.function("STAL_Init()", "s3");
function STAL_KPI_Register        = function.function("STAL_KPI_Register()", "s3");
board_init.calls(STAL_Init);
board_init.calls(STAL_KPI_Register, STAL_Init);

function HAL_INIT_GetConfig       = function.function("HAL_INIT_GetConfig()", "tmm");
function STAL_SYS_Register        = function.function("STAL_SYS_Register()", "s3");
function HAL_INIT_Init            = function.function("HAL_INIT_Init()", "tmm");
STAL_Init.calls(HAL_INIT_GetConfig);
STAL_Init.calls(STAL_SYS_Register, HAL_INIT_GetConfig);
STAL_Init.calls(HAL_INIT_Init, STAL_SYS_Register);

function InitStBoot                = function.function("InitStBoot()", "tmm");
function InitStPio                 = function.function("InitStPio()", "tmm");
function InitStUART                = function.function("InitStUART(*)", "tmm");
function InitStEvt                 = function.function("InitStEvt()", "tmm");
function InitStMerge               = function.function("InitStMerge(*)", "tmm");
function InitStFdma                = function.function("InitStFdma()", "tmm");
function InitStAvmem               = function.function("InitStAvmem()", "tmm");
function InitStAvmem2              = function.function("InitStAvmem2()", "tmm");
function InitStI2c                 = function.function("InitStI2c(*)", "tmm");
function InitStClkrv               = function.function("InitStClkrv()", "tmm");
function InitStDenc                = function.function("InitStDenc(*)", "tmm");
function InitStVtg                 = function.function("InitStVtg(*)", "tmm");
function InitStVout                = function.function("InitStVout(*)", "tmm");
function InitStAud                 = function.function("InitStAud()", "tmm");
function InitStBlit                = function.function("InitStBlit()", "tmm");
HAL_INIT_Init.calls(InitStBoot);
HAL_INIT_Init.calls(InitStPio, InitStBoot);
HAL_INIT_Init.calls(InitStUART, InitStPio);
HAL_INIT_Init.calls(InitStEvt, InitStUART);
HAL_INIT_Init.calls(InitStMerge, InitStEvt);
HAL_INIT_Init.calls(InitStFdma, InitStMerge);
HAL_INIT_Init.calls(InitStAvmem, InitStFdma);
HAL_INIT_Init.calls(InitStAvmem2, InitStAvmem);
HAL_INIT_Init.calls(InitStI2c, InitStAvmem2);
HAL_INIT_Init.calls(InitStClkrv, InitStI2c);
HAL_INIT_Init.calls(InitStDenc, InitStClkrv);
HAL_INIT_Init.calls(InitStVtg, InitStDenc);
HAL_INIT_Init.calls(InitStVout, InitStVtg);
HAL_INIT_Init.calls(InitStAud, InitStVout);
HAL_INIT_Init.calls(InitStBlit, InitStAud);

function STBOOT_Init               = function.function("STBOOT_Init()", "s3");
InitStBoot.calls(STBOOT_Init);

function kernel_initialize         = function.function("kernel_initialize()", "st");
function kernel_start              = function.function("kernel_start()", "st");
STBOOT_Init.calls(kernel_initialize);
STBOOT_Init.calls(kernel_start, kernel_initialize);

function STPIO_InitNoReset         = function.function("STPIO_InitNoReset()", "st");
InitStPio.calls(STPIO_InitNoReset);

function STUART_Init               = function.function("STUART_Init()", "st");
function STTBX_Init                = function.function("STTBX_Init()", "st");
InitStUART.calls(STUART_Init);
InitStUART.calls(STTBX_Init, STUART_Init);

function STEVT_Init                = function.function("STEVT_Init()", "st");
function STEVT_Open                = function.function("STEVT_Open()", "st");
InitStEvt.calls(STEVT_Init);
InitStEvt.calls(STEVT_Open, STEVT_Init);

function ST_GetClockInfo           = function.function("ST_GetClockInfo()", "st");
function STMERGE_Init              = function.function("STMERGE_Init()", "st");
function STMERGE_SetParams         = function.function("STMERGE_SetParams(*)", "st");
function STMERGE_Connect           = function.function("STMERGE_Connect(?)", "st");

InitStMerge.calls(ST_GetClockInfo);
InitStMerge.calls(STMERGE_Init, ST_GetClockInfo);
InitStMerge.calls(STMERGE_SetParams, STMERGE_Init);
InitStMerge.calls(STMERGE_Connect, STMERGE_SetParams);

function ST_GetClocksPerSecond      = function.function("ST_GetClocksPerSecond()", "st");
function STFDMA_Init                = function.function("STFDMA_Init()", "st");
InitStFdma.calls(ST_GetClocksPerSecond);
InitStFdma.calls(STFDMA_Init, ST_GetClocksPerSecond);

function STAVMEM_Init               = function.function("STAVMEM_Init()", "st");
function STAVMEM_CreatePartition    = function.function("STAVMEM_CreatePartition()", "st");
InitStAvmem.calls(STAVMEM_Init);
InitStAvmem.calls(STAVMEM_CreatePartition, STAVMEM_Init);
InitStAvmem2.calls(STAVMEM_Init);
InitStAvmem2.calls(STAVMEM_CreatePartition, STAVMEM_Init);

function STI2C_Init_0                 = function.function("STI2C_Init(0)", "st");
function STI2C_Init_1                 = function.function("STI2C_Init(1)", "st");
function STI2C_Init_2                 = function.function("STI2C_Init(*)", "st");
InitStI2c.calls(ST_GetClockInfo);
InitStI2c.calls(STI2C_Init_0, ST_GetClockInfo);
InitStI2c.calls(STI2C_Init_1, STI2C_Init_0);
InitStI2c.calls(STI2C_Init_2, STI2C_Init_1);

function STVTG_Init                   = function.function("STVTG_Init(hd)", "st");
function STVTG_Open                   = function.function("STVTG_Open(hd)", "st");
function STVTG_SetMode                = function.function("STVTG_SetMode(hd)", "st");
function STVTG_SetOptionalConfiguration = function.function("STVTG_SetOptionalConfiguration(hd)", "st");
function STVTG_Init_sd                = function.function("STVTG_Init(sd)", "st");
function STVTG_Open_sd                = function.function("STVTG_Open(sd)", "st");
function STVTG_SetMode_sd             = function.function("STVTG_SetMode(sd)", "st");
InitStVtg.calls(STVTG_Init);
InitStVtg.calls(STVTG_Open, STVTG_Init);
InitStVtg.calls(STVTG_SetMode, STVTG_Open);
InitStVtg.calls(STVTG_SetOptionalConfiguration, STVTG_SetMode);
InitStVtg.calls(STVTG_Init_sd, STVTG_SetOptionalConfiguration);
InitStVtg.calls(STVTG_Open_sd, STVTG_Init_sd);
InitStVtg.calls(STVTG_SetMode_sd, STVTG_Open_sd);

function STCLKRV_Init                 = function.function("STCLKRV_Init()", "st");
function STCLKRV_Open                 = function.function("STCLKRV_Open()", "st");
function STCLKRV_SetSTCSource         = function.function("STCLKRV_SetSTCSource()", "st");
function STCLKRV_SetSTCOffset         = function.function("STCLKRV_SetSTCOffset()", "st");
function STCLKRV_InvDecodeClk         = function.function("STCLKRV_InvDecodeClk()", "st");
function STCLKRV_SetApplicationMode   = function.function("STCLKRV_SetApplicationMode()", "st");
function STCLKRV_Enable               = function.function("STCLKRV_Enable()", "st");
InitStClkrv.calls(STCLKRV_Init);
InitStClkrv.calls(STCLKRV_Open, STCLKRV_Init);
InitStClkrv.calls(STCLKRV_SetSTCSource, STCLKRV_Open);
InitStClkrv.calls(STCLKRV_SetSTCOffset, STCLKRV_SetSTCSource);
InitStClkrv.calls(STCLKRV_InvDecodeClk, STCLKRV_SetSTCOffset); 
InitStClkrv.calls(STCLKRV_SetApplicationMode, STCLKRV_InvDecodeClk);
InitStClkrv.calls(STCLKRV_Enable, STCLKRV_SetApplicationMode);

function STDENC_Init                  = function.function("STDENC_Init()", "st");
function STDENC_Open                  = function.function("STDENC_Open()", "st");
function STDENC_SetEncodingMode       = function.function("STDENC_SetEncodingMode(*)", "st");
InitStDenc.calls(STDENC_Init);
InitStDenc.calls(STDENC_Open, STDENC_Init);
InitStDenc.calls(STDENC_SetEncodingMode, STDENC_Open);

function STVOUT_Init                  = function.function("STVOUT_Init()", "st");
function STVOUT_Open                  = function.function("STVOUT_Open()", "st");
function STVOUT_GetCapability         = function.function("STVOUT_GetCapability()", "st");
function STVOUT_SetInputSource        = function.function("STVOUT_SetInputSource()", "st");
function STVOUT_SetOutputParams       = function.function("STVOUT_SetOutputParams()", "st");
function STVOUT_Enable                = function.function("STVOUT_Enable()", "st");
InitStVout.calls(STVOUT_Init);
InitStVout.calls(STVOUT_Open, STVOUT_Init);
InitStVout.calls(STVOUT_GetCapability, STVOUT_Open);
InitStVout.calls(STVOUT_SetInputSource, STVOUT_GetCapability);
InitStVout.calls(STVOUT_SetOutputParams, STVOUT_SetInputSource);
InitStVout.calls(STVOUT_Enable, STVOUT_SetOutputParams);

function STBLIT_GetInitAllocParams    = function.function("STBLIT_GetInitAllocParams()", "st");
function STBLIT_Init                  = function.function("STBLIT_Init()", "st");
InitStBlit.calls(STBLIT_GetInitAllocParams);
InitStBlit.calls(STBLIT_Init, STBLIT_GetInitAllocParams);

function STAUD_Init                   = function.function("STAUD_Init()", "st");
function STAUD_Open                   = function.function("STAUD_Open()", "st");
function STAUD_OPGetParams            = function.function("STAUD_OPGetParams()", "st");
function STAUD_OPEnableHDMIOutput     = function.function("STAUD_OPEnableHDMIOutput", "st");
function STAUD_Close                  = function.function("STAUD_Close", "st");
InitStAud.calls(STAUD_Init);
InitStAud.calls(STAUD_Open, STAUD_Init);
InitStAud.calls(STAUD_OPGetParams, STAUD_Open);
InitStAud.calls(STAUD_OPEnableHDMIOutput, STAUD_OPGetParams);
InitStAud.calls(STAUD_Close, STAUD_OPEnableHDMIOutput);





/*

function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("()", "otv");
*/


function ctl_first_init            = function.function("ctl_first_init()", "otv");
function init_ctltask_attb         = function.function("init_ctltask_attb()", "otv");
function ctl_synchronize           = function.function("ctl_synchronize()", "otv");
function appman_timer_new          = function.function("kb_get_sys_focus()", "otv");
function kb_get_user_focus         = function.function("kb_get_sys_focus()", "otv");
function kb_get_sys_focus          = function.function("kb_get_sys_focus()", "otv");
function user_queue_wait_message   = function.function("user_queue_wait_message(;;)", "otv");
control_task_main.calls(ctl_first_init);
control_task_main.calls(init_ctltask_attb, ctl_first_init);
control_task_main.calls(ctl_synchronize, init_ctltask_attb);
control_task_main.calls(appman_timer_new, ctl_synchronize);
control_task_main.calls(kb_get_user_focus, appman_timer_new);
control_task_main.calls(kb_get_sys_focus, kb_get_user_focus);
control_task_main.calls(user_queue_wait_message, kb_get_sys_focus);

function ctl_decoder_init_1        = function.function("ctl_decoder_init_1()", "otv");
function direct_segment_init       = function.function("direct_segment_init()", "otv");
function o_printf_init             = function.function("o_printf_init()", "otv");
function handle_init               = function.function("handle_init()", "otv");
function system_timer_init         = function.function("system_timer_init()", "otv");
function function_table_init       = function.function("function_table_init()", "otv");
function time_init                 = function.function("time_init()", "otv");
function o_actmon_init             = function.function("o_actmon_init()", "otv");
function kb_init                   = function.function("kb_init()", "otv");
function rsb_init                  = function.function("rsb_init()", "otv");
function UI_scratchpad_new         = function.function("UI_scratchpad_new()", "otv");
function sockets_init              = function.function("sockets_init()", "otv");
function init_hash_table           = function.function("init_hash_table()", "otv");
function o_file_sys_init           = function.function("o_file_sys_init()", "otv");
function wk_mgr_init               = function.function("wk_mgr_init()", "otv");
function o_locale_init             = function.function("o_locale_init()", "otv");
function o_network_registration_pipe_init = function.function("o_network_registration_pipe_init()", "otv");
ctl_first_init.calls(ctl_decoder_init_1);
ctl_first_init.calls(direct_segment_init, ctl_decoder_init_1);
ctl_first_init.calls(o_printf_init, direct_segment_init);
ctl_first_init.calls(handle_init, o_printf_init);
ctl_first_init.calls(system_timer_init, handle_init);
ctl_first_init.calls(function_table_init, system_timer_init); 
ctl_first_init.calls(time_init, function_table_init);
ctl_first_init.calls(o_actmon_init, time_init);
ctl_first_init.calls(kb_init, o_actmon_init);
ctl_first_init.calls(rsb_init, kb_init);
ctl_first_init.calls(UI_scratchpad_new, rsb_init);
ctl_first_init.calls(sockets_init, UI_scratchpad_new);
ctl_first_init.calls(init_hash_table, sockets_init);
ctl_first_init.calls(o_file_sys_init, init_hash_table);
ctl_first_init.calls(wk_mgr_init, o_file_sys_init);
ctl_first_init.calls(o_locale_init, wk_mgr_init);
ctl_first_init.calls(o_network_registration_pipe_init, o_locale_init);

function xmsg_init                 = function.function("xmsg_init()", "otv");
function o_genhandle_init          = function.function("o_genhandle_init()", "otv");
function o_genclient_init          = function.function("o_genclient_init()", "otv");
function o_station_control_init    = function.function("o_station_control_init()", "otv");
function o_stream_handle_init      = function.function("o_stream_handle_init()", "otv");
function o_app_heap_system_init    = function.function("o_app_heap_system_init()", "otv");
function o_pipe_init               = function.function("o_pipe_init()", "otv");
function o_container_init          = function.function("o_container_init()", "otv");
function o_plist_init              = function.function("o_plist_init()", "otv");
function aee_init                  = function.function("aee_init()", "otv");
function o_avserv_init             = function.function("o_avserv_init()", "otv");
function init_current_pipe_db      = function.function("init_current_pipe_db()", "otv");
function o_pipe_register_null_src_class  = function.function("o_pipe_register_null_src_class()", "otv");
function o_pipe_register_null_dest_class = function.function("o_pipe_register_null_dest_class()", "otv");
function service_task_init         = function.function("service_task_init()", "otv");
function GP_initialization         = function.function("GP_initialization()", "otv");
function display_dest_register     = function.function("display_dest_register()", "otv");
function program_info_init         = function.function("program_info_init()", "otv");
function o_attribute_init          = function.function("o_attribute_init()", "otv");
function ctl_decoder_init_2        = function.function("ctl_decoder_init_2()", "otv");
function postload                  = function.function("postload(!)", "otv");
function module_service_init       = function.function("module_service_init()", "otv");
function service_task_run          = function.function("service_task_run()", "otv");
function o_fs_register_client      = function.function("o_fs_register_client()", "otv");
function init_batch_processing     = function.function("init_batch_processing()", "otv");
function gdbo_init                 = function.function("gdbo_init()", "otv");
function authentication_init       = function.function("authentication_init()", "otv");
function crypto_init               = function.function("crypto_init()", "otv");
function who_init                  = function.function("who_init()", "otv");
function rm_first_init             = function.function("rm_first_init()", "otv");
function osd_init                  = function.function("osd_init()", "otv");
function ui_graphic_init           = function.function("ui_graphic_init()", "otv");
function efemgr_init               = function.function("efemgr_init()", "otv");
function fep_init                  = function.function("fep_init()", "otv");
function intp_task_main            = function.function("intp_task_main(!)", "otv");
function set_exn_stack_owner       = function.function("set_exn_stack_owner()", "otv");
function user_queue_wait_message2  = function.function("user_queue_wait_message(;)", "otv");
function system_queue_put_message_abort = function.function("system_queue_put_message_abort(intp)", "otv");
function o_natapp_init             = function.function("o_natapp_init()", "otv");
function o_pipe_register_notify    = function.function("o_pipe_register_notify()", "otv");
function bc_src_class_register     = function.function("bc_src_class_register(0)", "otv");
function bc_cat_src_class_register = function.function("bc_cat_src_class_register(0)", "otv");
function o_ss_pes_handler_init     = function.function("o_ss_pes_handler_init()", "otv");
function pipe_control_init         = function.function("pipe_control_init()", "tmm");
function ctl_decoder_init_3        = function.function("ctl_decoder_init_3()", "otv");
function o_app_set_current_pipe    = function.function("o_app_set_current_pipe()", "otv");
function o_file_sys_init2          = function.function("o_file_sys_init2()", "otv");
function o_file_start_expiration_date_checking = function.function("o_file_start_expiration_date_checking()", "otv");
ctl_synchronize.calls(xmsg_init);
ctl_synchronize.calls(o_genhandle_init, xmsg_init);
ctl_synchronize.calls(o_genclient_init, o_genhandle_init);
ctl_synchronize.calls(o_station_control_init, o_genclient_init);
ctl_synchronize.calls(o_stream_handle_init, o_station_control_init);
ctl_synchronize.calls(o_app_heap_system_init, o_stream_handle_init);
ctl_synchronize.calls(o_pipe_init, o_app_heap_system_init);
ctl_synchronize.calls(o_container_init, o_pipe_init);
ctl_synchronize.calls(o_plist_init, o_container_init);
ctl_synchronize.calls(aee_init, o_plist_init);
ctl_synchronize.calls(o_avserv_init, aee_init);
ctl_synchronize.calls(init_current_pipe_db, o_avserv_init);
ctl_synchronize.calls(o_pipe_register_null_src_class, init_current_pipe_db);
ctl_synchronize.calls(o_pipe_register_null_dest_class, o_pipe_register_null_src_class);
ctl_synchronize.calls(service_task_init, o_pipe_register_null_dest_class);
ctl_synchronize.calls(GP_initialization, service_task_init); 
ctl_synchronize.calls(display_dest_register, GP_initialization);
ctl_synchronize.calls(program_info_init, display_dest_register);
ctl_synchronize.calls(o_attribute_init, program_info_init);
ctl_synchronize.calls(ctl_decoder_init_2, o_attribute_init);
ctl_synchronize.calls(postload, ctl_decoder_init_2);
ctl_synchronize.calls(module_service_init, postload);
ctl_synchronize.calls(service_task_run, module_service_init);
ctl_synchronize.calls(o_fs_register_client, service_task_run);
ctl_synchronize.calls(init_batch_processing, o_fs_register_client);
ctl_synchronize.calls(gdbo_init, init_batch_processing);
ctl_synchronize.calls(authentication_init, gdbo_init);
ctl_synchronize.calls(crypto_init, authentication_init);
ctl_synchronize.calls(who_init, crypto_init);
ctl_synchronize.calls(rm_first_init, who_init);
ctl_synchronize.calls(osd_init, rm_first_init);
ctl_synchronize.calls(ui_graphic_init, osd_init);
ctl_synchronize.calls(efemgr_init, ui_graphic_init);
ctl_synchronize.calls(fep_init, efemgr_init);
ctl_synchronize.calls(intp_task_main, fep_init);
ctl_synchronize.calls(set_exn_stack_owner, intp_task_main);
ctl_synchronize.calls(user_queue_wait_message2, set_exn_stack_owner);
ctl_synchronize.calls(system_queue_put_message_abort, user_queue_wait_message2);
ctl_synchronize.calls(o_natapp_init, system_queue_put_message_abort);
ctl_synchronize.calls(o_pipe_register_notify, o_natapp_init);
ctl_synchronize.calls(bc_src_class_register, o_pipe_register_notify);
ctl_synchronize.calls(bc_cat_src_class_register, bc_src_class_register);
ctl_synchronize.calls(o_ss_pes_handler_init, bc_cat_src_class_register);
ctl_synchronize.calls(pipe_control_init, o_ss_pes_handler_init);
ctl_synchronize.calls(ctl_decoder_init_3, pipe_control_init);
ctl_synchronize.calls(o_app_set_current_pipe, ctl_decoder_init_3);
ctl_synchronize.calls(o_file_sys_init2, o_app_set_current_pipe);
ctl_synchronize.calls(o_file_start_expiration_date_checking, o_file_sys_init2);

function service_task_main         = function.function("service_task_main(!)", "otv");
service_task_run.calls(service_task_main);
function o_fs_register_client2     = function.function("o_fs_register_client()", "otv");
function user_queue_wait_data      = function.function("user_queue_wait_data(;;)", "otv");
service_task_main.calls(o_fs_register_client2);
service_task_main.calls(user_queue_wait_data, o_fs_register_client2);

function decoder_hard_init_1       = function.function("decoder_hard_init_1()", "tmm");
function decoder_hard_init_2       = function.function("decoder_hard_init_2()", "tmm");
function decoder_hard_init_3       = function.function("decoder_hard_init_3()", "tmm");
ctl_decoder_init_1.calls(decoder_hard_init_1);
ctl_decoder_init_2.calls(decoder_hard_init_2);
ctl_decoder_init_3.calls(decoder_hard_init_3);

function STAL_DecoderHardInit1     = function.function("STAL_DecoderHardInit1()", "s3");
function STAL_DecoderHardInit2     = function.function("STAL_DecoderHardInit2()", "s3");
function STAL_DecoderHardInit3     = function.function("STAL_DecoderHardInit3()", "s3");

decoder_hard_init_1.calls(STAL_DecoderHardInit1);

//function BoardFormatAndMountHdd    = function.function("BoardFormatAndMountHdd()", "tmm");
//function STAL_FLASH_EmergencyErase = function.function("STAL_FLASH_EmergencyErase()", "s3");
decoder_hard_init_2.calls(STAL_DecoderHardInit2);
//decoder_hard_init_2.calls(BoardFormatAndMountHdd, STAL_DecoderHardInit2);
//decoder_hard_init_2.calls(STAL_FLASH_EmergencyErase, BoardFormatAndMountHdd);
decoder_hard_init_3.calls(STAL_DecoderHardInit3);

function STAL_PLD_Register         = function.function("STAL_PLD_Register()", "s3");
function STAL_SDBG_Register        = function.function("STAL_SDBG_Register()", "s3");
function HAL_INIT_DecoderHardInit1 = function.function("HAL_INIT_DecoderHardInit1()", "tmm");
STAL_DecoderHardInit1.calls(STAL_PLD_Register);
STAL_DecoderHardInit1.calls(STAL_SDBG_Register, STAL_PLD_Register);
STAL_DecoderHardInit1.calls(HAL_INIT_DecoderHardInit1, STAL_SDBG_Register);

function o_pipe_register_pld_ftable = function.function("o_pipe_register_pld_ftable()", "otv");
STAL_PLD_Register.calls(o_pipe_register_pld_ftable);

function STUART_Open               = function.function("STUART_Open()", "st");
STAL_SDBG_Register.calls(STUART_Open);

function STAL_CLK_INIT             = function.function("STAL_CLK_INIT()", "s3");
function STAL_KBD_Register         = function.function("STAL_KBD_Register()", "s3");
function STAL_RTC_Register         = function.function("STAL_RTC_Register()", "s3");
function STAL_GMIX_Register        = function.function("STAL_GMIX_Register()", "s3");
function STAL_VMAN_Register        = function.function("STAL_VMAN_Register()", "s3");
function STAL_DMX_Register         = function.function("STAL_DMX_Register()", "s3");
function STAL_DMD_Register         = function.function("STAL_DMD_Register()", "s3");
function STAL_CA_Register          = function.function("STAL_CA_Register()", "s3");
function STAL_TVOUT_Register       = function.function("STAL_TVOUT_Register()", "s3");
function STAL_VID_Register         = function.function("STAL_VID_Register()", "s3");
function STAL_VIDPFM_Register      = function.function("STAL_VIDPFM_Register()", "s3");
function STAL_AUD_Register         = function.function("STAL_AUD_Register()", "s3");
function STAL_AUDPFM_Register      = function.function("STAL_AUDPFM_Register()", "s3");
function STAL_OSD_Register         = function.function("STAL_OSD_Register()", "s3");
function STAL_RAMFS_Register       = function.function("STAL_RAMFS_Register()", "s3");
function STAL_FLASH_Register       = function.function("STAL_FLASH_Register()", "s3");
function STAL_SVSCALE_Register     = function.function("STAL_SVSCALE_Register()", "s3");
function STAL_SQC_Register         = function.function("STAL_SQC_Register()", "s3");
function STAL_MPLANE_Register      = function.function("STAL_MPLANE_Register()", "s3");
function HAL_INIT_DecoderHardInit2 = function.function("HAL_INIT_DecoderHardInit2(*)", "tmm");
STAL_DecoderHardInit2.calls(STAL_CLK_INIT);
STAL_DecoderHardInit2.calls(STAL_KBD_Register, STAL_CLK_INIT);
STAL_DecoderHardInit2.calls(STAL_RTC_Register, STAL_KBD_Register); 
STAL_DecoderHardInit2.calls(STAL_GMIX_Register, STAL_RTC_Register);
STAL_DecoderHardInit2.calls(STAL_VMAN_Register, STAL_GMIX_Register);
STAL_DecoderHardInit2.calls(STAL_DMX_Register, STAL_VMAN_Register);
STAL_DecoderHardInit2.calls(STAL_DMD_Register, STAL_DMX_Register);
STAL_DecoderHardInit2.calls(STAL_CA_Register, STAL_DMD_Register);
STAL_DecoderHardInit2.calls(STAL_TVOUT_Register, STAL_CA_Register);
STAL_DecoderHardInit2.calls(STAL_VID_Register, STAL_TVOUT_Register); 
STAL_DecoderHardInit2.calls(STAL_VIDPFM_Register, STAL_VID_Register);
STAL_DecoderHardInit2.calls(STAL_AUD_Register, STAL_VIDPFM_Register);
STAL_DecoderHardInit2.calls(STAL_AUDPFM_Register, STAL_AUD_Register);
STAL_DecoderHardInit2.calls(STAL_OSD_Register, STAL_AUDPFM_Register);
STAL_DecoderHardInit2.calls(STAL_RAMFS_Register, STAL_OSD_Register);
STAL_DecoderHardInit2.calls(STAL_FLASH_Register, STAL_RAMFS_Register);
STAL_DecoderHardInit2.calls(STAL_SVSCALE_Register, STAL_FLASH_Register);
STAL_DecoderHardInit2.calls(STAL_SQC_Register, STAL_SVSCALE_Register);
STAL_DecoderHardInit2.calls(STAL_MPLANE_Register, STAL_SQC_Register);
STAL_DecoderHardInit2.calls(HAL_INIT_DecoderHardInit2, STAL_MPLANE_Register);

function HAL_KBD_GetConfig         = function.function("HAL_KBD_GetConfig()", "tmm");
function sys_info_register         = function.function("sys_info_register()", "otv");
function kb_device_register        = function.function("kb_device_register()", "otv");
function kb_device_set_repeat      = function.function("kb_device_set_repeat()", "otv");
STAL_KBD_Register.calls(HAL_KBD_GetConfig);
STAL_KBD_Register.calls(sys_info_register, HAL_KBD_GetConfig);
STAL_KBD_Register.calls(kb_device_register, sys_info_register);
STAL_KBD_Register.calls(kb_device_set_repeat, kb_device_register);

function ram_fsys_init             = function.function("ram_fsys_init()", "otv");
STAL_RAMFS_Register.calls(ram_fsys_init);

function HAL_FLASH_GetConfig       = function.function("HAL_FLASH_GetConfig()", "tmm");
function STAL_FLASH_P_pBlockLayout = function.function("STAL_FLASH_P_pBlockLayout()", "s3");
function fm_file_sys_init          = function.function("fm_file_sys_init()", "otv");
STAL_FLASH_Register.calls(HAL_FLASH_GetConfig);
STAL_FLASH_Register.calls(STAL_FLASH_P_pBlockLayout, HAL_FLASH_GetConfig);
STAL_FLASH_Register.calls(fm_file_sys_init, STAL_FLASH_P_pBlockLayout);

function InitStHdmi                = function.function("InitStHdmi(*)", "tmm");
function STHDMI_Init               = function.function("STHDMI_Init()", "st");
function STHDMI_Open               = function.function("STHDMI_Open()", "st");
function STAL_HDMI_Init            = function.function("STAL_HDMI_Init()", "s3");
function STVOUT_Start              = function.function("STVOUT_Start()", "st");
HAL_INIT_DecoderHardInit2.calls(InitStHdmi);
InitStHdmi.calls(STHDMI_Init);
InitStHdmi.calls(STHDMI_Open, STHDMI_Init);
InitStHdmi.calls(STAL_HDMI_Init, STHDMI_Open);
InitStHdmi.calls(STVOUT_Start, STAL_HDMI_Init);

function HAL_DMD_GetConfig         = function.function("HAL_DMD_GetConfig()", "tmm");
STAL_DMD_Register.calls(HAL_DMD_GetConfig);

function STAL_SCART_Register       = function.function("STAL_SCART_Register()", "s3");
function HAL_INIT_DecoderHardInit3 = function.function("HAL_INIT_DecoderHardInit3()", "tmm");
STAL_DecoderHardInit3.calls(STAL_SCART_Register);
STAL_DecoderHardInit3.calls(HAL_INIT_DecoderHardInit3, STAL_SCART_Register);




/*
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
function         = function.function("", "");
*/

/* ################ directory structure ################ */
function thomdemo       = function.function("thomdemo", "s3");
function build          = function.function("build", "s3");
function code           = function.function("code", "s3");
function tools          = function.function("tools", "s3");
thomdemo.calls(build);
thomdemo.calls(code, build);
thomdemo.calls(tools, code);

function make           = function.function("make", "s3");
function commons        = function.function("commons", "s3");
build.calls(make);
make.calls(commons);

function cltv           = function.function("cltv", "s3");
function platforms      = function.function("platforms", "s3");
code.calls(cltv);
code.calls(platforms, cltv);

function interface      = function.function("interface", "s3");
cltv.calls(interface);

function dhr250         = function.function("dhr250", "s3");
platforms.calls(dhr250);


function main2          = function.function("main", "");
function drivers        = function.function("drivers", "");
function hal            = function.function("hal", "tmm");
function opentv         = function.function("opentv", "otv");
function np             = function.function("np", "otv");
function make2          = function.function("make", "s3");
function tools2         = function.function("tools", "st");
function ext_libs       = function.function("ext_libs", "");
dhr250.calls(main2);
dhr250.calls(drivers, main2);
dhr250.calls(hal, drivers);
dhr250.calls(opentv, hal);
dhr250.calls(np, opentv);
dhr250.calls(make2, np);
dhr250.calls(tools2, make2); 
dhr250.calls(ext_libs, tools2); 

function STFAE          = function.function("STFAE", "st");
function Thomson        = function.function("Thomson", "tmm");
drivers.calls(STFAE);
drivers.calls(Thomson, STFAE);

function include_1       = function.function("include", "tmm");
function src            = function.function("src", "tmm");
main2.calls(include_1);
main2.calls(src, include_1);

function main_c         = function.function("main.c", "tmm");
function board_init_c   = function.function("board_init.c", "tmm");
function otvglue_c      = function.function("otvglue.c", "tmm");
function pipe_control_c = function.function("pipe_control.c", "tmm");
src.calls(main_c);
src.calls(board_init_c, main_c);
src.calls(otvglue_c, board_init_c);
src.calls(pipe_control_c, otvglue_c);

function ndbg           = function.function("ndbg", "otv");
function dbg            = function.function("dbg", "otv");
opentv.calls(ndbg);
opentv.calls(dbg, ndbg);
function include_2       = function.function("include", "otv");
ndbg.calls(include_2);
dbg.calls(include_2);

np.calls(ndbg);
np.calls(dbg);

function linux          = function.function("linux", "st");
function solaris        = function.function("solaris", "st");
function win32          = function.function("win32", "st");
tools2.calls(linux);
tools2.calls(solaris, linux);
tools2.calls(win32, solaris);

function include_3       = function.function("include", "tmm");
function src2           = function.function("src", "tmm");
hal.calls(include_3);
hal.calls(src2, include_3);

function cltv_hal       = function.function("cltv_hal", "tmm");
function stal_pwr       = function.function("stal_pwr", "tmm");
function th_demod       = function.function("th_demod", "tmm");
src2.calls(cltv_hal);
src2.calls(stal_pwr, cltv_hal);
src2.calls(th_demod, stal_pwr);


function stal_init_hal  = function.function("stal_init_hal", "tmm");
function stal_aud_hal   = function.function("stal_aud_hal", "tmm");
function stal_dmd_hal   = function.function("stal_dmd_hal", "tmm");
function stal_dmx_hal   = function.function("stal_dmx_hal", "tmm");
function stal_flash_hal = function.function("stal_flash_hal", "tmm");
function stal_gmix_hal  = function.function("stal_gmix_hal", "tmm");
function stal_kbd_hal   = function.function("stal_kbd_hal", "tmm");
function stal_mplane_hal= function.function("stal_mplane_hal", "tmm");
function stal_osd_hal   = function.function("stal_osd_hal", "tmm");
function stal_sqc_hal   = function.function("stal_sqc_hal", "tmm");
function stal_vman_hal  = function.function("stal_vman_hal", "tmm");
function stal_scart_hal = function.function("stal_scart_hal", "tmm");
cltv_hal.calls(stal_init_hal);
cltv_hal.calls(stal_aud_hal, stal_init_hal);
cltv_hal.calls(stal_dmd_hal, stal_aud_hal);
cltv_hal.calls(stal_dmx_hal, stal_dmd_hal);
cltv_hal.calls(stal_flash_hal, stal_dmx_hal);
cltv_hal.calls(stal_gmix_hal, stal_flash_hal);
cltv_hal.calls(stal_kbd_hal, stal_gmix_hal);
cltv_hal.calls(stal_mplane_hal, stal_kbd_hal);
cltv_hal.calls(stal_osd_hal, stal_mplane_hal);
cltv_hal.calls(stal_sqc_hal, stal_osd_hal); 
cltv_hal.calls(stal_vman_hal, stal_sqc_hal);
cltv_hal.calls(stal_scart_hal, stal_vman_hal);

/* ################ draw the pictures ################ */


picture call_sequence = draw_tree(main);
add_legend(call_sequence);
attach(call_sequence.fit(), (0,0), se);
shipout("call_sequence.eps");
erase(currentpicture);

picture pic_board_init = draw_tree(board_init);
add_legend(pic_board_init);
attach(pic_board_init.fit(), (0,0), se);
shipout("board_init.eps");
erase(currentpicture);


picture pic_control_task_main = draw_tree(control_task_main);
add_legend(pic_control_task_main);
attach(pic_control_task_main.fit(), (0,0), se);
shipout("control_task_main.eps");
erase(currentpicture);


/* dir tree */

picture thomdemo = draw_tree(thomdemo);
add_legend_2(thomdemo);
attach(thomdemo.fit(), (0,0), se);
shipout("dir_tree.eps");
erase(currentpicture);
