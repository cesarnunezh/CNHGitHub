*Ocupacion
gen r5=(p506r4/100)
recode r5 (1/3.22 = 1) (3/3.22 = 2) (5/9.9 = 3) (10/33.2 = 4) (35/39 = 5) (41/43.9 = 6) (45/47.99 = 7)  (49/53.2 = 8)  (55/56.3 = 9) (64/66.3 = 10) (68/68.2 77/82.99 = 11) (84/84.3 = 12) (85/85.5= 13) (86/88.9= 14) (90/99.0= 15) (58/63.99 = 16)(69/75.0=17), gen(r51)
label define r51 1 "Agricultura, ganaderÃ­a, silvicultura" 2 "Pesca" 3 "ExplotaciÃ³n de minas y canteras" 4 "Industrias manufactureras" 5 "Suministro de electricidad, agua y gas"  6 "ConstrucciÃ³n" 7 "Comercio" 8 "Transporte y almacenamiento" 9 "Actividades de alojamiento y de comida" 10 "Servicios financieros"  11 "Actividades inmobiliarias, empresariales y alquiler" 12 "Defensa" 13 "Enseñanza" 14 "Servicios sociales y de salud" 15 "Otros servicios" 16 "Información y comunicaciones" 17 "Actividades profesionales, cientificas y tecnicas"
label values r51 r51
