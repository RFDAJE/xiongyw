prologues:=2;
defaultfont:="ptm8r";

verbatimtex
%&latex
\documentclass{article}
\usepackage{CJK}
\begin{CJK}{GBK}{song}
\begin{document}
etex

u := 10;
wd_wt := 2*u;   % width of white key
wd_bk := 1.4u;  % width of black key
ht_wt := 7*u;   % height of white key
ht_bk := 4.5*u;  % height of black key, top align with white key
rd_wt := .2u;  % round size of white key
rd_bk := .1u;  % round size of black key
off_x := wd_wt-wd_bk/2.; % x offset of black key from left
off_y := ht_wt - ht_bk;  % y offset of black key from bottom

beginfig(1);

pickup pencircle scaled 1pt;

% white keys
for i = 0 upto 7:
	draw (i*wd_wt,rd_wt)--(i*wd_wt+rd_wt,0u)--((i+1)*wd_wt-rd_wt,0u)--((i+1)*wd_wt,rd_wt)--((i+1)*wd_wt,ht_wt)--(i*wd_wt,ht_wt)--cycle withcolor black;
	if i = 0 : 
		label.top(btex $\mathrm{c}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 1:
		label.top(btex $\mathrm{d}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 2:
		label.top(btex $\mathrm{e}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 3:
		label.top(btex $\mathrm{f}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 4:
		label.top(btex $\mathrm{g}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 5:
		label.top(btex $\mathrm{a}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 6:
		label.top(btex $\mathrm{b}$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	elseif i = 7:
		label.top(btex $\mathrm{c}^1$ etex, (i*wd_wt+wd_wt/2,1u)) withcolor black;
	fi
endfor	


% black keys
for i = 0,1,3,4,5:
	fill (i*wd_wt+off_x,off_y+rd_bk)--(i*wd_wt+off_x+rd_bk,off_y)--(i*wd_wt+off_x+wd_bk-rd_bk,off_y)--(i*wd_wt+off_x+wd_bk,off_y+rd_bk)--(i*wd_wt+off_x+wd_bk,ht_wt)--(i*wd_wt+off_x,ht_wt)--cycle withcolor black;
endfor
fill (7*wd_wt+off_x,off_y+rd_bk)--(7*wd_wt+off_x+rd_bk,off_y)--(7*wd_wt+off_x+wd_bk/2,off_y)--(7*wd_wt+off_x+wd_bk/2,ht_wt)--(7*wd_wt+off_x,ht_wt)--cycle withcolor black;

label.top(btex $^\sharp \mathrm{c}$ etex, (wd_wt,4u)) withcolor white;
label.top(btex $^\sharp \mathrm{d}$ etex, (2*wd_wt,4u)) withcolor white;

endfig;



verbatimtex
\end{CJK}
\end{document}
etex

end