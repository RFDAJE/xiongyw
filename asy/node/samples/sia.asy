import fontsize;
import "../node/node.asy" as node;

settings.tex = "xelatex";
texpreamble("\usepackage{xeCJK}");
texpreamble("\usepackage{amsmath}");
texpreamble("\usepackage{amssymb}");
texpreamble("\setCJKmainfont{SimHei}");
texpreamble("\setmonofont[Path=../fonts/]{andalemo.ttf}");


/*
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
*/


/*
 * si adapter call sequence, simplified, 2013-11-25
 */



/* main */

node main   = node("main()", "");

node prctl  = node("prctl(PR_SET_NAME, \"si_adapter_proc\")", "u");
node osignal_init_handler      = node("osignal_init_handler()", "");  // "src/sysutils/*"
node si_adapter_init      = node("si_adapter_init()", "");
node PCD_api_send_process_ready      = node("PCD_api_send_process_ready()", "");
node osignal_wait_for_termination      = node("osignal_wait_for_termination()", "");
node si_adapter_shutdown      = node("si_adapter_shutdown()", "");
node exit      = node("exit()", "");

main.attach(prctl,
            osignal_init_handler,
            si_adapter_init,
            PCD_api_send_process_ready,
            osignal_init_handler,
            si_adapter_shutdown,
            exit);



/* si_adapter_init() */
node dbus_threads_init_default      = node("dbus_threads_init_default()", "");
node g_main_loop_new      = node("g_main_loop_new()", "");
node o_sysutils_init      = node("o_sysutils_init()", "");
node cfg_client_init      = node("cfg_client_init()", "");
node cfg_client_watch_dir      = node("cfg_client_watch_dir(\"/network/siconfig\")", "");
node cfg_client_watch_dir2      = node("cfg_client_watch_dir(\"/network/schemas/EPG\")", "");
node o_db_open_or_create      = node("o_db_open_or_create(\"/network/schemas/EPG\")", "");
node o_epglib_parental_rating_init       = node("o_epglib_parental_rating_init()", "");
node o_epglib_event_id_generate_init      = node("o_epglib_event_id_generate_init()", "");
node dl_config_si_sources_initialize      = node("dl_config_si_sources_initialize()", "");
node scm_init      = node("scm_init()", "");
node O_PTHREAD_CREATE      = node("$\bigstar\enskip$O_PTHREAD_CREATE(si_adapter_GMainThread()==>g_main_loop_run())", "");
node scm_start      = node("scm_start()", "");

si_adapter_init.attach(dbus_threads_init_default,
                       g_main_loop_new,
                       o_sysutils_init,
                       cfg_client_init,
                       cfg_client_watch_dir,
                       cfg_client_watch_dir2,
                       o_db_open_or_create,
                       o_epglib_parental_rating_init,
                       o_epglib_event_id_generate_init,
                       dl_config_si_sources_initialize,
                       scm_init,
                       O_PTHREAD_CREATE,
                       scm_start);

/* dl_config_si_sources_initialize() */

node cfg_client_get_dirs_and_entries = node("cfg_client_get_dirs_and_entries(\"/network/siconfig/dlScmSources\")", "");
node cfg_dirset_foreach = node("$\blacktriangleright\enskip$cfg_dirset_foreach()", "");

dl_config_si_sources_initialize.attach(cfg_client_get_dirs_and_entries,
                                       cfg_dirset_foreach);

/* dl_config_src_init_cfg_callback */

//node dl_config_src_init_cfg_callback = node("dl_config_src_init_cfg_callback()", "");
node dl_config_src_init = node("dl_config_src_init()", "");

cfg_dirset_foreach.attach(//dl_config_src_init_cfg_callback,
                          dl_config_src_init);

/* dl_config_src_init */


node dl_config_src_get_config_info = node("dl_config_src_get_config_info()", "");
node dlopen = node("dlopen()", "");
node dlsym = node("dlsym(o_sia_dl_config_scm_source_init)", "");
node dlsym2 = node("dlsym(o_sia_dl_config_scm_source_shutdown)", "");
node o_sia_dl_config_scm_source_init = node("o_sia_dl_config_scm_source_init()", "");

dl_config_src_init.attach(dl_config_src_get_config_info,
                          dlopen,
                          dlsym,
                          dlsym2,
                          o_sia_dl_config_scm_source_init);

