# gnuplot script for plotting doc data
# created(bruin, 2007-01-02)
# $Id: diag_doc.plt 2 2007-03-22 12:54:39Z Administrator $
#
# plot the doc in diag seq
#
reset
set term post eps enhanced color portrait "Arial" 14
set size 1,0.5
set logscale y
set xtics 20
set mxtics 0
set ytics .2
set mytics 0
#set format y "%.3f"
set xtics nomirror
set ytics nomirror
set ticscale -0.6 0.3
set grid lt 9 lw 0.1
set border 15 linewidth 0.4 
set xlabel 'index' 
set ylabel 'doc'
unset title
unset key
set output 'diag_doc.eps'
plot 'doc100.dat' using ($1):(1./$4) with points pointtype 7 pointsize .5
reset