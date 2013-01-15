# gnuplot script for plotting octavization function
# created(bruin, 2006-12-31)
# $Id: octavize.plt 2 2007-03-22 12:54:39Z Administrator $
#
reset
o(x)=x/2**(floor(log(x)/log(2)))
# this is a discontinuous function, needs to be drawn seperately:
# [0.25:0.5]
f1(x)=(x<0.25)?x/0:(x>0.5)?x/0:o(x)
# [0.5:1.0]
f2(x)=(x<0.5)?x/0:(x>1.0)?x/0:o(x)
# [1.0:2.0]
f3(x)=(x<1.0)?x/0:(x>2.0)?x/0:o(x)
# [2.0:4.0]
f4(x)=(x<2.0)?x/0:(x>3.99)?x/0:o(x)
# [4.0:8.0]
#f5(x)=(x<4.0)?x/0:(x>7.99)?x/0:o(x)

set term post eps enhanced color portrait "Arial" 14
set size 0.8, 0.4
#set size ratio 0.5
set xrange [0.25:4]
set yrange [1:2]
set logscale x
set xtics 0.25,2,8
set mxtics 0
set ytics 0.25
set format x "%.2f"
set format y "%.2f"
set ticscale 0.8 0.4
set border 15 linewidth 0.4 
#set xlabel 'x' font 'Arial,10'
set xlabel 'x'
set ylabel 'oct(x)'
unset grid
set grid lt 9 lw 0.1
unset title
unset key
set samples 500
set output 'octavize.eps'
# define a new linestyle with index 1
set style line 1 lt 1 lw 0.5 
# define function to be drawn by lines
set style function lines
# using the same line style
plot f1(x) ls 1, f2(x) ls 1, f3(x) ls 1,f4(x) ls 1
reset