# gnuplot v4.0 script for plotting doc data
# created(bruin, 2007-01-06)
# $Id: ratioasc_doc.plt 2 2007-03-22 12:54:39Z Administrator $
#
# layout (2 plots):
#  +-------------+-------------------+
#  |(1)1k        | (2)   2w          |
#  +-------------+-------------------+
#
# x-axis: idx
# y-axis: doc in ratio_asc
#
reset
set term post eps enhanced color portrait "Arial" 8
# h is horizontal size; v is vertical size
h=1.0
v=0.25
set size   h, v
set origin 0.0, 0.0
set format y "%g"
set xtics nomirror
set ytics nomirror
set logs y
set output 'ratioasc_doc.eps'
set multiplot
############################################
# (1) 1k points
set size   h/2., v
set origin 0.0, 0.0
unset key
unset grid
unset title
set xtics 0.1
set mxtics 0
set ytics 0.1
set mytics 0
set ticscale -0.4 0.2
set border 15 linewidth 0.4 
set xlabel 'a) sequence size 1000'
set ylabel 'doc'
plot 'doc1k.dat' using ($9/$8):(1./$10) with points pointtype 7 pointsize .1
############################################
# (2) 2w points
set size   h/2., v
set origin h/2., 0.0
set xlabel 'b) sequence size 20000'
plot 'doc2w.dat' using ($9/$8):(1./$10) with dots
############################################
unset multiplot
reset


