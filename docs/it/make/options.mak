


# this is for compiler
CPPFLAGS := $(addprefix -I ,$(include_dirs))
# this is for make to find include files when checking dependencies. really needed?
#vpath %.h $(include_dirs)


# --------------------------------------
# compiler options
# --------------------------------------
# [-x c]: sources in C language
#CFLAGS := -x c 
# [-c]: compile only
CFLAGS += -c 

# [-ffreestanding]: we work in a freestanding environment, in which the standard
#   library may not exist, and program startup may not necessarily be at main.
#   this equals to [-fno-hosted]. it implies [-fno-builtin].
CFLAGS += -ffreestanding
# [-fno-builtin]: don¡¯t recognize built-in functions that do not begin with ¡®__builtin_¡¯ as prefix.
CFLAGS += -fno-builtin
# [-fno-builtin-xxx]: only xxx built-in function is disabled
# CFLAGS += -fno-builtin-xxx
# [-nostdinc]: do not search the standard system directories for header files. 
CFLAGS += -nostdinc
# [-nostdlib]: do not use the standard system startup files or libraries when linking.
CFLAGS += -nostdlib 
# [-fomit-frame-pointer]: don¡¯t keep the frame pointer in a register for functions that don¡¯t need one.
CFLAGS += -fomit-frame-pointer
# [-ffunction-sections/-fdata-sections]: place each function or data item into its own section in the 
#   output file if the target supports arbitrary sections. 
#   Only use these options when there are significant benefits from doing so!
CFLAGS += -ffunction-sections 
CFLAGS += -fdata-sections 
# [-fno-exceptions]: enable kernel development mode?
CFLAGS += -fno-exceptions 
# [-fno-stack-protector]: ?
CFLAGS += -fno-stack-protector 
# [-fno-short-enums]: use 32-bit enums by default
CFLAGS += -fno-short-enums 

# [-Wall]: enable all warnings
CFLAGS += -Wall 
# [-Wpointer-arith]: warn about anything that depends on the ¡°size of¡± a function type or of void.
CFLAGS += -Wpointer-arith 
# [-Wstrict-prototypes]: warn if a function is declared or defined without specifying the argument types
CFLAGS += -Wstrict-prototypes 
# [-Winline]: warn if a function can not be inlined and it was declared as inline.
CFLAGS += -Winline 
# [-Wundef]: warn whenever an identifier which is not a macro is encountered in an ¡®#if¡¯
#   directive, outside of ¡®defined¡¯. Such identifiers are replaced with zero.
CFLAGS += -Wundef 

# [-g]: produce debug info, should be turn off for release build
CFLAGS += -g  
# [-ggdb]: produce debugging information for use by GDB. is it applicable here?
#CFLAGS += -ggdb
# [-O2]: Optimize even more than [-O] or [-O1]. better turn it off for debug build.
#CFLAGS += -O2

# ARM specific options
# [-marm]:
CFLAGS += -marm  
# [-mcpu=arm926ej-s]: specifies the name of the target ARM processor
CFLAGS += -mcpu=arm926ej-s  
# [-mabi=aapcs-linux]: generate code for the specified ABI
CFLAGS += -mabi=aapcs-linux 
# [-mfloat-abi=soft]: specifies which floating-point ABI to use; it equals to [-fsoft-float].
CFLAGS += -mfloat-abi=soft 
# [thumb-interwork]: generate code which supports calling between the ARM and Thumb instruction sets.
CFLAGS += -mthumb-interwork 


# [-UOSD_REG_CPU_ACCESS]:
CFLAGS += -UOSD_REG_CPU_ACCESS   
# [-U__linux]:
CFLAGS += -U__linux 
# [-UAVL_BOOTLOADER]:
CFLAGS += -UAVL_BOOTLOADER 
# [-D__AVL_ARM926EJ__]:
CFLAGS += -D__AVL_ARM926EJ__ 
# [-D__AVL_MTOS__]:
CFLAGS += -D__AVL_MTOS__ 
# [-D__AVL_LIBRASD__]:
CFLAGS += -D__AVL_LIBRASD__
#CFLAGS += -D__AVL_CFG_DEBUG__ for debug output the print information
CFLAGS += -D__AVL_CFG_DEBUG__ 

#CFLAGS += -DCONFIG_FPGA 
CFLAGS += -D__AVL_CFG_TERMINAL_LOG__ 
CFLAGS += -DAVL_CFG_FRONTEND_DRIVER_ADTMB_PLUS__
CFLAGS += -D__AVL_CFG_DTMB__

# [compile for agar lib, not for agar application]
CFLAGS += -D_AGAR_INTERNAL
CFLAGS += -D_AGAR_GUI_INTERNAL
CFLAGS += -D_AGAR_CORE_INTERNAL

