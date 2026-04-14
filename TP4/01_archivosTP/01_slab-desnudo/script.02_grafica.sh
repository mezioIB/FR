#!/bin/bash

# Los argumentos de entrada son:
#  1: el ancho del slab [cm]
#  2: longitud característica del mallado [cm]
#  3: Condición de contorno. Pueden ser  vacuum|null

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
anchoSlab=${1:-40}
lc=${2:-1}
cc=${3:-null}

#----------------------------------------------------------------------------------------------------
# Generación de la malla con el programa gmesh
#----------------------------------------------------------------------------------------------------
echo "Generando la malla ..."
# Se inicializan la longitud caracteristica y el ancho del slab con los argumentos dados
sed s/LongitudCaracteristica/$lc/ in_malla.geo.m4 > out_malla.geo.temp
sed s/AnchoSlab/$anchoSlab/ out_malla.geo.temp > out_malla.geo
rm out_malla.geo.temp > /dev/null
# Se genera el mallado (https://gmsh.info/doc/texinfo/gmsh.html#Command_002dline-options).
# Donde las opciones usadas son:
#  -v 1: usa el gmsh en modo silencioso, salvo errores
#  -1: Generación de una malla en una dimensión
#  -algo auto: algoritmo para la generación de la malla
#  -o out.slab.msh: se especifica el archivo de salida
gmsh -v 1 -1 -algo auto out_malla.geo -o out.slab.msh

#----------------------------------------------------------------------------------------------------
# Resolución del problema con FeenoX:
#----------------------------------------------------------------------------------------------------
echo "Resolviendo el reactor ..."
feenox in_reactor.fee $cc 0

#----------------------------------------------------------------------------------------------------
# Graficación del resultado
#----------------------------------------------------------------------------------------------------
echo "Graficando ..."
echo "# Estilos" > out.gnuplot.gp
echo "set style line 11 lc rgb 'red'   dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue'  dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 13 lc rgb 'green' dashtype 1 lw 2;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'distancia [cm]'; " >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'slab desnudo a dos grupos';" >> out.gnuplot.gp
echo "xn=$anchoSlab;" >> out.gnuplot.gp # Ancho del núcleo
echo "set arrow from 0, graph 0 to 0, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from xn, graph 0 to xn, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set xrange [0:xn];" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.flujos.png'; plot 'out.slab.dat' u 1:2 ls 11 w l t 'rápido', '' u 1:3 ls 12 w l t 'térmico'"

#echo "set logscale y;" >> out.gnuplot.gp
echo "muNuc=1.41;" >> out.gnuplot.gp #tamaños característicos
echo "S1=1.2515;" >> out.gnuplot.gp #relaciones espectrales fundamentales
echo "set style line 14 lc rgb 'gray' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set grid xtics ls 14;" >> out.gnuplot.gp
echo 'set xtics ("{/:Italic 4\/{/Symbol m}}" 4*muNuc , "{/:Italic 4\/{/Symbol m}}" -4*muNuc+xn , 0 , xn);' >> out.gnuplot.gp
echo "set arrow from graph 0, first S1 to graph 1, first S1 nohead lc rgb 'blue' dashtype 1 lw 1;" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'relación espectral []'; set output 'out.espectro.png'; plot 'out.slab.dat' u 1:4 ls 13 w l notitle"

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"
