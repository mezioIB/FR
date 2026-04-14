// Slab unidimensional de ancho a=100
a = 100; // Ancho de Slab
lc = 2;  // Longitud caracteristica del elemento

// Definimos dos puntos, uno a x=0 y otro a x=a
// Ambos con la misma longitud caracteristica
Point(1) = {0,   0, 0, lc};
Point(2) = {a,   0, 0, lc};

// Definimos una linea que uno ambos puntos
Line(1) = {1, 2};

// Definimos tres entidades fisicas con nombre,
// los dos puntos los llamamos left y right para
// para hacer referencia a ellos al especificar
// las condiciones de borde
Physical Point("left") = {1};
Physical Point("right") = {2};

// A la linea la llamamos fuel para asociarla
// al material en el input de FeenoX
Physical Line("fuel") = {1};