ifdef _DEMO_TEST
CFLAGS += -D_DEMO_TEST
endif

# [compile for jpeg]
CFLAGS += -DFOR_MTOS

# [compile for agar lib, not for agar application]
CFLAGS += -D_AGAR_INTERNAL
CFLAGS += -D_AGAR_GUI_INTERNAL
CFLAGS += -D_AGAR_CORE_INTERNAL
# [-D__AVL_IR_NEC__] or [-D__AVL_IR_RC5__]
#CFLAGS += -D__AVL_IR_RC5__
CFLAGS += -D__AVL_IR_NEC__
CFLAGS += -D_AGAR_UPDATE_REGION

#
# controlling which msg queue to be used
#
CFLAGS += -DKVCA_USE_MW_QUEUE
#CFLAGS += -DSEARCH_USE_MW_QUEUE
CFLAGS += -DPLAYER_USE_MW_QUEUE
#CFLAGS += -DMONITOR_USE_MW_QUEUE

#
# enable CA or not
#
#CFLAGS += -DENABLE_CA

#
# string transcoding at database API
#
#CFLAGS += -DDB_TRANSCODING



#
# source file level debug flags
#
#CFLAGS += -D_AG_DEBUG_LSL_
CFLAGS += -DMAIN_DEBUG
CFLAGS += -DMW_MEM_DEBUG
#CFLAGS += -DMW_SYS_DEBUG
#CFLAGS += -DKVCA_DEBUG
#CFLAGS += -DSEARCH_DEBUG
#CFLAGS += -DMONITOR_DEBUG
#CFLAGS += -DCA_MGR_DEBUG
#CFLAGS += -DSC_TASK_DEBUG
#CFLAGS += -DPLAYER_SVC_DEBUG
#CFLAGS += -DPLAYER_API_DEBUG
#CFLAGS += -DDRV_OSD_LINKLIST_COMMON_DEBUG
#CFLAGS += -DDRV_OSD_LINKLIST_DEBUG
#CFLAGS += -DAGAR_WIDGET_DEBUG
#CFLAGS += -DAGAR_VIEWBOX_DEBUG
#CFLAGS += -DAGAR_WINDOW_DEBUG
#CFLAGS += -DAGAR_LABEL_DEBUG
#CFLAGS += -DAGAR_SURFACE_DEBUG
#CFLAGS += -DAGAR_DRV_DEBUG
#CFLAGS += -DAGAR_TEXT_DEBUG
#CFLAGS += -DAGAR_PIXMAP_DEBUG
#CFLAGS += -DAGAR_BLIT_DEBUG
#CFLAGS += -DAGAR_BMP_DEBUG
#CFLAGS += -DAGAR_MYEDIT_DEBUG
# Common Manual Search
#CFLAGS += -DCMS_DEBUG
#CFLAGS += -DMANAGER_DEBUG
# Search Manager
#CFLAGS += -DSM_DEBUG
#CFLAGS += -DSECTION_DEBUG
#CFLAGS += -DNVRAM_DEBUG
#CFLAGS += -DDATABASE_DEBUG

#########################################################
# options used for linking: 
#########################################################
LD_OPTIONS := -msoft-float 
LD_OPTIONS += -g 
LD_OPTIONS += -nostdlib
LD_OPTIONS += -nodefaultlibs
LD_OPTIONS += -Wl,-T,demo/ld_script.ld
LD_OPTIONS += -Wl,--no-undefined 
LD_OPTIONS += -Wl,--gc-sections 
LD_OPTIONS += -Wl,-static 
LD_OPTIONS += -Wl,-L $(TOOLCHAIN_LIB_ROOT) 
LD_OPTIONS += -Wl,-L $(BSP_LIB_PATH)
LD_OPTIONS += -Wl,-L $(CAK_LIB_PATH)
LD_OPTIONS += -Wl,-Map -Wl,$(outroot)/$(system_map)
# libs/objs used for linking:
#LD_OPTIONS += -Wl,--start-group
LD_LIBS := -lgcc
LD_LIBS += -lm
LD_LIBS += -l_librasd_bsp
LD_LIBS += -lkvca40_AVL_20120117
#LD_LIBS += $(srcroot)/bsp/platform/libs/Vector_gnu.o
#LD_LIBS += $(srcroot)/bsp/platform/libs/main.o
#LD_LIBS += $(srcroot)/bsp/platform/libs/avl_util.o
#LD_LIBS += $(srcroot)/bsp/platform/libs/misc.o 
#LD_LIBS += $(srcroot)/bsp/platform/libs/shell.o
#LD_LIBS += $(srcroot)/bsp/platform/libs/dsputil_init_arm.o
#LD_OPTIONS += -Wl,--end-group 


