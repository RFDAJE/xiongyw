# gnuplot v4.0 script for plotting ratio_asc sequence data
# created(bruin, 2007-01-13)
# $Id: ratioasc_ratio_doc.plt 2 2007-03-22 12:54:39Z Administrator $
#
# layout (2 plots):
#  +-------------+-------------------+
#  |(1) ratio    | (2)  doc          |
#  +-------------+-------------------+
#
# x-axis: idx
# y-axis: ratio (1) and doc (2)
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
set ticscale 0.4 0.3
set border 15 linewidth 0.4 
set output 'ratioasc_ratio_doc.eps'
set multiplot
############################################
# (1) ratio
set size   h/2., v
set origin 0.0, 0.0
set xtics 100
set mxtics 0
set ytics .25
set mytics 0
set format y "%.2f"
set grid lt 9 lw 0.1
set xlabel 'index' 
set ylabel 'ratio'
unset title
unset key
plot 'doc500.dat' using ($1):($9/$8) with points pointtype 7 pointsize .2
#plot 'doc500.dat' using ($1):($9/$8) with dots
############################################
# (2) doc
set size   h/2., v
set origin h/2., 0.0
set logscale y
set mxtics 0
set ytics .2
set mytics 0
#set format y "%.3f"
set format y "%g"
#set grid lt 9 lw 0.1
unset grid
set ylabel 'doc'
unset title
unset key
plot 'doc500.dat' using ($1):(1./$10) with points pointtype 7 pointsize .3
############################################
unset multiplot
reset

