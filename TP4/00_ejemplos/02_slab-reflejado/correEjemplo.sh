#!/bin/bash

#Generación de la malla con el programa gmesh 
echo "Generando la malla ..."
# (https://gmsh.info/doc/texinfo/gmsh.html#Command_002dline-options).
# Donde las opciones usadas son:
#  -1: Generación de una malla en una dimensión
#  -algo auto: algoritmo paa la generación de la malla
#              auto, meshadapt, del2d, front2d, delquad, pack, initial2d, del3d, front3d, mmg3d, hxt, initial3d
#  -o out.slab.msh: se especifica el archivo de salida
gmsh -v 0 -1 -algo auto slab_refl.geo -o out.slab_refl.msh

# El siguiente paso, es usar la malla generada, para correr el milonga:
echo "Resoviendo el reactor ..."
feenox slab_refl.fee

# Se grafica el resultado
echo "Graficando ..."
echo "# Estilos" > out.gnuplot.gp
echo "set style line 11 lc rgb 'red'   dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue'  dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 13 lc rgb 'green' dashtype 1 lw 2;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'distancia [cm]'; " >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'slab reflejado a dos grupos';" >> out.gnuplot.gp
echo "xn=45;" >> out.gnuplot.gp # Ancho del núcleo
echo "set arrow from 0, graph 0 to 0, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from xn, graph 0 to xn, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set xrange [-40:90];" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp

gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.flujos.png'; plot 'out.slab_refl.dat' u 1:2 ls 11 w l t 'rápido', '' u 1:3 ls 12 w l t 'térmico'"

echo "set logscale y;" >> out.gnuplot.gp
echo "set autoscale x;" >> out.gnuplot.gp
echo "mul=8.56; mur=40.88; muc=2.12;" >> out.gnuplot.gp #tamaños característicos
echo "set xrange [(0-4*mul):(xn+4*mur)];" >> out.gnuplot.gp
echo "set style line 14 lc rgb 'gray' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set grid xtics ls 14;" >> out.gnuplot.gp
echo 'set xtics ("{/:Italic 4\/{/Symbol l}_l}" -4*mul ,"{/:Italic 2\/{/Symbol l}_l}" -2*mul ,\
    "{/:Italic 4\/{/Symbol l}_r}" 4*mur+xn ,"{/:Italic 3\/{/Symbol l}_r}" 3*mur+xn ,"{/:Italic 2\/{/Symbol l}_r}" 2*mur+xn ,"{/:Italic 1\/{/Symbol l}_r}" 1*mur+xn , \
    "{/:Italic 4\/{/Symbol m}}" 4*muc , "{/:Italic 4\/{/Symbol m}}" -4*muc+xn , 0 , xn);' >> out.gnuplot.gp
echo "Sl=2.86; Sr=20.0; Sc=0.25;" >> out.gnuplot.gp #relaciones espectrales estacionarias
echo "set arrow from graph 0, first Sc to graph 1, first Sc nohead lc rgb 'blue' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from (0-4*mul), Sl to 0, Sl nohead lc rgb 'red' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from (xn), Sr to (xn+4*mur), Sr nohead lc rgb 'red' dashtype 1 lw 1;" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'relación espectral []'; set output 'out.espectro.png'; plot 'out.slab_refl.dat' u 1:4 ls 13 w l notitle"

rm out.gnuplot.gp
echo "Terminado"
