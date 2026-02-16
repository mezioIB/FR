# Archivo de configuración para GNUPlot
# Para más ejemplos ir a la página oficial:
# http://www.gnuplot.info/

# Defino estilo de línea
# Nombre del estilo: 11
# Color: red
# Ancho de línea: 1
set style line 11 lc rgb 'red' lw 1;

# Defino estilo de lía
# Nombre del estilo: 12
# Color: blue
# Ancho de línea: 2
set style line 12 lc rgb 'blue' lw 2;

# Nombres de ejes y títulos
set xlabel 'eje X [unidad]';
set ylabel 'eje Y [unidad]';
set title 'Comparación entre crecimientos';

# Defino límites para los ejes, para que vayan de cero a uno
set xrange [0:1];
set yrange [0:1];

# Coloco la leyenda arriba a la izquierda
set key left top;

# Defino para que la salida sea a un archivo PNG, y que la fuente sea Arial con tamaño 10
set terminal pngcairo size 800,400 enhanced font 'Arial,10';

# Ejemplo de uso
#gnuplot 02.conf.gnuplot -p -e "set output '02.salida.png'; plot '02.datos.dat' u 1:2 ls 11 w l t 'cuadrática', '' u 1:3 ls 12 w l t 'cúbica'"