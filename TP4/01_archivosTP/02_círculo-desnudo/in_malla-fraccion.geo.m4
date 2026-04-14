// Creamos un sector circular

// Los datos de entrada son:
r = DatoRadio;                          // Radio del círculo
fracCirc=DatoFraccion;                  // Fracción del círculo a resolver
lcC = DatoLongitudCaracteristicaCentro; // Longitud caracteristica del elemento cerca del centro
lcB = DatoLongitudCaracteristicaBorde;  // Longitud caracteristica del elemento cerca del borde

// Definimos dos puntos, uno a x=0, otro a x=r
// y otro en un punto a 360/fracCirc grados sobre la circunferencia
// Todos con la misma longitud característica
Point(1) = {0, 0, 0, lcC};
Point(2) = {r, 0, 0, lcB};
Point(3) = {Cos(2*Pi/fracCirc)*r, Sin(2*Pi/fracCirc)*r, 0, lcB};

// Creamos un sector circular en base a los puntos dados
Circle(1) = {2, 1, 3};
// Cerramos el sector circular
Line(2) = {3, 1};
Line(3) = {1, 2};

// Creamos una curva cerrada, para poder crear una superficie
Line Loop(4) = {1, 2, 3};
// Creamos la superficie formado por el sector circular
Plane Surface(5) = {4};

// Definimos las entidades fisicas con nombre,
// A la superficie la llamamos nucleo para asociarla al material en el input
Physical Surface("nucleo") = {5};
// Y nombramos los bordes
Physical Line("exterior") = {1};
Physical Line("lado1") = {2};
Physical Line("lado2") = {3};
