// Slab unidimensional de ancho a
a = AnchoSlab;                // Ancho de Slab
lc = LongitudCaracteristica;  // Longitud caracteristica del elemento

// Definimos dos puntos, uno a x=0 y otro a x=a
// Ambos con la misma longitud caracteristica
Point(1) = {0,   0, 0, lc};
Point(2) = {a,   0, 0, lc};

// Definimos una linea que uno ambos puntos
Line(1) = {1, 2};

// Definimos tres entidades fisicas con nombre,
// los dos puntos los llamamos left y right para
// para hacer referencia a ellos al especificas
// las condiciones de borde
Physical Point("left") = {1};
Physical Point("right") = {2};

// A la linea la llamamos fuel para asociarla
// al material en el input
Physical Line("nucleo") = {1};
