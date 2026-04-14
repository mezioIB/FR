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
feenox in_reactor.fee $cc 1

echo "Terminado"
