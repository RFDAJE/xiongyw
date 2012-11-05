# gnuplot script for plotting cent(x) function
# created(bruin, 2007-01-02)
# $Id: cent.plt 2 2007-03-22 12:54:39Z Administrator $
#
reset
c(x)=1200.*log(x)/log(2.)
set term post eps enhanced color portrait "Arial" 14
set size 0.8,0.4
#set size ratio 0.5
set xrange [1:2]
set yrange [1:1200]
#set logscale x
set xtics  .25
set mxtics 0
set ytics 300
set mytics 0
set ticscale 0.8 0.4
set border 15 linewidth 0.4 
set format x "%.2f"
#set xlabel 'x' font 'Arial,10'
set xlabel 'ratio' 
set ylabel 'cent'
#unset grid
set grid lt 9 lw 0.1
unset title
unset key
set samples 200
set output 'cent.eps'
# define a new linestyle with index 1
set style line 1 lt 1 lw 0.5 
# define function to be drawn by lines
set style function lines
# using the same line style
plot c(x) ls 1
reset