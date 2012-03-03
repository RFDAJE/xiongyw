import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


/*--------------------------------------------------*/
/* OS start from RESET exception handling */

node __code_start             = node("Vector_gnu.S", "rd");
node prepare_exception_vector_table = node("prepare_exception_vector_table", "rd");
node set_exception_vector_table_base = node("set_exception_vector_table_base=0x00000000", "rd");
node init_stacks_for_all_modes = node("init_stacks_for_all_processor_modes", "rd");
node install_exception_vector_table = node("install_exception_vector_table: irq_handler, swi_handler", "rd");
node os_hal_init              = node("OS_Hal_Init()", "rd");
node os_main                  = node("OS_Main()", "rd");

__code_start.attach(prepare_exception_vector_table, 
                    set_exception_vector_table_base,
                    init_stacks_for_all_modes,
                    install_exception_vector_table,
                    os_hal_init,
                    os_main);

node AVL_MALLOC_INIT_DMA       = node("AVL_MALLOC_INIT_DMA()", "rd");
node avl_malloc_init_dma       = node("avl_malloc_pool_init()", "rd");
node AVL_MALLOC_INIT           = node("AVL_MALLOC_INIT()", "rd");
node avl_malloc_init           = node("avl_malloc_init()", "rd");
node avl_mmu_set_ttb_base      = node("avl_mmu_set_ttb_base()", "rd");
node avl_set_arm_cp15_domain_ctrl_reg      = node("avl_set_arm_cp15_domain_ctrl_reg()", "rd");
node avl_mmu_create_sections   = node("avl_mmu_create_sections(*)", "rd");
node avl_mmu_enable            = node("avl_mmu_enable()", "rd");
node avl_cache_enable_icache   = node("avl_cache_enable_icache()", "rd");
node avl_cache_enable_dcache   = node("avl_cache_enable_dcache()", "rd");
node avl_set_arm_cp15_dtcm_region_reg = node("avl_set_arm_cp15_dtcm_region_reg()","rd");
node avl_set_arm_cp15_itcm_region_reg = node("avl_set_arm_cp15_itcm_region_reg()","rd");

os_hal_init.attach(AVL_MALLOC_INIT_DMA,
                   AVL_MALLOC_INIT,
                   avl_mmu_set_ttb_base, 
                   avl_set_arm_cp15_domain_ctrl_reg, 
                   avl_mmu_create_sections,
                   avl_mmu_enable, 
                   avl_cache_enable_icache, 
                   avl_cache_enable_dcache,
				   avl_set_arm_cp15_dtcm_region_reg,
				   avl_set_arm_cp15_itcm_region_reg);

AVL_MALLOC_INIT_DMA.attach(avl_malloc_init_dma);

AVL_MALLOC_INIT.attach(avl_malloc_init);

node os_init_local      = node("OS_Init_Local()", "rd");
node thread_init        = node("Thread_Init()", "rd");
node flag_init          = node("Flag_Init()", "rd");
node mailbox_init       = node("MailBox_Init()", "rd");
node mutex_init         = node("Mutex_Init()", "rd");
node obj_init           = node("Obj_Init()", "rd");
node queue_init         = node("Queue_Init()", "rd");
node sem_init           = node("Sem_Init()", "rd");
node cond_init          = node("Cond_Init()", "rd");
node event_init         = node("Event_Init()", "rd");
node Thread_Create0     = node("Thread_Create(OS_Thread_Idle, 63)", "rd");
node os_userappinit     = node("Os_UserAppInit()", "rd");
node os_switchtouserapp = node("OS_SwitchToUserApp()", "rd");

os_main.attach(os_init_local,
               thread_init,
               flag_init,
               mailbox_init,
               mutex_init,
               obj_init, 
               queue_init,
               sem_init, 
               cond_init,
               event_init, 
               Thread_Create0,
               os_userappinit,
               os_switchtouserapp);



