import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


/*
node       = node("()", "ae");
node       = node("()", "ae");
node       = node("()", "ae");
node       = node("()", "ae");
node       = node("()", "ae");
node       = node("()", "ae");
*/


/*--------------------------------------------------*/


node on_sys_start             = node("on_sys_start()", "ae");
node avl_driver_init          = node("avl_driver_init()", "ae");
node avl_middleware_init      = node("avl_middleware_init()", "ae");
node avl_gui_event_loop      = node("avl_gui_event_loop()", "ae");

on_sys_start.attach(avl_driver_init, 
                    avl_middleware_init, 
					avl_gui_event_loop);

node init_osd      = node("init_osd()", "ae");
node demux_setup      = node("demux_setup()", "ae");
node avl_thread_delay = node("avl_thread_delay(2000)", "ae");
node avl_time_init      = node("avl_time_init()", "ae");
node avl_mediaplayer_init      = node("avl_mediaplayer_init()", "ae");

avl_driver_init.attach(init_osd,
                       demux_setup,
					   avl_thread_delay,
					   avl_time_init,
					   avl_mediaplayer_init);

node avl_vos_init	 = node("avl_vos_init()", "ae");				
node avl_vos_open    = node("avl_vos_open()", "ae");
node avl_vos_set_format      = node("avl_vos_set_format()", "ae");
node set_background_color    = node("set_background_color()", "ae");

init_osd.attach(avl_vos_init,
                avl_vos_open,
				avl_vos_set_format,
				set_background_color);
				
node avl_demux_init      = node("avl_demux_init()", "ae");
node avl_demux_open      = node("avl_demux_open(HW_TSP_0)", "ae");
node avl_demux_tsin_allocate      = node("avl_demux_tsin_allocate()", "ae");
node avl_demux_signal_allocate      = node("avl_demux_signal_allocate(SECTION)", "ae");
node avl_demux_signal_allocate2      = node("avl_demux_signal_allocate(PES)", "ae");

demux_setup.attach(avl_demux_init,
                   avl_demux_open,
				   avl_demux_tsin_allocate,
				   avl_demux_signal_allocate,
				   avl_demux_signal_allocate2);

node avl_console_init = node("avl_console_init()", "ae");
node avl_nvram_init = node("avl_nvram_init()", "ae");
node avl_frontend_init = node("avl_frontend_init()", "ae");
node avl_section_Init = node("avl_section_Init()", "ae");
node avl_db_init = node("avl_db_init()", "ae");
node avl_monitor_init = node("avl_monitor_init()", "ae");
node avl_mamanger_init = node("avl_mamanger_init()", "ae");
node avl_thread_delay2 = node("avl_thread_delay(2000)", "ae");
node add_outPutService_command = node("add_outPutService_command()", "ae");
node add_manualSearch_command = node("add_manualSearch_command()", "ae");
node add_avplayer_command = node("add_avplayer_command()", "ae");
node avl_thread_delay3 = node("avl_thread_delay(20000)", "ae");

avl_middleware_init.attach(avl_console_init,
                           avl_nvram_init,
						   avl_frontend_init,
						   avl_section_Init,
						   avl_db_init,
						   avl_monitor_init,
						   avl_mamanger_init,
						   avl_thread_delay2,
						   add_outPutService_command,
						   add_manualSearch_command,
						   add_avplayer_command,
						   avl_thread_delay3);
						   

node avl_frontend_initialize      = node("avl_frontend_initialize()", "ae");
node avl_frontend_open      = node("avl_frontend_open()", "ae");
node avl_thread_create      = node("avl_thread_create(frontend_task)", "ae");

avl_frontend_init.attach(avl_frontend_initialize,
                         avl_frontend_open,
                         avl_thread_create);						 
						   
node section_buffer_init      = node("section_buffer_init()", "ae");
node avl_mutex_init      = node("avl_mutex_init(logic_channel)", "ae");
node avl_mutex_init2      = node("avl_mutex_init(physical_channel)", "ae");
node avl_thread_create_ext = node("avl_thread_create_ext(save_demux_section_data, 16)", "ae");
node avl_settimer_ex      = node("avl_settimer_ex()", "ae");

avl_section_Init.attach(section_buffer_init,
                        avl_mutex_init,
						avl_mutex_init2,
						avl_thread_create_ext,
						avl_settimer_ex);


node init_sat_table      = node("init_sat_table()", "ae");
node init_network_table      = node("init_network_table()", "ae");
node init_ts_table      = node("init_ts_table()", "ae");
node init_service_table      = node("init_service_table()", "ae");
node init_bqt_table      = node("init_bqt_table()", "ae");
node init_schedule_table      = node("init_schedule_table()", "ae");						
node init_global_data      = node("init_global_data()", "ae");						
						
avl_db_init.attach(init_sat_table,
                   init_network_table,
				   init_ts_table,
				   init_service_table,
				   init_bqt_table,
				   init_schedule_table,
				   init_global_data);
				   
node avl_mutex_init3      = node("avl_mutex_init()", "ae");
node avl_semaphore_init3      = node("avl_semaphore_init()", "ae");
node avl_thread_create_ext3      = node("avl_thread_create_ext(monitor_task, 16)", "ae");

avl_monitor_init.attach(avl_mutex_init3,
                        avl_semaphore_init3,
						avl_thread_create_ext3);
						
						

node avl_manager_set_status      = node("avl_manager_set_status()", "ae");
avl_mamanger_init.attach(avl_manager_set_status);

			   
				   
                   						
						
						
						
						
						
						
						
						
						
						
						
						
						

/* output the diagrams */
picture pic_on_sys_start = draw_call_sequence(on_sys_start);

//attach(pic_on_sys_start.fit(), (0,0), SE);
attach(bbox(pic_on_sys_start, 2, 2, white), (0,0), SE);
