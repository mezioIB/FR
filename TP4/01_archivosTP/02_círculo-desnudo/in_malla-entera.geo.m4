// Creamos un círculo entero

// Los datos de entrada son:
r = DatoRadio;                           // Radio del círculo
lcC = DatoLongitudCaracteristicaCentro;  // Longitud caracteristica del elemento cerca del centro
lcB = DatoLongitudCaracteristicaBorde;   // Longitud caracteristica del elemento cerca del borde

// Para crear un círculo, se podría usar el comando Disk, pero para dar mayor compatibilidad
// lo crearemos a partir de dos arcos.
// Primero se crean los tres puntos para el arco, uno en x=0, otro en x=r, y otro en x=-r
Point(1) = {0,  0, 0, lcC};
Point(2) = {r,  0, 0, lcB};
Point(3) = {-r, 0, 0, lcB};

// Creamos los dos sectores circulares en base a los puntos dados
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 2};

// Creamos una curva cerrada, para poder crear una superficie
Line Loop(3) = {1, 2};
// Creamos la superficie formado por el sector circular
Plane Surface(4) = {3};

// Definimos las entidades fisicas con nombre,
// A la superficie la llamamos nucleo para asociarla al material en el input
Physical Surface("nucleo") = {4};
// Y a la circunferencia cerrada la llamamos exterior
Physical Line("exterior") = {1,2};