node avl_interrupt_initialize    = node("avl_interrupt_initialize()", "rd");
node avl_interrupt_start_ctx_timer    = node("avl_interrupt_start_ctx_timer()", "rd");
node Thread_Create1 = node("Thread_Create(startup_task_entry, 0)", "rd");


os_userappinit.attach(avl_interrupt_initialize,
                      avl_interrupt_start_ctx_timer,
                      Thread_Create1);

node reset_vic_irq_vector_0_to_15 = node("reset_vic_irq_vector_0_to_15", "rd");
node reset_vic_irq_vector_default = node("reset_vic_irq_vector_default", "rd");
node set_vic_irq_system_priority_level_to_0 = node("set_vic_irq_system_priority_level_to_0", "rd");
node reset_irq_isr_link_list = node("reset_irq_isr_link_list", "rd");
node disable_vic_irq_sources = node("disable_vic_irq_sources", "rd");
node reset_fiq_isr_link_list = node("reset_fiq_isr_link_list", "rd");
node disable_vic_fiq_sources = node("disable_vic_fiq_sources", "rd");

avl_interrupt_initialize.attach(reset_vic_irq_vector_0_to_15,
                                reset_vic_irq_vector_default,
								set_vic_irq_system_priority_level_to_0,
								reset_irq_isr_link_list,
								disable_vic_irq_sources,
								reset_fiq_isr_link_list,
								disable_vic_fiq_sources);

node tick_timer_set1 = node("avl_write32(TICK_TIMER_DIV, 1000000)", "rd");
node tick_timer_set2 = node("avl_write32(TICK_TIMER_VAL, 1)", "rd");
node tick_timer_set3 = node("avl_write32(TICK_TIMER_MASK, 0)", "rd");
node tick_timer_set4 = node("avl_write32(TICK_TIMER_ENA, 3)", "rd");
node tick_timer_irq_enable = node("vic_irq_tick_timer_source_enable", "rd");
								
avl_interrupt_start_ctx_timer.attach(tick_timer_set1,
                                     tick_timer_set2,
									 tick_timer_set3,
									 tick_timer_set4,
									 tick_timer_irq_enable);
							   
							   
node switch_to_task = node("switch_to_task(): switch to SYS mode with IRQ/FIQ enabled", "rd");
node os_find_highest_ready2 = node("OS_FindHighestReady()", "rd");

os_switchtouserapp.attach(os_find_highest_ready2, switch_to_task);
							   

							   
/*--------------------------------------------------*/							   
/* startup_task_entry */							   
							   
node startup_task_entry    = node("startup_task_entry()", "rd");

node gpt_init    = node("gpt_init()", "rd");
node avl_os_module_init_call   = node("avl_os_module_init_call()", "rd");
node on_sys_start    = node("on_sys_start()", "ae");
node Thread_Create2   = node("Thread_Create(avl_run_shell, 1)", "rd");
node avl_thread_delay   = node("avl_thread_delay(;;)", "rd");


startup_task_entry.attach(gpt_init,
                          avl_os_module_init_call, 
                          on_sys_start, 
                          Thread_Create2,
                          avl_thread_delay);
						  
node vos_init = node("vos_init()", "rd");
node avl_audio_mtos_init = node("avl_audio_mtos_init()", "rd");
node video_mtos_init   = node("video_mtos_init()", "rd");
node init_blitter_params   = node("init_blitter_params()", "rd");
node demux_mtos_init   = node("demux_mtos_init()", "rd");
node i2c_mtos_init   = node("i2c_mtos_init()", "rd");
node sys_68k_mtos_init   = node("sys_68k_mtos_init()", "rd");


avl_os_module_init_call.attach(vos_init,
                               avl_audio_mtos_init,
                               video_mtos_init, 
                               init_blitter_params,
                               demux_mtos_init,
                               i2c_mtos_init, 
                               sys_68k_mtos_init);

node avl_gpt_init = node("avl_gpt_init()", "rd");
node gpt_install_irq = node("gpt_install_irq()", "rd");

