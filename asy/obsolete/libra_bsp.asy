/* created(bruin, 2011-11-29): call sequence in LibraSD BSP
 *
 * last modfied(bruin, 2011-11-29)
 */

import fontsize;

settings.tex = "xelatex";
 

texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimSun}");

 

 
 /* we use PostScript unit in both picture and frame */
size(0, 0);
unitsize(0, 0);

real   font_size = 10;      /* font size */
real   connect_width = 2font_size;  /* connection betw. callee and caller */
pair   se=0.000001SE;         /* used for alignment for picture attach() */

defaultpen(/*font("cmr12") + */fontsize(font_size));
pen line_pen = linewidth(0.8) + black + linecap(0); /* square cap */
pen name_pen = linewidth(0.1) + black + fontsize(font_size);

/* r&d/ae */
string rd = "rd";
string ae = "ae";

/* color for different department */
pen fill_pen_rd  = white;
pen fill_pen_ae  = rgb(204, 153, 255);


/* function: a node in call tree */
struct function{
	string   func_name;
	string   impl_by;   /* name of the department to implement this func */

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

	if(p.impl_by == rd){
		fill = FillDraw(fill_pen_rd);
	}else if(p.impl_by == ae){
		fill = FillDraw(fill_pen_ae);
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
	real y = -pic_size(pic).y - 50;
    label(pic, "Legend:\quad", (0,y+2), 0.001SE, NoFill);

	draw(pic, "\texttt{\quad BSP\quad}",        box, (8font_size,y),  2, black, FillDraw(fill_pen_rd));
	draw(pic, "\texttt{\quad APP\quad}", box, (18font_size,y), 2, black, FillDraw(fill_pen_ae));

	label(pic, "\texttt{func(*)}:      the func has been called many times.", (4font_size,y-20), 0.001SE, NoFill);
	label(pic, "\texttt{func(!)}:      a thread been created to execute this func", (4font_size,y-30), 0.001SE, NoFill);
	label(pic, "\texttt{func(;)}:      the func been called in a loop", (4font_size,y-40), 0.001SE, NoFill);
	label(pic, "\texttt{func(;;)}:     the func been called in an infinite loop", (4font_size,y-50), 0.001SE, NoFill);
}

/* ################ functions and calls ################ */

function __code_start             = function.function("Vector_gnu.S", "rd");
function prepare_exception_vector_table = function.function("prepare_exception_vector_table", "rd");
function set_exception_vector_table_base = function.function("set_exception_vector_table_base=0x00000000", "rd");
function init_stacks_for_all_modes = function.function("init_stacks_for_all_processor_modes", "rd");
function install_exception_vector_table = function.function("install_exception_vector_table", "rd");
function os_hal_init              = function.function("OS_Hal_Init()", "rd");
function os_main                  = function.function("OS_Main()", "rd");

__code_start.calls(prepare_exception_vector_table);
__code_start.calls(set_exception_vector_table_base, prepare_exception_vector_table);
__code_start.calls(init_stacks_for_all_modes, set_exception_vector_table_base);
__code_start.calls(install_exception_vector_table, init_stacks_for_all_modes);
__code_start.calls(os_hal_init, install_exception_vector_table);
__code_start.calls(os_main, os_hal_init);

function AVL_MALLOC_INIT_DMA       = function.function("AVL_MALLOC_INIT_DMA()", "rd");
function avl_malloc_init_dma       = function.function("avl_malloc_pool_init()", "rd");
function AVL_MALLOC_INIT           = function.function("AVL_MALLOC_INIT()", "rd");
function avl_malloc_init           = function.function("avl_malloc_init()", "rd");
function avl_mmu_set_ttb_base      = function.function("avl_mmu_set_ttb_base()", "rd");
function avl_set_arm_cp15_domain_ctrl_reg      = function.function("avl_set_arm_cp15_domain_ctrl_reg()", "rd");
function avl_mmu_create_sections   = function.function("avl_mmu_create_sections(*)", "rd");
function avl_mmu_enable            = function.function("avl_mmu_enable()", "rd");
function avl_cache_enable_icache   = function.function("avl_cache_enable_icache()", "rd");
function avl_cache_enable_dcache   = function.function("avl_cache_enable_dcache()", "rd");

os_hal_init.calls(AVL_MALLOC_INIT_DMA);
os_hal_init.calls(AVL_MALLOC_INIT, AVL_MALLOC_INIT_DMA);
os_hal_init.calls(avl_mmu_set_ttb_base, AVL_MALLOC_INIT);
os_hal_init.calls(avl_set_arm_cp15_domain_ctrl_reg, avl_mmu_set_ttb_base);
os_hal_init.calls(avl_mmu_create_sections, avl_set_arm_cp15_domain_ctrl_reg);
os_hal_init.calls(avl_mmu_enable, avl_mmu_create_sections);
os_hal_init.calls(avl_cache_enable_icache, avl_mmu_enable);
os_hal_init.calls(avl_cache_enable_dcache, avl_cache_enable_icache);

AVL_MALLOC_INIT_DMA.calls(avl_malloc_init_dma);

AVL_MALLOC_INIT.calls(avl_malloc_init);

function os_init_local      = function.function("OS_Init_Local()", "rd");
function thread_init        = function.function("Thread_Init()", "rd");
function flag_init          = function.function("Flag_Init()", "rd");
function mailbox_init       = function.function("MailBox_Init()", "rd");
function mutex_init         = function.function("Mutex_Init()", "rd");
function obj_init           = function.function("Obj_Init()", "rd");
function queue_init         = function.function("Queue_Init()", "rd");
function sem_init           = function.function("Sem_Init()", "rd");
function cond_init          = function.function("Cond_Init()", "rd");
function event_init         = function.function("Event_Init()", "rd");
function os_thread_idle     = function.function("OS_Thread_Idle(!, 63)", "rd");
function os_userappinit     = function.function("Os_UserAppInit()", "rd");
function os_switchtouserapp = function.function("OS_SwitchToUserApp()", "rd");

os_main.calls(os_init_local);
os_main.calls(thread_init,os_init_local);
os_main.calls(flag_init, thread_init);
os_main.calls(mailbox_init, flag_init);
os_main.calls(mutex_init, mailbox_init);
os_main.calls(obj_init, mutex_init);
os_main.calls(queue_init, obj_init);
os_main.calls(sem_init, queue_init);
os_main.calls(cond_init, sem_init);
os_main.calls(event_init, cond_init);
os_main.calls(os_thread_idle, event_init); 
os_main.calls(os_userappinit, os_thread_idle);
os_main.calls(os_switchtouserapp, os_userappinit);



function avl_interrupt_initialize    = function.function("avl_interrupt_initialize()", "rd");
function avl_interrupt_start_ctx_timer    = function.function("avl_interrupt_start_ctx_timer()", "rd");
function Thread_Create1      = function.function("Thread_Create(startup_task_entry, 0)", "rd");

/* function startup_task_entry    = function.function("startup_task_entry(!, 0)", "rd"); */

os_userappinit.calls(avl_interrupt_initialize);
os_userappinit.calls(avl_interrupt_start_ctx_timer, avl_interrupt_initialize);
os_userappinit.calls(startup_task_entry, avl_interrupt_start_ctx_timer);



function gpt_init    = function.function("gpt_init()", "rd");
function avl_os_module_init_call   = function.function("avl_os_module_init_call()", "rd");
function on_sys_start    = function.function("on_sys_start()", "ae");
function avl_run_shell   = function.function("avl_run_shell(!, 1)", "rd");
function avl_thread_delay   = function.function("avl_thread_delay(;;)", "rd");


startup_task_entry.calls(gpt_init);
startup_task_entry.calls(avl_os_module_init_call, gpt_init);
startup_task_entry.calls(on_sys_start, avl_os_module_init_call); 
startup_task_entry.calls(avl_run_shell, on_sys_start);
startup_task_entry.calls(avl_thread_delay, avl_run_shell);


function vos_init = function.function("vos_init()", "rd");
function avl_audio_mtos_init = function.function("avl_audio_mtos_init()", "rd");
function video_mtos_init   = function.function("video_mtos_init()", "rd");
function init_blitter_params   = function.function("init_blitter_params()", "rd");
function demux_mtos_init   = function.function("demux_mtos_init()", "rd");
function i2c_mtos_init   = function.function("i2c_mtos_init()", "rd");
function sys_68k_mtos_init   = function.function("sys_68k_mtos_init()", "rd");


avl_os_module_init_call.calls(vos_init);
avl_os_module_init_call.calls(avl_audio_mtos_init, vos_init);
avl_os_module_init_call.calls(video_mtos_init, avl_audio_mtos_init);
avl_os_module_init_call.calls(init_blitter_params, video_mtos_init);
avl_os_module_init_call.calls(demux_mtos_init, init_blitter_params);
avl_os_module_init_call.calls(i2c_mtos_init, demux_mtos_init); 
avl_os_module_init_call.calls(sys_68k_mtos_init, i2c_mtos_init);




/* ################ draw the pictures ################ */


picture call_sequence = draw_tree(__code_start);
add_legend(call_sequence);
attach(call_sequence.fit(), (0,0), se);

