#!/bin/bash

# Los argumentos de entrada son:
#  1: semiancho del slab [cm]
#  2: espesor del reflector [cm]
#  3: longitud característica del mallado cerca del centro [cm]
#  4: longitud característica del mallado cerca de la interfaz [cm]
#  5: longitud característica del mallado cerca del borde [cm]

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
semiAnchoSlab=${1:-15}
AnchoReflector=${2:-20}
lcC=${3:-0.5}
lcI=${4:-0.5}
lcB=${5:-0.5}

#----------------------------------------------------------------------------------------------------
# Generación de la malla con el programa gmesh
#----------------------------------------------------------------------------------------------------
echo "Generando la malla ..."
sed s/LongitudCaracteristicaCentro/$lcC/ in_malla.geo.m4       > out_malla.geo.temp1
sed s/LongitudCaracteristicaInterfaz/$lcI/ out_malla.geo.temp1 > out_malla.geo.temp2
sed s/LongitudCaracteristicaBorde/$lcB/ out_malla.geo.temp2    > out_malla.geo.temp3
sed s/SemiAnchoSlab/$semiAnchoSlab/ out_malla.geo.temp3        > out_malla.geo.temp4
sed s/AnchoReflector/$AnchoReflector/ out_malla.geo.temp4      > out_malla.geo
rm out_malla.geo.temp* > /dev/null
# Se genera el mallado (https://gmsh.info/doc/texinfo/gmsh.html#index-Command_002dline-options).
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
echo "set xlabel 'distancia desde el centro del slab [cm]'; " >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'semi-slab reflejado a dos grupos';" >> out.gnuplot.gp
echo "xn=$semiAnchoSlab; xr=$AnchoReflector" >> out.gnuplot.gp # Ancho del núcleo
echo "set arrow from 0, graph 0 to 0, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from xn, graph 0 to xn, graph 1 nohead lc rgb 'black' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set xrange [0:(xn+xr)];" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.flujos.png'; plot 'out.slab.dat' u 1:2 ls 11 w l t 'rápido', '' u 1:3 ls 12 w l t 'térmico'"

#echo "set logscale y;" >> out.gnuplot.gp
echo "muNuc=1.41; l3=5.19; l4=2.85; l3y4=6.32;" >> out.gnuplot.gp #tamaños característicos
echo "S1=1.2515; S3=3.0435;" >> out.gnuplot.gp #relaciones espectrales fundamentales
echo "set style line 14 lc rgb 'gray' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set grid xtics ls 14;" >> out.gnuplot.gp
echo 'set xtics ("{/:Italic 2\/{/Symbol m}}" xn-2*muNuc , "{/:Italic 4\/{/Symbol m}}" xn-4*muNuc , 0 , xn, xn+xr, \
    "{/:Italic 4\/{/Symbol l}_3}" xn+4*l3, "{/:Italic 4\/{/Symbol l}_4}" xn+4*l4, "{/:Italic 4\/({/Symbol l}_3+{/Symbol l}_4})" xn+4*l3y4);' >> out.gnuplot.gp
echo "set arrow from 0,S1 to xn,S1 nohead lc rgb 'blue' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set arrow from xn,S3 to (xn+xr),S3 nohead lc rgb 'red' dashtype 1 lw 1;" >> out.gnuplot.gp
gnuplot out.gnuplot.gp -p -e "set ylabel 'relación espectral []'; set output 'out.espectro.png'; plot 'out.slab.dat' u 1:4 ls 13 w l notitle"

rm out.gnuplot.gp 2> /dev/null
echo "Terminado"


gmsh out_flujos.msh
