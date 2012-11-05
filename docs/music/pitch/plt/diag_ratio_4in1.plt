# gnuplot v4.0 script for plotting doc data
# created(bruin, 2007-01-06)
# $Id: diag_ratio_4in1.plt 2 2007-03-22 12:54:39Z Administrator $
#
# layout (4 plots):
#  +-------------+-------------------+
#  |(1)1k        | (2)   5k          |
#  +-------------+-------------------+
#  |(3)2w        | (4) part of 2w    |
#  +-------------+-------------------+
#
# x-axis: idx
# y-axis: ratio in diag_seq
#
reset
set term post eps enhanced color portrait "Arial" 8
# h is horizontal size; v is vertical size
h=1.0
v=0.5
set size   h, v
set origin 0.0, 0.0
set format y "%.2f"
set xtics nomirror
set ytics nomirror
set output 'diag_ratio_4in1.eps'
set multiplot
############################################
# (1) 500 points
set size   h/2., v/2.
set origin 0.0, v/2.
unset key
unset grid
unset title
set xtics 100 
set mxtics 0
set ytics 0.25
set mytics 0
set ticscale -0.4 0.2
set border 15 linewidth 0.4 
set xlabel 'a) sequence size 500'
set ylabel 'ratio'
plot 'doc500.dat' using ($1):($3/$2) with points pointtype 7 pointsize .2
############################################
# (2) 2k points
set size   h/2., v/2.
set origin h/2., v/2.
set xtics 400
set xlabel 'b) sequence size 2000'
plot 'doc2k.dat' using ($1):($3/$2) with points pointtype 7 pointsize .1
############################################
# (3) 5k points
set size   h/2., v/2.
set origin 0.0, 0.0
set xtics 1000
set xlabel 'c) sequence size 5000'
plot 'doc5k.dat' using ($1):($3/$2) with points pointtype 7 pointsize .1
############################################
# (4) part of 5k points
set size   h/2., v/2.
set origin h/2., 0.0
set xrange [0:1000]
set yrange [1.0:1.5]
set xtics 200
set ytics 0.1
set xlabel 'd) sequence size 5000 (low-left part)'
plot 'doc5k.dat' using ($1):($3/$2) with points pointtype 7 pointsize .3
############################################
unset multiplot
reset


