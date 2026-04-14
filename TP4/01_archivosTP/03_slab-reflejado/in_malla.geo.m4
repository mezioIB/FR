// Semi slab unidimensional reflejado
a = SemiAnchoSlab;                    // Semi ancho del combustible
b = AnchoReflector;                   // Espesor de reflector
lcC = LongitudCaracteristicaCentro;   // Longitud caracteristica del elemento cerca del centro
lcI = LongitudCaracteristicaInterfaz; // Longitud caracteristica del elemento cerca de la interfaz
lcB = LongitudCaracteristicaBorde;    // Longitud caracteristica del elemento cerca del borde

// Definimos tres puntos, x=0, x=a y x=a+b
// Todos con la misma longitud caracteristica
Point(1) = {  0, 0, 0, lcC};
Point(2) = {  a, 0, 0, lcI};
Point(3) = {a+b, 0, 0, lcB};

// Definimos dos linea que unen los puntos
Line(1) = {1, 2};
Line(2) = {2, 3};

// Definimos cuatro entidades fisicas con nombre,
// los dos puntos los llamamos left y right para
// para hacer referencia a ellos al especificas
// las condiciones de borde
Physical Point("left") = {1};
Physical Point("right") = {3};

// A las lineas las llamamos nucleo y reflector
// para asociarlas al material en el input
Physical Line("nucleo") = {1};
Physical Line("reflector") = {2};
