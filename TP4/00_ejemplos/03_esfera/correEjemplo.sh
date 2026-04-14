#!/bin/bash

graficaEsfera(){
# Graficamos una esfera entera
sed s/DatoLongitudCaracteristicaB/10/ esfera_reflejada_entera.geo.m4 > out.geo.temp1
sed s/DatoLongitudCaracteristicaI/3/  out.geo.temp1                  > out.geo.temp2
sed s/DatoLongitudCaracteristicaC/10/ out.geo.temp2                  > out.geo.temp3
sed s/DatoEspesorReflector/30/        out.geo.temp3                  > out.geo.temp4
sed s/DatoFraccion/4/                 out.geo.temp4                  > out.geo.temp5
sed s/DatoRadio/30/                   out.geo.temp5                  > out.esfera_reflejada_entera.geo
rm out.geo.temp* > /dev/null
gmsh -3 -algo del3d out.esfera_reflejada_entera.geo -o out.esfera_reflejada.msh
gmsh out.esfera_reflejada.msh visualizaEsfera.gmsh

# Luego creamos una animación con esa malla
gmsh out.esfera_reflejada.msh exportaMalla.gmsh

convert -delay 20 -loop 0 out.anim-*.png out.anim.gif
}

grafico1D(){
# Se grafica el resultado
echo "# Estilos" > out.gnuplot.gp
echo "set style line 11 lc rgb 'red'   dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set style line 12 lc rgb 'blue'  dashtype 1 lw 1;" >> out.gnuplot.gp
echo "set style line 13 lc rgb 'green' dashtype 1 lw 1;" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'radio [cm]'; " >> out.gnuplot.gp
echo "set key right top;" >> out.gnuplot.gp
echo "set title 'esfera reflejada a dos grupos';" >> out.gnuplot.gp
echo "set arrow from 33.7, graph 0 to 33.7, graph 1 nohead lc rgb 'black' dashtype 2 lw 1;" >> out.gnuplot.gp
echo "set xrange [0:63.7];" >> out.gnuplot.gp
echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp

gnuplot out.gnuplot.gp -p -e "set ylabel 'flujo de neutrones [n/s]'; set output 'out.1D.flujos.png'; plot 'out.flujo1D.txt' u 1:2 ls 11 w l t 'rápido', '' u 1:3 ls 12 w l t 'térmico'"
gnuplot out.gnuplot.gp -p -e "set ylabel 'relación espectral []'; set output 'out.1D.espectro.png'; plot 'out.flujo1D.txt' u 1:4 ls 13 w l notitle"

rm out.gnuplot.gp
}



grafico2D(){
# Se grafica el resultado
echo "# Estilos" > out.gnuplot.gp
# http://www.gnuplotting.org/tag/colormap/
echo "load 'parula.pal';" >> out.gnuplot.gp
echo "# Configuraciones" >> out.gnuplot.gp
echo "set xlabel 'X [cm]'; " >> out.gnuplot.gp
echo "set ylabel 'Y [cm]'; " >> out.gnuplot.gp
echo "set key left bmargin;" >> out.gnuplot.gp
echo "set pm3d;" >> out.gnuplot.gp
echo "set hidden3d;" >> out.gnuplot.gp
echo "set size square 1,1;" >> out.gnuplot.gp
echo "unset ztics;" >> out.gnuplot.gp
echo "unset zlabel;" >> out.gnuplot.gp
echo "set colorbox vertical user origin .8,.1 size .02,.8;" >> out.gnuplot.gp
echo "set view 0,0,1,1;" >> out.gnuplot.gp
echo "set view equal xy;" >> out.gnuplot.gp
echo "set xrange [0:63.7];" >> out.gnuplot.gp
echo "set yrange [0:63.7];" >> out.gnuplot.gp
echo "set cblabel 'escala de colores';" >> out.gnuplot.gp

echo "set terminal pngcairo size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp
#echo "set terminal wxt size 800,400 enhanced font 'Ubuntu,10';" >> out.gnuplot.gp

gnuplot "out.gnuplot.gp" -p -e "set title 'flujo rápido [n/s]'; set output 'out.2D.flujo_rapido.png'; set cbrange [0:7]; splot 'out.flujo2D.txt' u 1:2:3 w l notitle"
gnuplot "out.gnuplot.gp" -p -e "set title 'flujo térmico [n/s]'; set output 'out.2D.flujo_térmico.png'; set cbrange [0:7]; splot 'out.flujo2D.txt' u 1:2:4 w l notitle"
gnuplot "out.gnuplot.gp" -p -e "set title 'relación espectral'; set output 'out.2D.rel_espectral.png'; set cbrange [1.2:3.2]; splot 'out.flujo2D.txt' u 1:2:5 w l notitle"

rm out.gnuplot.gp
}

