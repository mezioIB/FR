#!/bin/bash

moderador=1

# Ejecuto el input "03.CuatroFactores.fee" con el FeenoX, usando el moderador dado
feenox 03.CuatroFactores.fee $moderador > "03.mod${moderador}.datos.txt"

# Grafico la relación entre el k_infinito, y las dos variables independientes
gnuplot 03.conf_3d.gnuplot -p -e "set output '03.mod${moderador}.3d.png'; splot '03.mod${moderador}.datos.txt' u 1:2:6 t 'K' w pm3d"

# Extraigo el máximo k_infinito, para un enriquecimiento del 0.711%
cat 03.mod${moderador}.datos.txt | gawk '{if($2~/0.711/ && $6>Kmax){Kmax=$6;Ropt=$1}}; END {print Ropt" "Kmax}' > 03.mod${moderador}.kmax.txt

# Extraigo el máximo k_infinito, para todos los enriquecimientos
cat 03.mod${moderador}.datos.txt | awk '{if($6>Kinf[$2*1]){Kinf[$2*1]=$6;Ropt[$2*1]=$1}}; END{for(i=0.711;i<95;i+=0.95)print i" "Ropt[i]" "Kinf[i]}' > 03.mod${moderador}.kmax_E.txt
