#!/bin/bash

#----------------------------------------------------------------------------------------------------
# Graficación de los resultados obtenidos con el script script.03_bucaCriticidad.sh
#----------------------------------------------------------------------------------------------------
echo "Graficando ..."
echo "# Estilos" > out.gnuplot.gp
echo "set style line 11 lc rgb 'red'   dashtype 1 lw 1.5 ps 2 pt 4 pi 1;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue'  dashtype 1 lw 1.5 ps 2 pt 6 pi 1;" >> out.gnuplot.gp
echo "set style line 13 lc rgb 'green' dashtype 1 lw 1.5 ps 2 pt 8 pi 1;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set datafile separator \",\"" >> out.gnuplot.gp
echo "set xlabel 'radio [cm]'; " >> out.gnuplot.gp
echo "set ylabel 'reactividad [pcm]';" >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'cilindro infinito desnudo a dos grupos';" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set output 'out.rhoVSd.png'; plot 'out.iteraciones.24_10_0.5.dat' u 1:2 ls 11 t 'lc=10cm', 'out.iteraciones.24_1_0.5.dat' u 1:2 ls 12 t 'lc=1cm', 'out.iteraciones.24_0.01_0.5.dat' u 1:2 ls 13 t 'lc=0.01cm'"

echo "set style line 21 lc rgb 'red'   dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 22 lc rgb 'blue'  dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set style line 23 lc rgb 'red'   dashtype 2 lw 2;" >> out.gnuplot.gp
echo "set style line 24 lc rgb 'blue'  dashtype 2 lw 1;" >> out.gnuplot.gp
echo "set xlabel 'tamaño característico celda cerca del centro (-) o de la periferia (--) [cm]';" >> out.gnuplot.gp
echo "set logscale x;" >> out.gnuplot.gp
echo "set ytics nomirror tc ls 21" >> out.gnuplot.gp
echo "set ylabel 'tamaño crítico [cm]' tc ls 21;" >> out.gnuplot.gp
echo "set y2tics nomirror tc ls 22" >> out.gnuplot.gp
echo "set y2label 'tiempo de cálculo [s]' tc ls 22" >> out.gnuplot.gp
echo "set key center top;" >> out.gnuplot.gp

gnuplot out.gnuplot.gp -p -e "set output 'out.convergencia_lc.png'; plot 'out.iteraciones.div_lcR.dat' u 1:2 ls 21 w l t '(c) tamaño crítico [cm]', '' u 1:5 ls 22 w l t '(c) tiempo de cálculo [s]' axes x1y2, 'out.iteraciones.div_lcC.dat' u 1:2 ls 23 w l t '(p) tamaño crítico [cm]' axes x1y1, '' u 1:5 ls 24 w l t '(p) tiempo de cálculo [s]' axes x1y2"


echo "set xlabel 'número de divisiones ';" >> out.gnuplot.gp
echo "unset logscale x;" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set output 'out.convergencia_div.png'; plot 'out.iteraciones.lcR_lcC.dat' u 1:2 ls 21 w l t '(c) tamaño crítico [cm]', '' u 1:5 ls 22 w l t '(c) tiempo de cálculo [s]' axes x1y2"

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"
