#----------------------------------------------------------------------
# created(bruin, 2008-05-16)
#
# $Id$
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


pdf: test.pdf

%.eps: test.asy water.dat roads.dat map.asy
	asy -noV -f eps $<
	
%.pdf:%.eps	
	epstopdf $<

clean:
	rm -f *.eps *.bak *.aux *.toc *.mtc* *.mpx *.mx1 *.fot  *.idx  *.ilg  *.ind *.log *.bak *.pdf *.dvi *.ps *.1 *.2
	
clean_all: clean
	rm -f *.pdf
