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
	  @printf "#\n# Building $(tmp_obj) ... \n#\n"
	  $(CC) -MM  -MF $(tmp_dep) -MP -MT $$@ $(CFLAGS) $(CPPFLAGS) $$<
	  $(CC) $(CFLAGS) $(CPPFLAGS) -o $$@ $$<
         )
endef




