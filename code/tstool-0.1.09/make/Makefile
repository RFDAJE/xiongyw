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


# ######################################
# these are macros, usually no change
# ######################################
include macros.mak


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
