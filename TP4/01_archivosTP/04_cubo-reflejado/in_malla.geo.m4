// Semi slab unidimensional reflejado
a = SemiAnchoSlab;            // Semi ancho del combustible
b = AnchoReflector;           // Espesor de reflector
lc = LongitudCaracteristica;  // Longitud caracteristica

// Definimos tres puntos, x=0, x=a y x=a+b
// Todos con la misma longitud caracteristica
Point(1)  = {  0, a, 0, lc};
Point(2)  = {  a, a, 0, lc};
Point(3)  = {  a, 0, 0, lc};
Point(4)  = {  0, 0, 0, lc};
Point(5)  = {  0, a, a, lc};
Point(6)  = {  a, a, a, lc};
Point(7)  = {  a, 0, a, lc};
Point(8)  = {  0, 0, a, lc};
Point(9)  = {a+b, a, 0, lc};
Point(10) = {a+b, 0, 0, lc};
Point(11) = {a+b, a, a, lc};
Point(12) = {a+b, 0, a, lc};

// Definimos dos linea que unen los puntos
Line(1)  = { 1, 2};
Line(2)  = { 2, 3};
Line(3)  = { 3, 4};
Line(4)  = { 4, 1};

Line(5)  = { 5, 6};
Line(6)  = { 6, 7};
Line(7)  = { 7, 8};
Line(8)  = { 8, 5};

Line(9)  = { 1, 5};
Line(10) = { 8, 4};

Line(11) = { 2, 6};
Line(12) = { 7, 3};

Line(13)  = { 2, 9};
Line(14)  = { 9,10};
Line(15)  = {10, 3};

Line(16)  = { 6,11};
Line(17)  = {11,12};
Line(18)  = {12, 7};

Line(19) = { 9,11};
Line(20) = {12,10};

Line Loop(30) = {  1,  2,  3,  4}; Plane Surface(50) = {30};
Line Loop(31) = {  5,  6,  7,  8}; Plane Surface(51) = {31};
Line Loop(32) = {  9, -8, 10,  4}; Plane Surface(52) = {32};
Line Loop(33) = { 11,  6, 12, -2}; Plane Surface(53) = {33};
Line Loop(34) = {  9,  5,-11, -1}; Plane Surface(54) = {34};
Line Loop(35) = {-10, -7, 12,  3}; Plane Surface(55) = {35};

Line Loop(36) = { 13, 14, 15, -2}; Plane Surface(56) = {36};
Line Loop(37) = { 16, 17, 18, -6}; Plane Surface(57) = {37};
Line Loop(38) = { 19, 17, 20,-14}; Plane Surface(58) = {38};
Line Loop(39) = { 11, 16,-19,-13}; Plane Surface(59) = {39};
Line Loop(40) = {-12,-18, 20, 15}; Plane Surface(60) = {40};

Surface Loop(70) = {-50,51,-52,53,-54,55};
//Surface Loop(70) = {50,-51,52,-53,54,-55};
Volume(71) = {70};
Surface Loop(72) = {-53,56,-57,58,-59,60};
//Complex
Volume(73) = {72};

// Definimos cuatro entidades fisicas con nombre,
// los dos volúmenes serán las regiones
Physical Volume("nucleo") = {71};
Physical Volume("reflector") = {73};
// Y hay dos tipos de contorno
Physical Surface("centro") = {50,52,55,56,60};
Physical Surface("bordes") = {51,54,57,58,59};
