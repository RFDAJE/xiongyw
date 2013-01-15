# gnuplot script for plotting cent~doc relation
# created(bruin, 2007-01-14)
# $Id: cent_doc_steps.plt 2 2007-03-22 12:54:39Z Administrator $
#
reset
set term post eps enhanced color portrait "Arial" 12
set size 1.0,0.4
set xrange [0:1200]
set logscale y
set xtics nomirror 100
set mxtics 0
set ytics nomirror 0.1581
set mytics 0
set ticscale -0.8 0.4
set border 15 linewidth 0.4 
set format x "%g"
set format y "%.4f"
set xlabel 'cent' 
set ylabel 'doc'
#set grid lt 9 lw 0.3
set grid lt 0 lw 0.3
unset title
unset key
set output 'cent_doc_steps.eps'
# define a new linestyle with index 1
set style line 1 lt 1 lw 0.5 
# define function to be drawn by lines
set style function lines
# using the same line style
plot 'cent_doc.dat' ls 1 with steps
reset