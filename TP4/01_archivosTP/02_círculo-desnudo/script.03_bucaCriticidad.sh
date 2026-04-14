#!/bin/bash

# Los argumentos de entrada son:
#  1: el radio mínimo del cilindro [cm]
#  2: el radio máximo del cilindro [cm]
#  3: umbral aceptable de reactividad [pcm]
#  4: Condición de contorno. Pueden ser  vacuum|null

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
radioMin=${1:-20}
radioMax=${2:-60}
tol=${3:-100}
cc=${4:-null}
archSal="out.iteraciones"

#----------------------------------------------------------------------------------------------------
# función que genera la malla y calcula el K_eff
#----------------------------------------------------------------------------------------------------
function calculaK(){
    # Renombramos las variables de entrada
    radio=$1; divisiones=$2; lcC=$3; lcR=$4; cc=$5

    # Generación de la malla con el programa gmesh
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
    rm out_malla.geo > /dev/null

    # Resolución del problema con FeenoX:
    feenox in_reactor.fee $cc 1
    rm out_malla.msh > /dev/null
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
    divisiones=$3; lcC=$4; lcR=$5; cc=$6; tol=$7; archSalida=$8

    target=0  # valor objetivo para la reactividad
    error=1000 # valor inicial de reactividad en valor absoluto

    while (( $(bc -l<<<"$error>$tol") )); do
        # Calcula el promedio entre min y max, redondeando a 4 decimales
        mean=$(bc <<< "scale=4; ($min+$max)/2")

        salida=$(calculaK $mean $divisiones $lcC $lcR $cc)
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
encabezado="radio núcleo [cm],rho [pcm],factor de pico,tiempo de cáculo [s],memoria máxima usada [Gigabytes]"

if false; then
    echo "#lc [cm],$encabezado" > "$archSal.div_lcR.dat"
    divisiones=24; lcR=0.5;
    for lcC in 10 1 0.5 0.1 0.01
    do
        echo "#$encabezado" > "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "cálculo inicial para longitud característica de $lcC cm cerca del centro..."
        salida=$(calculaK $radioMin $divisiones $lcC $lcR $cc); imprime "$radioMin $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=$(calculaK $radioMax $divisiones $lcC $lcR $cc); imprime "$radioMax $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "iterando ..."
        dichotomic_search $radioMin $radioMax $divisiones $lcC $lcR $cc $tol "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=`tail -n 1 "$archSal.${divisiones}_${lcC}_${lcR}.dat"`; echo "$lcC,$salida" >> "$archSal.div_lcR.dat"
    done
fi

if false; then
    echo "#lc [cm],$encabezado" > "$archSal.div_lcC.dat"
    divisiones=24; lcC=0.5;
    for lcR in 10 1 0.5 0.1 0.01
    do
        echo "#$encabezado" > "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "cálculo inicial para longitud característica de $lcR cm cerca de la periferia..."
        salida=$(calculaK $radioMin $divisiones $lcC $lcR $cc); imprime "$radioMin $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=$(calculaK $radioMax $divisiones $lcC $lcR $cc); imprime "$radioMax $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "iterando ..."
        dichotomic_search $radioMin $radioMax $divisiones $lcC $lcR $cc $tol "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=`tail -n 1 "$archSal.${divisiones}_${lcC}_${lcR}.dat"`; echo "$lcR,$salida" >> "$archSal.div_lcC.dat"
    done
fi

if false; then
    echo "#divisiones,$encabezado" > "$archSal.lcR_lcC.dat"
    lcC=0.5; lcR=0.5;
    for divisiones in 1 2 3 4 6 8 12 15 16 24 32 64 128 256
    do
        echo "#$encabezado" > "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "cálculo inicial para $divisiones división del círculo ..."
        salida=$(calculaK $radioMin $divisiones $lcC $lcR $cc); imprime "$radioMin $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=$(calculaK $radioMax $divisiones $lcC $lcR $cc); imprime "$radioMax $salida" "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        echo "iterando ..."
        dichotomic_search $radioMin $radioMax $divisiones $lcC $lcR $cc $tol "$archSal.${divisiones}_${lcC}_${lcR}.dat"
        salida=`tail -n 1 "$archSal.${divisiones}_${lcC}_${lcR}.dat"`; echo "$divisiones,$salida" >> "$archSal.lcR_lcC.dat"
    done
fi

echo "Terminado"
