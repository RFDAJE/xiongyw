# gnuplot script for 7 tones scale
# created(bruin, 2007-01-27)
# $Id: scale7.plt 2 2007-03-22 12:54:39Z Administrator $
#
# reference: http://t16web.lanl.gov/Kawano/gnuplot/index-e.html
#
reset
# x is steps ranges [0:8], y is cent [0:1200]
do(x) =(x<0.)?x/0:(x>1.)?x/0:   0.
re(x) =(x<1.)?x/0:(x>2.)?x/0: 200.
mi(x) =(x<2.)?x/0:(x>3.)?x/0: 400.
fa(x) =(x<3.)?x/0:(x>4.)?x/0: 500.
sol(x)=(x<4.)?x/0:(x>5.)?x/0: 700.
la(x) =(x<5.)?x/0:(x>6.)?x/0: 900.
si(x) =(x<6.)?x/0:(x>7.)?x/0:1100.
do2(x)=(x<7.)?x/0:(x>8.)?x/0:1200.

set term post eps enhanced color portrait "Arial" 11
set size 0.7, 0.3

set xrange [0:8]
set yrange [0:1200]

#set xtics border nomirror 1
#set xtics border ('do' 0.5, 're' 1.5, 'mi' 2.5, 'fa' 3.5, 'sol' 4.5, 'la' 5.5, 'si' 6.5, 'do' 7.5)

unset xtics
unset x2tics
unset ytics
set ticscale -0.4 0.2
#set y2tics ('' 0, '' 200, '' 400, '' 500, '' 700, '' 900, '' 1100, '' 1200)	
set ytics nomirror (0, 200, 400, 500, 700, 900, 1100, 1200)	

#set y2tics border nomirror 200
#set y2tics ('0' 0, "1200" 1200)	

set label  'do'  at 0.5,  -40 center
set label  're'  at 1.5,  -40 center
set label  're'  at 1.5,  150 center
set label  'mi'  at 2.5,  -40 center
set label  'mi'  at 2.5,  350 center
set label  'fa'  at 3.5,  -40 center
set label  'fa'  at 3.5,  450 center
set label  'sol' at 4.5,  -40 center
set label  'sol' at 4.5,  650 center
set label  'la'  at 5.5,  -40 center
set label  'la'  at 5.5,  850 center
set label  'si'  at 6.5,  -40 center
set label  'si'  at 6.5, 1050 center
set label  'do'  at 7.5,  -40 center
set label  'do'  at 7.5, 1150 center

#set label    '0' at  .5,   40 center
#set label  '200' at 1.5,  240 center
#set label  '400' at 2.5,  440 center
#set label  '500' at 3.5,  540 center
#set label  '700' at 4.5,  740 center
#set label  '900' at 5.5,  940 center
#set label '1100' at 6.5, 1140 center
#set label '1200' at 7.5, 1240 center

set label 'cent' at .2, 1200 left
# bottom, left & right
set border 11 linewidth 1 
# bottom & right
#set border 9 linewidth 1 
#set xlabel 'x' font 'Arial,10'
#set xlabel 'scale'
#set y2label 'cent' 
#set grid lt 9 lw 0.2
unset title
unset key
set samples 500
set output 'scale7.eps'
# define a new linestyle with index 1
set style line 1 lt -1 lw 1 
# define function to be drawn by lines
set style function lines
# using the same line style
plot do(x)  ls 1 w histeps, \
     re(x)  ls 1 w histeps, \
     mi(x)  ls 1 w histeps, \
     fa(x)  ls 1 w histeps, \
     sol(x) ls 1 w histeps, \
     la(x)  ls 1 w histeps, \
     si(x)  ls 1 w histeps, \
     do2(x) ls 1 w histeps
reset