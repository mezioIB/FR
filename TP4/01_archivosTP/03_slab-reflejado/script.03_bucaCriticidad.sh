#!/bin/bash

# Los argumentos de entrada son:
#  1: el ancho mínimo del slab [cm]
#  2: el ancho máximo del slab [cm]
#  3: umbral aceptable de reactividad [pcm]
#  4: Condición de contorno. Pueden ser  vacuum|null

# Si no se definen estos argumentos de entrada se inicializan las variables con un valor por defecto
semiAnchoSlabMin=${1:-5}
semiAnchoSlabMax=${2:-30}
tol=${3:-100}

archSal="out.iteraciones"


#----------------------------------------------------------------------------------------------------
# función que genera la malla y calcula el K_eff
#----------------------------------------------------------------------------------------------------
function calculaK(){
    # Renombramos las variables de entrada
    semiAnchoSlab=$1; AnchoReflector=$2; lcC=$3; lcI=$4; lcB=$5

    #----------------------------------------------------------------------------------------------------
    # Generación de la malla con el programa gmesh
    #----------------------------------------------------------------------------------------------------
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
    rm out_malla.geo > /dev/null

    #----------------------------------------------------------------------------------------------------
    # Resolución del problema con FeenoX:
    #----------------------------------------------------------------------------------------------------
    feenox in_reactor.fee 1
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
    AnchoReflector=$3; lcC=$4; lcI=$5; lcB=$6; tol=$7; archSalida=$8

    target=0  # valor objetivo para la reactividad
    error=1000 # valor inicial de reactividad en valor absoluto

    while (( $(bc -l<<<"$error>$tol") )); do
        # Calcula el promedio entre min y max, redondeando a 4 decimales
        mean=$(bc <<< "scale=4; ($min+$max)/2")

        salida=$(calculaK $mean $AnchoReflector $lcC $lcI $lcB)
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
echo "#ancho reflector [cm],$encabezado" > "$archSal.dat"

lc=5
for AnchoReflector in 2 5 7 10 20 30 40 50 60
do
    echo "#$encabezado" > "$archSal.$AnchoReflector.dat"
    echo "cálculo inicial para un ancho del reflector de $AnchoReflector cm..."
    salida=$(calculaK $semiAnchoSlabMin $AnchoReflector $lc $lc $lc); imprime "$semiAnchoSlabMin $salida" "$archSal.$AnchoReflector.dat"
    salida=$(calculaK $semiAnchoSlabMax $AnchoReflector $lc $lc $lc); imprime "$semiAnchoSlabMax $salida" "$archSal.$AnchoReflector.dat"
    echo "iterando ..."
    dichotomic_search $semiAnchoSlabMin $semiAnchoSlabMax $AnchoReflector $lc $lc $lc $tol "$archSal.$AnchoReflector.dat"
    salida=`tail -n 1 "$archSal.$AnchoReflector.dat"`; echo "$AnchoReflector,$salida" >> "$archSal.dat"
done
echo "Terminado"
