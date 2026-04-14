// Slab unidimensional a tres zonas
a = 45; // Ancho de combustible
b = 40;  // Ancho de reflector izquierdo
c = 170;  // Ancho de reflector derecho
lc = 0.1; // Longitud caracteristica del elemento

// Definimos cuatro puntos, uno a x=-b, x=0, x=a y x=a+c
// Todos con la misma longitud caracteristica
Point(1) = { -b, 0, 0, lc};
Point(2) = {  0, 0, 0, lc};
Point(3) = {  a, 0, 0, lc};
Point(4) = {a+c, 0, 0, lc};

// Definimos tres linea que unen los puntos
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};

// Definimos cinco entidades fisicas con nombre,
// los dos puntos los llamamos left y right para
// para hacer referencia a ellos al especificas
// las condiciones de borde
Physical Point("left") = {1};
Physical Point("right") = {4};

// A las lineas las llamamos fuel, left_refl y right_refl
// para asociarlas al material en el input
Physical Line("left_refl") = {1};
Physical Line("fuel") = {2};
Physical Line("right_refl") = {3};
