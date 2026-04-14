#!/bin/bash

#Generación de la malla con el programa gmesh 
echo "Generando la malla ..."
# (https://gmsh.info/doc/texinfo/gmsh.html#Command_002dline-options).
# Donde las opciones usadas son:
#  -1: Generación de una malla en una dimensión
#  -algo auto: algoritmo para la generación de la malla
#  -o out.slab.msh: se especifica el archivo de salida
gmsh -1 -algo auto slab.geo -o out.slab.msh


# El siguiente paso, es usar la malla generada, para correr el FeenoX:
echo "Resolviendo el reactor ..."
feenox slab.fee

# Se grafica el resultado
echo "Graficando los resultados ..."
echo "# Estilos" > out.gnuplot.gp
echo "set termoption dash;" >> out.gnuplot.gp
echo "set style line 11 lc rgb 'red'  lw 1 ps 1 pt 6;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue' linetype 2 lw 1;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'distancia [cm]'; " >> out.gnuplot.gp
echo "set ylabel 'flujo de neutrones [n/s]'; " >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'slab desnudo a un grupo';" >> out.gnuplot.gp
#echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
#echo "set output 'out.flujos.png';" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e 'plot "out.slab.dat" u 1:2 ls 11 w p t "numérico", "" u 1:3 ls 12 w l t "analítico"'

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"
