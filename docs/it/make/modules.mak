# Note: 'modules' contains a list of directory names of the modules,
#   the directories is relative to $(srcroot). e.g.:
#
#   modules := main
#   modules += util
#   modules += util/submodule
#
modules := mware/dvb/database
modules += mware/manager
modules += mware/dvb/parser
modules += mware/dvb/service/hangup
modules += mware/dvb/service/player
modules += mware/dvb/service/search
modules += mware/dmx
modules += mware/fpd
modules += mware/kbd
modules += mware/nim
modules += mware/nvram
modules += mware/sys
modules += mware/font16


modules += mware/misc
modules += mware/monitor
#modules += mware/log
# Note: MTOS bsp provides a console which allows customized commands to be added. 
#   so the same console module is not necessary for LibraSD
#modules += mware/console
modules += mware/utility/sts_update
modules += mware/utility/sts_update/dummy
modules += mware/utility/sys_config
modules += mware/utility/sys_config/dummy
modules += mware/dvb/dsm-cc

modules += mware/3rd/giflib
modules += mware/3rd/jpeg-8b
modules += mware/3rd/zlib-1.2.5
modules += mware/3rd/libpng-1.4.7

modules += app/demo
modules += app/demo/main
modules += app/demo/res/font
# this is only for temporary agar test
ifdef _DEMO_TEST
modules += mware/3rd/agar/tests
else
modules += app/demo/screen
# this for main test window asset
modules += app/demo/res/main_menu_test

# add the gui resource 
modules += app/demo/res/common
# add the gui main menu resource 
modules += app/demo/res/main_menu
# add the gui channel manager resource 
modules += app/demo/res/channel_manager
# add the gui program preview resource 
modules += app/demo/res/program_preview
# add the gui program search resource 
modules += app/demo/res/program_search
# add the gui program guid resource 
modules += app/demo/res/program_guide
# add the gui reminder manager resource 
modules += app/demo/res/reminder_manager
# add the gui tv screen resource 
modules += app/demo/res/tv_screen
# add the gui tv screen resource 
modules += app/demo/res/tv_screen/color_button
# add the gui tv screen resource 
modules += app/demo/res/tv_screen/IDNO
# add the gui tv screen resource
modules += app/demo/res/favorite_list

endif

modules += bsp/peripherals/demod
#modules += bsp/peripherals/demod/avl_dvbs_plus
modules += bsp/peripherals/demod/avl_dtmb_plus
#modules += bsp/peripherals/tuner/Sharp
modules += bsp/peripherals/ir

# compile for agar 
modules += mware/3rd/agar/core
modules += mware/3rd/agar/gui

modules += mware/3rd/agar/avl_widget/agEdit_widget
modules += mware/3rd/agar/avl_widget/interface
modules += mware/3rd/agar/avl_widget/video_widget
modules += mware/3rd/agar/avl_widget/gif_widget
modules += mware/3rd/agar/avl_widget/spin_widget
modules += mware/3rd/agar/avl_widget/table_widget
modules += mware/3rd/agar/avl_widget/progress_widget

# KVN CA4.0
modules += mware/3rd/cas/kvca4.0/src


#modules += bsp/platform




# include directories
#include_dirs := $(srcroot)/include 
include_dirs := $(srcroot)/bsp/peripherals/include 
include_dirs += $(srcroot)/mware/include 
#include_dirs += $(srcroot)/mware/include/facility/gui
#include_dirs += $(srcroot)/mware/include/utility
include_dirs += $(srcroot)/app/demo/include 

include_dirs += $(srcroot)/mware/3rd/agar/include/agar
include_dirs += $(srcroot)/mware/3rd/agar/include

include_dirs += $(BSP_INCLUDE_ROOT)
include_dirs += $(BSP_INCLUDE_ROOT)/common
include_dirs += $(BSP_INCLUDE_ROOT)/kernel
include_dirs += $(BSP_INCLUDE_ROOT)/std
include_dirs += $(BSP_INCLUDE_ROOT)/arch
include_dirs += $(BSP_INCLUDE_ROOT)/hal
include_dirs += $(BSP_INCLUDE_ROOT)/products
include_dirs += $(BSP_INCLUDE_ROOT)/drivers


# put it here for temp purpose
include_dirs += $(srcroot)/bsp/peripherals/include/demod
#include_dirs += $(srcroot)/bsp/peripherals/include/flash
include_dirs += $(srcroot)/bsp/peripherals/include/front_panel
include_dirs += $(srcroot)/bsp/peripherals/include/tuner

# add for agar include
include_dirs += $(srcroot)/mware/3rd/agar/include/agar/gui
include_dirs += $(srcroot)/mware/3rd/agar/include/agar
include_dirs += $(srcroot)/mware/3rd/agar/include

# KVN CA4.0
include_dirs += $(srcroot)/mware/3rd/cas/kvca4.0/include

include_dirs += $(addprefix $(srcroot)/,$(modules))



