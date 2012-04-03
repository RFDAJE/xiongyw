src_list := $(wildcard *.asy)
pdf_list := $(subst .asy,.pdf,$(src_list))
png_list := $(subst .asy,.png,$(src_list))


# $(call one-compile-rule,src)
define one-compile-rule
	$(eval asy := $1)
	$(eval pdf := $(subst .asy,.pdf,$1))
	$(eval png := $(subst .asy,.png,$1))

	$(eval $(pdf): $(asy)
	  asy -noV -f pdf $(asy) -o $(pdf)
         )
	$(eval $(png): $(asy)
	  asy -noV -f png $(asy) -o $(png)
         )

endef



# $(call compile-rules, src-list)
define compile-rules
	$(foreach f,$1,$(call one-compile-rule,$(f)))
endef

$(eval $(call compile-rules,$(src_list)))

.PHONY: all clean 
#all: $(pdf_list) $(png_list)
all: $(pdf_list)
	echo $(src_list)

clean:
	rm *.pdf *.png

