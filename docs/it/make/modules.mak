# Note: 'modules' contains a list of directory names of the modules,
#   the directories is relative to $(srcroot). e.g.:
#
#   modules := main
#   modules += util
#   modules += util/submodule
#

#-----------------------------------------
# SDK
#-----------------------------------------

modules := $(SDK_ROOT)/src/dvb/database
# move "manager" into APP and rename to "fsm"
#modules += $(SDK_ROOT)/src/manager
modules += $(SDK_ROOT)/src/dvb/parser
modules += $(SDK_ROOT)/src/dvb/service/hangup
modules += $(SDK_ROOT)/src/dvb/service/player
modules += $(SDK_ROOT)/src/dvb/service/search
modules += $(SDK_ROOT)/src/dmx
modules += $(SDK_ROOT)/src/fpd
modules += $(SDK_ROOT)/src/kbd
modules += $(SDK_ROOT)/src/nim
modules += $(SDK_ROOT)/src/nvram
modules += $(SDK_ROOT)/src/sys
modules += $(SDK_ROOT)/src/font16

modules += $(SDK_ROOT)/src/misc
modules += $(SDK_ROOT)/src/monitor
modules += $(SDK_ROOT)/src/utility/sts_update
modules += $(SDK_ROOT)/src/utility/sts_update/dummy
modules += $(SDK_ROOT)/src/utility/sys_config
modules += $(SDK_ROOT)/src/utility/sys_config/dummy
modules += $(SDK_ROOT)/src/dvb/dsm-cc

modules += $(SDK_ROOT)/src/3rd/giflib
modules += $(SDK_ROOT)/src/3rd/jpeg-8b
modules += $(SDK_ROOT)/src/3rd/zlib-1.2.5
modules += $(SDK_ROOT)/src/3rd/libpng-1.4.7

# compile for agar 
modules += $(SDK_ROOT)/src/3rd/agar/core
modules += $(SDK_ROOT)/src/3rd/agar/gui

modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/agEdit_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/interface
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/video_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/gif_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/spin_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/table_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/progress_widget
modules += $(SDK_ROOT)/src/3rd/agar/avl_widget/popup_widget

# KVN CA4.0
modules += $(SDK_ROOT)/src/3rd/cas/kvca4.0/src




#-----------------------------------------
# APP
#-----------------------------------------


modules += $(APP_ROOT)/$(APP_NAME)/src
modules += $(APP_ROOT)/$(APP_NAME)/src/main
modules += $(APP_ROOT)/$(APP_NAME)/src/res/font
modules += $(APP_ROOT)/$(APP_NAME)/src/screen
# this for main test window asset
modules += $(APP_ROOT)/$(APP_NAME)/src/res/main_menu_test

# add the gui resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/common
# add the gui main menu resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/main_menu
# add the gui channel manager resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/channel_manager
# add the gui program preview resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/program_preview
# add the gui program search resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/program_search
# add the gui program guid resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/program_guide
# add the gui reminder manager resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/reminder_manager
# add the gui tv screen resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/tv_screen
# add the gui tv screen resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/tv_screen/color_button
# add the gui tv screen resource 
modules += $(APP_ROOT)/$(APP_NAME)/src/res/tv_screen/IDNO
# add the gui tv screen resource
modules += $(APP_ROOT)/$(APP_NAME)/src/res/favorite_list

modules += $(APP_ROOT)/$(APP_NAME)/src/fsm

#-----------------------------------------
# BSP
#-----------------------------------------

modules += $(TGT_BSP_PERIPHERAL_ROOT)/src/demod
modules += $(TGT_BSP_PERIPHERAL_ROOT)/src/demod/avl_dtmb_plus
modules += $(TGT_BSP_PERIPHERAL_ROOT)/src/front_panel






#-----------------------------------------
# includes
#-----------------------------------------

include_dirs := $(modules)

include_dirs += $(TGT_BSP_PERIPHERAL_ROOT)/src/include 
include_dirs += $(SDK_ROOT)/src/include 
include_dirs += $(APP_ROOT)/$(APP_NAME)/src/include 

include_dirs += $(SDK_ROOT)/src/3rd/agar/include
include_dirs += $(SDK_ROOT)/src/3rd/agar/include/agar
include_dirs += $(SDK_ROOT)/src/3rd/agar/include/agar/gui

include_dirs += $(TGT_BSP_SOC_INC_ROOT)
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/common
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/kernel
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/std
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/arch
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/hal
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/products
include_dirs += $(TGT_BSP_SOC_INC_ROOT)/drivers

include_dirs += $(TGT_BSP_PERIPHERAL_ROOT)/src/include/demod
include_dirs += $(TGT_BSP_PERIPHERAL_ROOT)/src/include/front_panel
include_dirs += $(TGT_BSP_PERIPHERAL_ROOT)/src/include/tuner

# KVN CA4.0
include_dirs += $(TGT_ROOT)/$(TGT_NAME)/cas/kvca4.0/include

