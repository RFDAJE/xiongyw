# gnuplot v4.0 script for plotting doc data
# created(bruin, 2007-01-14)
# $Id: docdes_ratio_2in1.plt 2 2007-03-22 12:54:39Z Administrator $
#
# layout (2 plots):
#  +-------------+-------------------+
#  |(1)1k        | (2)   2k          |
#  +-------------+-------------------+
#
# x-axis: idx
# y-axis: ratio in doc_des sequence
#
reset
set term post eps enhanced color portrait "Arial" 8
# h is horizontal size; v is vertical size
h=1.0
v=0.25
set size   h, v
set origin 0.0, 0.0
set format y "%.2f"
set xtics nomirror
set ytics nomirror
set output 'docdes_ratio_2in1.eps'
set multiplot
############################################
# (1) 500 points
set size   h/2., v
set origin 0.0, 0.0
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
plot 'doc500.dat' using ($1):($6/$5) with points pointtype 7 pointsize .2
############################################
# (2) 2k points
set size   h/2., v
set origin h/2., 0.0
set xtics 400
set xlabel 'b) sequence size 2000'
plot 'doc2k.dat' using ($1):($6/$5) with points pointtype 7 pointsize .1
############################################
unset multiplot
reset


