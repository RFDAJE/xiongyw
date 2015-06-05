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

modules := $(PKG_ROOT)/src




#-----------------------------------------
# includes
#-----------------------------------------

include_dirs := $(modules)
include_dirs += $(PKG_ROOT)   # config.h
