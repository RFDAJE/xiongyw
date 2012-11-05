# gnuplot v4.0 script for plotting diag sequence by arrows
# created(bruin, 2007-01-10)
# $Id: diag_arrow21.plt 2 2007-03-22 12:54:39Z Administrator $
#
#
# x-axis: denomerator
# y-axis: numerator
# total points: 21
#
reset
set term post eps enhanced color portrait "Arial" 12
set size square
set size 0.7, 0.45
set output 'diag_arrow21.eps'
set xrange [0:14]
set yrange [0:14]
set xtics 1
set ytics 1
set ticscale 0.4 0.2
set border 15 linewidth 0.4 
set grid lt 9 lw 0.1
set grid 
unset key
set xlabel "denominator"
set ylabel "numerator"
# points are in red (lt 1) circled dots;
# arrow are black (lt -1) with "head" but not "filled"
# two bounding lines in gray (lt 9)
plot 'arrow21.dat' with vectors head lt -1 lw 0.1, \
     'arrow21.dat' using 1:2 with points linetype 1 pointtype 7 pointsize .8, \
     2*x lt 9, \
     x lt 9 
reset


