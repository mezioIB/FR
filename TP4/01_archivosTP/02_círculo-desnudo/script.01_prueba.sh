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
feenox in_reactor.fee $cc 1

echo "Terminado"
