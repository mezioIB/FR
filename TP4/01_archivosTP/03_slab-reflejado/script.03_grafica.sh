#!/bin/bash

#----------------------------------------------------------------------------------------------------
# Graficación de los resultados obtenidos con el script script.03_bucaCriticidad.sh
#----------------------------------------------------------------------------------------------------
echo "Graficando ..."
echo "# Estilos" > out.gnuplot.gp
echo "set style line 21 lc rgb 'red'   dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 22 lc rgb 'blue'  dashtype 2 lw 1;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set datafile separator \",\"" >> out.gnuplot.gp
echo "set xlabel 'ancho del reflector [cm]';" >> out.gnuplot.gp
echo "set ytics nomirror tc ls 21" >> out.gnuplot.gp
echo "set ylabel 'semi ancho crítico del núcleo [cm]' tc ls 21;" >> out.gnuplot.gp
echo "set y2tics nomirror tc ls 22" >> out.gnuplot.gp
echo "set y2label 'factor de pico' tc ls 22" >> out.gnuplot.gp
echo "set key right top;" >> out.gnuplot.gp
echo "set title 'semi-slab reflejado a dos grupos';" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
echo "set output 'out.convergencia.png';" >> out.gnuplot.gp

gnuplot out.gnuplot.gp -p -e " plot 'out.iteraciones.dat' u 1:2 ls 21 w l t 'semi ancho crítico del núcleo [cm]', '' u 1:4 ls 22 w l t 'factor de pico' axes x1y2"

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"
