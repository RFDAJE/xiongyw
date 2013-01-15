#----------------------------------------------------------------------
# created(bruin, 2007-01-01)
#
# $Id: Makefile 8 2007-03-22 13:13:56Z Administrator $
#----------------------------------------------------------------------

CTEX      := C:/CTEX
CTEX_BIN  := $(CTEX)/texmf/miktex/bin
ASYM      := C:/CTeX/texmf/tex/latex/asymptote
ASYM_BIN  := $(ASYM)
SRC_ROOT  := $(shell pwd)
ASY_SRC   := $(SRC_ROOT)/asy
PATH      := $(PATH):$(CTEX_BIN):$(ASYM_BIN)
VPATH     := $(VPATH):$(SRC_ROOT):$(ASY_SRC)

export CTEX_BIN ASYM_BIN SRC_ROOT ASY_SRC PATH VPATH 


all: pdf
	-$(CTEX_BIN)/pdflatex --interaction=nonstopmode pitch
	-$(CTEX_BIN)/pdflatex --interaction=nonstopmode pitch

pdf:
	make -C $(ASY_SRC) -f $(ASY_SRC)/Makefile all
	
test:
	-$(CTEX_BIN)/pdflatex --interaction=nonstopmode test
	-$(CTEX_BIN)/pdflatex --interaction=nonstopmode test

dvi:
	latex pitch
	latex pitch
	makeindex pitch
	latex pitch

ps:	
	latex pitch
	dvips pitch
	
dvipdf:
	dvipdfmx pitch
	
	

clean: 
	make -C $(ASY_SRC) -f $(ASY_SRC)/Makefile clean
	rm -f *.aux *.toc *.mtc* *.mpx *.mx1 *.fot  *.idx  *.ilg  *.ind *.log *.bak *.pdf *.dvi *.ps *.1 *.2
	
clean_all: clean
	make -C $(ASY_SRC) -f $(ASY_SRC)/Makefile clean_all