/* o_sia_dl_config_scm_source_init */
node O_PTHREAD_CREATE4 = node("$\bigstar\enskip$O_PTHREAD_CREATE(src_specific_main)", "");
node scm_register_si_src = node("scm_register_si_src()", "");
node dots = node("etc...","");

o_sia_dl_config_scm_source_init.attach(O_PTHREAD_CREATE4,
                                       scm_register_si_src,
                                       dots);						

/* scm_register_si_src */
						
//node scmSISourceMgr_Register = node("scmSISourceMgr_Register()", "");
//scm_register_si_src.attach(scmSISourceMgr_Register);

/* scm_init */
node resman_connect_proxy = node("resman_connect_proxy()", "");
node rm_register_client = node("rm_register_client()", "");
node scmEventMgr_Init = node("scmEventMgr_Init()", "");
node scmScanMgr_Init = node("scmScanMgr_Init()", "");
node scmNetworkClassMgr_Init = node("scmNetworkClassMgr_Init()", "");
node scmConnectionMgr_Init = node("scmConnectionMgr_Init()", "");
node scmPwrmgrClient_Init = node("scmPwrmgrClient_Init()", "");
node scmCCOM_Init = node("scmCCOM_Init()", "");
node scmConfigMgrIfc_Init = node("scmConfigMgrIfc_Init()", "");

scm_init.attach(resman_connect_proxy,
                rm_register_client,
                scmEventMgr_Init,
                scmScanMgr_Init,
                scmNetworkClassMgr_Init,
                scmConnectionMgr_Init,
                scmPwrmgrClient_Init,
                scmCCOM_Init,
                scmConfigMgrIfc_Init);

/* scmEventMgr_Init */
node g_async_queue_new_full = node("g_async_queue_new_full()","");
node O_PTHREAD_CREATE2      = node("$\bigstar\enskip$O_PTHREAD_CREATE(scmEventMgr_Main()==>while(1)\{e=g_async_queue_pop(); switch(e)\{\}\})", "");
scmEventMgr_Init.attach(g_async_queue_new_full,
                        O_PTHREAD_CREATE2);

/* scmScanMgr_Init */
node o_timer_create = node("o_timer_create(scmScanMgr_TimerCallback)", "");
node o_timer_start = node("o_timer_start()", "");

scmScanMgr_Init.attach(o_timer_create,
                       o_timer_start);

/* scmNetworkClassMgr_Init */
node o_epglib_init = node("o_epglib_init()","");
scmNetworkClassMgr_Init.attach(o_epglib_init);

/* scmConnectionMgr_Init */
node o_tss_open_connection = node("o_tss_open_connection()", "");
node o_tss_create_proxy = node("o_tss_create_proxy()", "");
node o_tss_register_signals = node("o_tss_register_signals()", "");
scmConnectionMgr_Init.attach(o_tss_open_connection,
                             o_tss_create_proxy,
                             o_tss_register_signals);

/* scmCCOM_Init */

node sem_init = node("sem_init()", "");
node O_PTHREAD_CREATE3 = node("$\bigstar\enskip$O_PTHREAD_CREATE(scmCCOM_Main)", "");
node sem_wait = node("sem_wait()", "");

scmCCOM_Init.attach(sem_init,
                    O_PTHREAD_CREATE3,
                    sem_wait);

/* scmConfigMgrIfc_Init */
node scmi_getStringList = node("scmi_getStringList(\"/network/siconfig/monitoredConfigEntries\")", "");
node cfg_client_watch_dir3 = node("cfg_client_watch_dir()", "");
node cfg_client_add_notify = node("cfg_client_add_notify(scmConfigMgrIfc_ConfigChangedCallback)", "");
node scmi_freeStringList = node("scmi_freeStringList()", "");

scmConfigMgrIfc_Init.attach(scmi_getStringList,
                            cfg_client_watch_dir3,
                            cfg_client_add_notify,
                            scmi_freeStringList);                            



/*
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
node  = node("()", "");
*/


/* scm_start */

node scmEventMgrEvent_Create = node("scmEventMgrEvent_Create()","");
node scmEventMgr_Notify = node("scmEventMgr_Notify(SCM_EVENT_UNLOCK_CONFIGURATION_INIT)","");

scm_start.attach(scmEventMgrEvent_Create,
                 scmEventMgr_Notify);








/* output the diagrams */
picture pic_main = draw_call_sequence(main);

//attach(pic_on_sys_start.fit(), (0,0), SE);
attach(bbox(pic_main, 2, 2, white), (0,0), SE);
