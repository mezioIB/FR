# Archivo de configuración para GNUPlot
# Para más ejemplos ir a la página oficial:
# http://www.gnuplot.info/

# Nombres de ejes y títulos
set xlabel 'Relación de moderación (R = N_M/N_U)';
set ylabel 'Enriquecimiento (E = N_{U235}/N_U) [%]';
set title 'k_{{/Symbol \245}}';

# Defino límites para los ejes, para que vayan de cero a uno
set yrange [0:100];

# Quito la leyenda
set nokey

# Defino para que la salida sea a un archivo PNG, y que la fuente sea Arial con tamaño 10
set terminal pngcairo size 800,400 enhanced font 'Arial,10';