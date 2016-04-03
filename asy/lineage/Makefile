.PHONY: all clean

test:
	asy -f pdf test.asy

gens:
	asy -f pdf gens.asy
	mkdir -p pdf
	cp *.pdf pdf

misc:
	asy -f pdf zhangjuzheng.asy

clean:
	-rm *.log 
	-rm *.aux
	-rm *.dvi
	-rm *.eps
