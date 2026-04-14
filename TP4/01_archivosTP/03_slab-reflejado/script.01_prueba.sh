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
feenox in_reactor.fee 1

echo "Terminado"
