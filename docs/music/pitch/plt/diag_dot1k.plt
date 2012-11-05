# gnuplot v4.0 script for plotting diag sequence by dots
# created(bruin, 2007-01-10)
# $Id: diag_dot1k.plt 2 2007-03-22 12:54:39Z Administrator $
#
#
# x-axis: denomerator
# y-axis: numerator
# total points: 1k
#
reset
set term post eps enhanced color portrait "Arial" 12
set size square
set size 0.7, 0.45
set output 'diag_dot1k.eps'
set xrange [0:50]
set yrange [0:50]
set xtics nomirror 10
set ytics nomirror 10
set ticscale 0.4 0.2
set border 15 linewidth 0.4 
set grid lt 9 lw 0.1
#unset grid 
unset key
set xlabel "denominator"
set ylabel "numerator"
plot 'doc1k.dat' using 2:3 with points linetype 1 pointtype 7 pointsize .4
reset


