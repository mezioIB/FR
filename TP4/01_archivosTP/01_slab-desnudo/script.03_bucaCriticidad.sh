#!/bin/bash

# Los argumentos de entrada son:
#  1: el ancho mínimo del slab [cm]
#  2: el ancho máximo del slab [cm]
#  3: umbral aceptable de reactividad [pcm]
#  4: Condición de contorno. Pueden ser  vacuum|null

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
anchoSlabMin=${1:-20}
anchoSlabMax=${2:-60}
tol=${3:-100}
cc=${4:-null}
archSal="out.iteraciones"


#----------------------------------------------------------------------------------------------------
# función que genera la malla y calcula el K_eff
#----------------------------------------------------------------------------------------------------
function calculaK(){
    # Renombramos las variables de entrada
    anchoSlab=$1; lc=$2; cc=$3

    # Generación de la malla con el programa gmesh
    # Se inicializan la longitud caracteristica y el ancho del slab con los argumentos dados
    sed s/LongitudCaracteristica/$lc/ in_malla.geo.m4 > out_malla.geo.temp
    sed s/AnchoSlab/$anchoSlab/ out_malla.geo.temp > out_malla.geo
    rm out_malla.geo.temp > /dev/null
    gmsh -v 1 -1 -algo auto out_malla.geo -o out.slab.msh
    rm out_malla.geo > /dev/null

    # Resolución del problema con FeenoX:
    feenox in_reactor.fee $cc 1
    rm out.slab.msh > /dev/null
}

#----------------------------------------------------------------------------------------------------
# función para imprimir simultáneamente en pantalla y en el archivo
#----------------------------------------------------------------------------------------------------
function imprime(){
    echo $1
    echo "${1// /,}" >> "$2"
}

#----------------------------------------------------------------------------------------------------
# función que realiza una búsqueda dicotómica
#----------------------------------------------------------------------------------------------------
function dichotomic_search(){
    min=$1
    max=$2
    lc=$3; cc=$4; tol=$5; archSalida=$6

    target=0  # valor objetivo para la reactividad
    error=1000 # valor inicial de reactividad en valor absoluto

    while (( $(bc -l<<<"$error>$tol") )); do
        # Calcula el promedio entre min y max, redondeando a 4 decimales
        mean=$(bc <<< "scale=4; ($min+$max)/2")

        salida=$(calculaK $mean $lc $cc)
        #IFS=':'; arrSalida=($salida); unset IFS; current=${arrSalida[0]}
        current=$(echo "$salida" | cut -d " " -f 1)
        error=$(bc <<< "scale=4; $current-$target")
        error=${error#-}
        imprime "$mean $salida" $archSalida
        if (( $(bc -l<<<"$current<$target") ))
            then min=$mean
            else max=$mean
        fi
    done
}


#----------------------------------------------------------------------------------------------------
# Busco el tamaño crítico
#----------------------------------------------------------------------------------------------------
encabezado="ancho núcleo [cm],rho [pcm],factor de pico,tiempo de cáculo [s],memoria máxima usada [Gigabytes]"
echo "#lc [cm],$encabezado" > "$archSal.dat"

for lc in 10 1 0.01
do
    echo "#$encabezado" > "$archSal.$lc.dat"
    echo "cálculo inicial para longitud característica de $lc cm..."
    salida=$(calculaK $anchoSlabMin $lc $cc); imprime "$anchoSlabMin $salida" "$archSal.$lc.dat"
    salida=$(calculaK $anchoSlabMax $lc $cc); imprime "$anchoSlabMax $salida" "$archSal.$lc.dat"
    echo "iterando ..."
    dichotomic_search $anchoSlabMin $anchoSlabMax $lc $cc $tol "$archSal.$lc.dat"
    salida=`tail -n 1 "$archSal.$lc.dat"`; echo "$lc,$salida" >> "$archSal.dat"
done
echo "Terminado"
