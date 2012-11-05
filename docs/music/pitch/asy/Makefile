#----------------------------------------------------------------------
# created(bruin, 2007-02-05): generating pdf graphics from asy source
#
# $Id: Makefile 2 2007-03-22 12:54:39Z Administrator $
#----------------------------------------------------------------------

all: scale7.pdf             \
     kbd.pdf                \
     diag_arrow.pdf         \
     diag_dots.pdf          \
     diag_trend.pdf         \
     diag_4in1.pdf          \
     docdes_2in1.pdf        \
     ratioasc_trend.pdf     \
     cent_doc.pdf           \
     series.pdf             \
     p_series.pdf           \
     temp.pdf

series.eps p_series.eps temp.eps: cases.asy
	asy -noV -f eps $<

%.eps:%.asy
	asy -noV -f eps $<

	
%.pdf:%.eps	
	epstopdf $<


clean:
	rm -f *.eps *.bak
	
clean_all: clean
	rm -f *.pdf
