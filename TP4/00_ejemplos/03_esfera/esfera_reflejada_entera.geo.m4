// Creamos una esfera entera

// Los datos de entrada son:
r = DatoRadio;                     // Radio de la esfera
b = DatoEspesorReflector;          // Espesor del reflector
lcB = DatoLongitudCaracteristicaB; // Longitud caracteristica del elemento cerca del borde
lcI = DatoLongitudCaracteristicaI; // Longitud caracteristica del elemento cerca de la interface
lcC = DatoLongitudCaracteristicaC; // Longitud caracteristica del elemento cerca del centro

// Centro de coordenadas
Point(1) = {0,  0, 0, lcC};
// Intersecciones entre la superficie de la esfera y los ejes x e y
Point(2) = {r,  0, 0, lcI};
Point(3) = {0,  r, 0, lcI};
Point(4) = {-r, 0, 0, lcI};
Point(5) = {0, -r, 0, lcI};
// Idem para la segunda cáscara:
Point(6) = { r+b, 0, 0, lcB};
Point(7) = {0,  r+b, 0, lcB};
Point(8) = {-r-b, 0, 0, lcB};
Point(9) = {0, -r-b, 0, lcB};

// Arcos que representas las Intersecciones entre la superficie de la esfera y el plano xy
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 4};
Circle(3) = {4, 1, 5};
Circle(4) = {5, 1, 2};
// Idem para la segunda cáscara:
Circle(5) = {6, 1, 7};
Circle(6) = {7, 1, 8};
Circle(7) = {8, 1, 9};
Circle(8) = {9, 1, 6};

// Creamos las cascaras
// Primero la interna
CascaraIntA1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{1}; };
CascaraIntA2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{1}; };
CascaraIntB1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{2}; };
CascaraIntB2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{2}; };
CascaraIntC1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{3}; };
CascaraIntC2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{3}; };
CascaraIntD1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{4}; };
CascaraIntD2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{4}; };
// Luego la externa
CascaraExtA1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{5}; };
CascaraExtA2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{5}; };
CascaraExtB1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{6}; };
CascaraExtB2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{6}; };
CascaraExtC1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{7}; };
CascaraExtC2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{7}; };
CascaraExtD1[] = Extrude { {0, -1, 0}, {0, 0, 0}, Pi/2 } { Line{8}; };
CascaraExtD2[] = Extrude { {0,  1, 0}, {0, 0, 0}, Pi/2 } { Line{8}; };


// Ahora rellenamos la cáscara con un volumen
Surface Loop(100) = { -CascaraIntA1[1], CascaraIntA2[1], -CascaraIntB1[1], CascaraIntB2[1], -CascaraIntC1[1], CascaraIntC2[1], -CascaraIntD1[1], CascaraIntD2[1] };
Volume(101) = {100};
Physical Volume("nucleo") = {101};

Surface Loop(200) = { -CascaraExtA1[1], CascaraExtA2[1], -CascaraExtB1[1], CascaraExtB2[1], -CascaraExtC1[1], CascaraExtC2[1], -CascaraExtD1[1], CascaraExtD2[1] };
Volume(201) = {200,-100};
Physical Volume("reflector") = {201};

Physical Surface("exterior") = { -CascaraExtA1[1], CascaraExtA2[1], -CascaraExtB1[1], CascaraExtB2[1], -CascaraExtC1[1], CascaraExtC2[1], -CascaraExtD1[1], CascaraExtD2[1] };


