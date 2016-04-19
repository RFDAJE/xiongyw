.PHONY: all clean test gens zjz zhao hlm tym

all: gens test zjz zhao

test:
	asy -f pdf test.asy

gens:
	asy -f pdf gens.asy
	-mkdir -p pdf
	-cp *.pdf pdf

zjz:
	asy -f pdf misc/zhangjuzheng.asy -o misc/

zhao:
	asy -f pdf misc/zhao.asy -o misc/

hlm:
	asy -f pdf misc/hlm_jia.asy -o misc/

tym:
	asy -f pdf misc/taoyuanming.asy -o misc/


clean:
	-rm *.log 
	-rm *.aux
	-rm *.dvi
	-rm *.eps