gpt_init.attach(avl_gpt_init, gpt_install_irq);
node avl_interrupt_install_irq_handler0 = node("avl_interrupt_install_irq_handler()", "rd");
gpt_install_irq.attach(avl_interrupt_install_irq_handler0);
node avl_interrupt_disable0 = node("avl_interrupt_disable()", "rd");
node assign_irq_list_entry0 = node("assign irq list entry", "rd");
node avl_interrupt_restore0 = node("avl_interrupt_restore()", "rd");
avl_interrupt_install_irq_handler0.attach(avl_interrupt_disable0, assign_irq_list_entry0, avl_interrupt_restore0);
							   
node avl_vos_init = node("avl_vos_init()", "rd");
node vos_install_irq = node("vos_install_irq()", "rd");
vos_init.attach(avl_vos_init, vos_install_irq);
node avl_interrupt_install_irq_handler = node("avl_interrupt_install_irq_handler()", "rd");
vos_install_irq.attach(avl_interrupt_install_irq_handler);

							   
							   
							   
/*--------------------------------------------------*/							   
/* IRQ execption handler */

node irq_handler = node("irq_handler", "rd");
node avl_interrupt_is_ctx = node("avl_interrupt_is_ctx", "rd");
node OS_Sche_Ctx_Sw = node("OS_Sche_Ctx_Sw", "rd");
node do_irq = node("do_irq", "rd");
node OS_Int_Ctx_Sw = node("OS_Int_Ctx_Sw", "rd");

irq_handler.attach(avl_interrupt_is_ctx, OS_Sche_Ctx_Sw, do_irq, OS_Int_Ctx_Sw);

node read_vic_final_status = node("read_vic_final_status", "rd");
node skip_shed_tick_irq_source = node("skip_shed_tick_irq_source", "rd");
node determine_irq_source = node("determine irq_src_idx", "rd");
node locate_irq_isr_entry = node("isr_entry = g_interrupt_irq_list[irq_src_idx]", "rd");
node call_isr = node("isr_entry->isr(isr_entry->data)", "rd");

do_irq.attach(read_vic_final_status,
              skip_shed_tick_irq_source,
			  determine_irq_source,
			  locate_irq_isr_entry,
			  call_isr);
			  
node read_irq_source_status = node("read_irq_source_status", "rd");			  
node service_the_irq_source_wrt_status = node("service_the_source_wrt_status", "rd");
node clear_the_irq_source = node("clear_the_irq_source", "rd");

call_isr.attach(read_irq_source_status, service_the_irq_source_wrt_status, clear_the_irq_source);

/*--------------------------------------------------*/			  
/* SWI execption handler */
node swi_handler = node("swi_handler", "rd");			  
node OS_Swi_Ctx_Sw = node("OS_Swi_Ctx_Sw", "rd");	

swi_handler.attach(OS_Swi_Ctx_Sw);		  

node OS_FindHighestReady = node("OS_FindHighestReady", "rd");			  
node OS_SaveCurCtx = node("OS_SaveCurCtx", "rd");			  
node OS_LoadCurCtx = node("OS_LoadCurCtx", "rd");

OS_Swi_Ctx_Sw.attach(OS_FindHighestReady, OS_SaveCurCtx, OS_LoadCurCtx);			  
			  
//node  = node("", "rd");






/* output the diagrams */
picture pic_code_start = draw_call_sequence(__code_start);
picture pic_startup_task_entry = draw_call_sequence(startup_task_entry);
picture pic_irq_handler = draw_call_sequence(irq_handler);
picture pic_swi_handler =  draw_call_sequence(swi_handler);

attach(bbox(pic_code_start, 2, 2, white), (0,0), SE);
attach(bbox(pic_startup_task_entry, 2, 2, white), (0,-940), SE);
attach(bbox(pic_irq_handler, 2, 2, white), (0, -1300), SE);
attach(bbox(pic_swi_handler, 2, 2, white), (0, -1550), SE);
							   
							   
							   