creaEsfera(){
# Generamos la malla en función del número de divisiones azimutales
if [ $3 == 1 ]
then
  # Se inicializan la longitud caracteristica y el radio del círculo con los argumentos dados
  sed s/DatoLongitudCaracteristicaB/$6/ esfera_reflejada_entera.geo.m4        > out.esfera_reflejada_entera.geo.temp1
  sed s/DatoLongitudCaracteristicaI/$5/ out.esfera_reflejada_entera.geo.temp1 > out.esfera_reflejada_entera.geo.temp2
  sed s/DatoLongitudCaracteristicaC/$4/ out.esfera_reflejada_entera.geo.temp2 > out.esfera_reflejada_entera.geo.temp3
  sed s/DatoEspesorReflector/$2/        out.esfera_reflejada_entera.geo.temp3 > out.esfera_reflejada_entera.geo.temp4
  sed s/DatoRadio/$1/                   out.esfera_reflejada_entera.geo.temp4 > out.esfera_reflejada_entera.geo
  rm out.esfera_reflejada_entera.geo.temp* > /dev/null

  # Se genera el mallado
  gmsh -3 -algo del3d out.esfera_reflejada_entera.geo -o out.esfera_reflejada.msh> /dev/null
else
  # Se inicializan la longitud caracteristica, el radio de la esfera y su fracción
  sed s/DatoLongitudCaracteristicaB/$6/ esfera_reflejada_fraccion.geo.m4        > out.esfera_reflejada_fraccion.geo.temp1
  sed s/DatoLongitudCaracteristicaI/$5/ out.esfera_reflejada_fraccion.geo.temp1 > out.esfera_reflejada_fraccion.geo.temp2
  sed s/DatoLongitudCaracteristicaC/$4/ out.esfera_reflejada_fraccion.geo.temp2 > out.esfera_reflejada_fraccion.geo.temp3
  sed s/DatoEspesorReflector/$2/        out.esfera_reflejada_fraccion.geo.temp3 > out.esfera_reflejada_fraccion.geo.temp4
  sed s/DatoFraccion/$3/                out.esfera_reflejada_fraccion.geo.temp4 > out.esfera_reflejada_fraccion.geo.temp5
  sed s/DatoRadio/$1/                   out.esfera_reflejada_fraccion.geo.temp5 > out.esfera_reflejada_fraccion.geo
  rm out.esfera_reflejada_fraccion.geo.temp* > /dev/null

  # Se genera el mallado
  gmsh -3 -algo del3d out.esfera_reflejada_fraccion.geo -o out.esfera_reflejada.msh > /dev/null
fi
}


#graficaEsfera

radio=33.7
espRefl=30
fracEsf=64
lcC=1
lcI=0.5
lcB=2

echo "creando la malla..."
creaEsfera $radio $espRefl $fracEsf $lcC $lcI $lcB
echo "calculando la reactividad"
feenox esfera_reflejada.fee $radio $espRefl $fracEsf $lcC $lcI $lcB
echo "graficando"
grafico2D
grafico1D

