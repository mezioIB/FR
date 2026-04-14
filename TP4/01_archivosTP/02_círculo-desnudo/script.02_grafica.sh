#!/bin/bash

# Los argumentos de entrada son:
#  1: radio del círculo [cm]
#  2: número de divisiones del círculo. Puede ser cualquier número natural que no sea primo, o el 1, 2 o 3
#  3: longitud característica del mallado cerca del centro [cm]
#  4: longitud característica del mallado cerca del borde [cm]
#  5: Condición de contorno. Pueden ser  vacuum | {null}

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
radio=${1:-30}
divisiones=${2:-1}
lcC=${3:-0.9}
lcR=${4:-0.9}
cc=${5:-null}

#----------------------------------------------------------------------------------------------------
# Generación de la malla con el programa gmesh
#----------------------------------------------------------------------------------------------------
echo "Generando la malla ..."
# Generamos la malla en función del número de divisiones azimutales
if [ $divisiones -eq 1 ]
then
    # Se inicializan la longitud caracteristica y el radio del círculo con los argumentos dados
    sed s/DatoLongitudCaracteristicaCentro/$lcC/ in_malla-entera.geo.m4     > out_malla-entera.geo.temp1
    sed s/DatoLongitudCaracteristicaBorde/$lcR/  out_malla-entera.geo.temp1 > out_malla-entera.geo.temp2
    sed s/DatoRadio/$radio/ out_malla-entera.geo.temp2                      > out_malla.geo
    rm out_malla-entera.geo.temp* > /dev/null
    # Se genera el mallado
    gmsh -2 -algo del2d out_malla.geo -o out_malla.msh> /dev/null
else
    # Se inicializan la longitud caracteristica, el radio del círculo y su fracción con los argumentos dados
    sed s/DatoLongitudCaracteristicaCentro/$lcC/ in_malla-fraccion.geo.m4    > out_malla-fraccion.geo.temp1
    sed s/DatoLongitudCaracteristicaBorde/$lcR/ out_malla-fraccion.geo.temp1 > out_malla-fraccion.geo.temp2
    sed s/DatoFraccion/$divisiones/ out_malla-fraccion.geo.temp2             > out_malla-fraccion.geo.temp3
    sed s/DatoRadio/$radio/ out_malla-fraccion.geo.temp3                     > out_malla.geo
    rm out_malla-fraccion.geo.temp* > /dev/null
    # Se genera el mallado
    gmsh -2 -algo del2d out_malla.geo -o out_malla.msh > /dev/null
fi


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
echo "set xlabel 'distancia al centro [cm]'; " >> out.gnuplot.gp
echo "set key center bottom;" >> out.gnuplot.gp
echo "set title 'cilindro infinito desnudo a dos grupos';" >> out.gnuplot.gp
echo "xn=$radio;" >> out.gnuplot.gp # Ancho del núcleo
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
