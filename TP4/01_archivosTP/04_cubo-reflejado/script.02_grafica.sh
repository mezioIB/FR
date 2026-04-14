#!/bin/bash

# Los argumentos de entrada son:
#  1: semiancho del slab [cm]
#  2: espesor del reflector [cm]
#  3: longitud característica del mallado[cm]

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
semiAnchoSlab=${1:-33}
AnchoReflector=${2:-40}
lc=${3:-2.0}

#----------------------------------------------------------------------------------------------------
# Generación de la malla con el programa gmesh
#----------------------------------------------------------------------------------------------------
echo "Generando la malla ..."
sed s/LongitudCaracteristica/$lc/ in_malla.geo.m4         > out_malla.geo.temp1
sed s/SemiAnchoSlab/$semiAnchoSlab/ out_malla.geo.temp1   > out_malla.geo.temp2
sed s/AnchoReflector/$AnchoReflector/ out_malla.geo.temp2 > out_malla.geo
rm out_malla.geo.temp* > /dev/null
# Se genera el mallado (https://gmsh.info/doc/texinfo/gmsh.html#index-Command_002dline-options).
# Donde las opciones usadas son:
#  -v 1: usa el gmsh en modo silencioso, salvo errores
#  -1: Generación de una malla en una dimensión
#  -algo auto: algoritmo para la generación de la malla
#  -o out.slab.msh: se especifica el archivo de salida
gmsh -v 1 -3 -algo auto out_malla.geo -o out.slab.msh
#gmsh out.slab.msh; exit

#----------------------------------------------------------------------------------------------------
# Resolución del problema con FeenoX:
#----------------------------------------------------------------------------------------------------
echo "Resolviendo el reactor ..."
feenox in_reactor.fee 0

#----------------------------------------------------------------------------------------------------
# Graficación del resultado
#----------------------------------------------------------------------------------------------------
echo "Graficando ..."
echo "# Estilos" > out.gnuplot.gp
echo "set style line 11 lc rgb 'red'   dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue'  dashtype 1 lw 2;" >> out.gnuplot.gp
echo "set style line 13 lc rgb 'green' dashtype 1 lw 2;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'distancia al centro [cm]'; " >> out.gnuplot.gp
echo "set key right top;" >> out.gnuplot.gp
echo "set title 'cubo reflejado en una dirección, a dos grupos';" >> out.gnuplot.gp
echo "xn=$semiAnchoSlab; xr=$AnchoReflector" >> out.gnuplot.gp # Ancho del núcleo
echo "set xrange [0:(xn)];" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.flujosYZ.png'; plot 'out.slab.Y.dat' u 1:2 ls 11 w l t 'f_y(y)', 'out.slab.Z.dat' u 1:2 ls 12 w l t 'f_z(z)'"
echo "set arrow from 0, graph 0 to 0, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from xn, graph 0 to xn, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set xrange [0:(xn+xr)];" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.flujosX.png'; plot 'out.slab.X.dat' u 1:2 ls 11 w l t 'rápido', '' u 1:3 ls 12 w l t 'térmico'"


echo "set key left top;" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'relación espectral []'; set output 'out.espectro.png'; plot 'out.slab.X.dat' u 1:4 ls 13 w l notitle"

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"
