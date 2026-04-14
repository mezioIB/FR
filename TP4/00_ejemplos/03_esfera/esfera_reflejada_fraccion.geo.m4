// Creamos una fracción de esfera

// Los datos de entrada son:
r = DatoRadio;                     // Radio de la esfera
b = DatoEspesorReflector;          // Espesor del reflector
fracEsf1 = DatoFraccion;           //Fracción de la esfera en un ángulo
fracEsf2 = 4;                      //Fracción de la esfera en la otra dirección angular
lcB = DatoLongitudCaracteristicaB; // Longitud caracteristica del elemento cerca del borde
lcI = DatoLongitudCaracteristicaI; // Longitud caracteristica del elemento cerca de la interface
lcC = DatoLongitudCaracteristicaC; // Longitud caracteristica del elemento cerca del centro

// Centro de coordenadas
Point(1) = {0,  0, 0, lcC};
// Intersecciones entre la superficie de la esfera y el eje x
Point(2) = {r,  0, 0, lcI};
// Y creamos los otros dos vértices del sector esférico
Point(3) = {Cos(2*Pi/fracEsf2)*r, Sin(2*Pi/fracEsf2)*r, 0, lcI};
Point(4) = {Cos(2*Pi/fracEsf1)*r, 0, Sin(2*Pi/fracEsf1)*r, lcI};
// Idem para la segunda cáscara:
// Intersecciones entre la superficie de la esfera y el eje x
Point(5) = {r+b,  0, 0, lcB};
// Y creamos los otros dos vértices del sector esférico
Point(6) = {Cos(2*Pi/fracEsf2)*(r+b), Sin(2*Pi/fracEsf2)*(r+b), 0, lcB};
Point(7) = {Cos(2*Pi/fracEsf1)*(r+b), 0, Sin(2*Pi/fracEsf1)*(r+b), lcB};


// Líneas que representan las tres aristas rectas
Line(1) = {1,2};
Line(2) = {1,3};
Line(3) = {1,4};
// Arcos que representas las tres aristas curvas
Circle(4) = {2, 1, 3};
Circle(5) = {2, 1, 4};
Circle(6) = {3, 1, 4};
// Idem para la segunda cáscara:
// Líneas que representan las tres aristas rectas
Line(7) = {2,5};
Line(8) = {3,6};
Line(9) = {4,7};
// Arcos que representas las tres aristas curvas
Circle(10) = {5, 1, 6};
Circle(11) = {5, 1, 7};
Circle(12) = {6, 1, 7};


// Las tres caras planas
Line Loop(13) = {5, -3, 1};
Plane Surface(14) = {13};
Line Loop(15) = {-4, -1, 2};
Plane Surface(16) = {15};
Line Loop(17) = {-6, -2, 3};
Plane Surface(18) = {17};
// Idem para la segunda cáscara// Las tres caras planas
Line Loop(19) = {7, 11, -9, -5};
Plane Surface(20) = {19};
Line Loop(21) = {-10, -7, 4, 8};
Plane Surface(22) = {21};
Line Loop(23) = {-12, -8, 6, 9};
Plane Surface(24) = {23};



// Creamos las caras curvas. 
// Esta solución sólo sirve para angulos rectos, o sea, solo se puede dividir por 2 o 4
Cascara[] = Extrude { {0, -1, 0}, {0, 0, 0}, 2*Pi/fracEsf1 } { Line{4}; };
//Printf("top curve = %g", Cascara[0]);
//Printf("surface = %g", Cascara[1]);
//Printf("side curves = %g and %g", Cascara[2], Cascara[3]);
Cascara2[] = Extrude { {0, -1, 0}, {0, 0, 0}, 2*Pi/fracEsf1 } { Line{10}; };

// Ahora rellenamos la cáscara con un volumen
Surface Loop(40) = {14,16,18,Cascara[1]};
Volume(41) = {40};
// Y rellenamos la otra cáscara con otro volumen
Surface Loop(42) = {20,22,24,-Cascara[1],Cascara2[1]};
Volume(43) = {42};

// Definimos las entidades fisicas con nombre, para poder ser llamadas
Physical Volume("nucleo") = {41};
Physical Volume("reflector") = {43};
// Y nombramos los bordes
Physical Surface("exterior") = Cascara2[1];
Physical Surface("lados") = {14,16,18,20,22,24};
