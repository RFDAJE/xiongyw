# ---------------------------------------------------------------------------------------
# non-recursive make project 
#
# created(bruin, 2011-11-28)
# last updated: 2012-06-19
#
# reference: 
#   1. http://oreilly.com/catalog/make3/book/index.csp "Managing Projects with GNU Make", 3rd, Robert Mecklenburg
#   2. http://aegis.sf.net/auug97.pdf "Recursive Make Considered Harmful", Peter Miller
# ---------------------------------------------------------------------------------------


# --------------------------------------
# assumptions and goals
# --------------------------------------
# assumptions:
#   1. only use GNU Make under Linux environment (can support Windows if toolchain and gmake.exe
#      are available for Windows)
#   2. source files may have the same name (in different directories)
#   3. source tree is clean, i.e., no extra sources, no local makefiles.
#   4. source are either C or C++ with the following suffix: .h, .c, .cpp
#   5. 3rd party release is in the form of binary archives (.a) and appropriate headers (.h)
# 
# goals:
#   1. non-recursive
#   2. separating output from source tree
#   3. dependency generation
#   4. override built-in rules
#   5. using 'local.mk' in subdirectories to override root Makefile
#   6. misc: support jobs, help, silent/verbose, etc
# --------------------------------------


### -------------------------------------------------------------
### --         determine the build platform           
### -------------------------------------------------------------
ifdef ComSpec
	WINDOWS := 1
else
	ifeq ($(shell uname), Linux)
		LINUX := 1
	else
	    $(error Host platform is not supported!)   
	endif
endif


### -------------------------------------------------------------
### --   compiler and other tools
### -------------------------------------------------------------

ifdef WINDOWS
	$(error Host platform is not supported!)   
else
	CC      := gcc
	CP     := cp
	MD     := mkdir -p
	RM     := rm -rf
	ECHO    := echo
endif

# --------------------------------------
# these are simple variables
# --------------------------------------


PKG_NAME := tstool
PKG_ROOT := ..
OUT_ROOT := out

sources    :=
libraries  := 
executable := tstool


# 
# modules.mak and options.mak are put in the app specific sub directories
#

# --------------------------------------
# all sources and include directories
# --------------------------------------
include modules.mak  


# --------------------------------------
# compiling & linking options
# --------------------------------------
include options.mak



# --------------------------------------
# output directories
# --------------------------------------
ifdef WINDOWS
	out_dirs := $(subst /,\,$(addprefix $(OUT_ROOT)/,$(patsubst $(PKG_ROOT)/%,%,$(modules))))
else
	out_dirs := $(addprefix $(OUT_ROOT)/,$(patsubst $(PKG_ROOT)/%,%,$(modules)))
endif




# --------------------------------------
# these are recursive variables
# --------------------------------------
objects = $(call srcs-to-objs, $(sources))
depends = $(patsubst %.o,%.d,$(objects))



# --------------------------------------
# these are user defined macros
# --------------------------------------

# get objects path from sources path
# $(call srcs-to-objs,srcs)
define srcs-to-objs 
	$(addprefix $(OUT_ROOT)/, \
	$(patsubst $(PKG_ROOT)/%,%,\
	$(patsubst %.cpp,%.o,$(filter %.cpp,$1)) \
	$(patsubst %.c,%.o,$(filter %.c,$1))     \
	$(patsubst %.S,%.o,$(filter %.S,$1)))) 
endef

# --------------------------------------
# $(call module-to-lib module-path)
define module-to-lib
	$(addprefix $(OUT_ROOT)/,$(patsubst $(PKG_ROOT)/%,%/$(notdir $1).a,$1))
endef
	
# --------------------------------------
# generate rules for each module in the module list
# $(call all-module-rules,module-dir-list)
define all-module-rules
	$(foreach module,$1,$(call one-module-rules,$(module)))
endef

# auto insert (by eval) rules for each module, also updating 
# global 'sources' & 'libraries' variables;
#
# if there is a 'local.mk' under the module directory, also
# read that (-include), and the 'local.mk' can define 'local_exclude"
# to list names of source files to be excluded in the compilation.
# $(call one-module-rules,module-root-path)
define one-module-rules
	$(eval -include $1/local.mk)
	$(eval module_src := $(wildcard $1/*.c) $(wildcard $1/*.cpp) $(wildcard $1/*.S))

	$(eval local_exclude := $(addprefix $1/,$(local_exclude)))
	$(eval module_src := $(filter-out $(local_exclude),$(module_src)))

	$(eval module_obj := $(call srcs-to-objs,$(module_src)))
	$(eval module_lib := $(call module-to-lib,$1))
	
	sources += $(module_src)

	libraries += $(module_lib)

	$(eval $(module_lib): $(module_obj)
	  $(AR) rv $$@ $$^
         )
endef


# --------------------------------------
# $(call compile-rules, src-list)
define compile-rules
	$(foreach f,$1,$(call one-compile-rule,$(call srcs-to-objs,$(f)),$(f)))
endef

# generate rules for each source file. 
# Note: we choose the "The Hard Way" ([1] pp144-148) to separate the depends/objects from the source,
#   this way we do not rely on gmake's built-in rules, but explicitly specify rules for each of our
#   source; also note that the dependencies are generated at the same time when objects are generated,
#   i.e., in "Tromey's Way" ([1], pp150-154, with small variance). 
#   the net result is that we do not have pattern rules but all explicit rules which are auto-generated.
# $(call one-compile-rule,obj,src)
define one-compile-rule
	$(eval tmp_obj := $1)
	$(eval tmp_src := $2)
	$(eval tmp_dep := $(patsubst %.o,%.d,$(tmp_obj)))

	$(eval $(tmp_obj): $(tmp_src)
	  $(CC) -MM  -MF $(tmp_dep) -MP -MT $$@ $(CFLAGS) $(CPPFLAGS) $$<
	  $(CC) $(CFLAGS) $(CPPFLAGS) -o $$@ $$<
         )
endef




# This is to prevent gmake treats the first target (appears when
# generate module rules) as the default target
all:


# --------------------------------------
# here goes the bulk part of our rules! 
# --------------------------------------
$(eval $(call all-module-rules,$(modules)))
$(eval $(call compile-rules,$(sources)))





# --------------------------------------
#  regular targets
# --------------------------------------


.PHONY: all clean help chkdir
	
all: chkdir $(objects)
	$(CC) $(objects) -o $(OUT_ROOT)/$(executable)

	
chkdir: $(out_dirs)
$(out_dirs):
	$(MD) $@

clean:
ifdef WINDOWS
	$(RM) $(subst /,\,$(OUT_ROOT))
else
	$(RM) $(OUT_ROOT)
endif	

help:
	@$(ECHO) "targets available:"
	@$(ECHO) "    help          print help info"
	@$(ECHO) "    all           build app, this is the default target"
	@$(ECHO) "    clean         clean the build"



ifneq "$(MAKECMDGOALS)" "clean"
  -include $(depends)
endif
