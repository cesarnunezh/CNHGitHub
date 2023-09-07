/*==============================================================================
 Nombre del código:			PEA ocupada 
 Autor:		 				César Núñez
 Objetivo:					Limpiar la ENAHO y estimar variables PEA Ocupada
 Bases a usar:				Encuesta Nacional de Hogares (ENAHO) - 2021
 
 Estructura:
	
	1. Direcciones
	2. Limpieza de base
	3. Tabulaciones
==============================================================================*/

*	1. Direcciones
{
	clear all
	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"
/*	clear all
	global bd "D:\1. Documentos\0. Bases de datos\2. ENAHO\1. Data"
	global temp "D:\1. Documentos\0. Bases de datos\2. ENAHO\2. Temp"
	global output "D:\1. Documentos\0. Bases de datos\2. ENAHO\3. Output"
*/
}

*	2. Limpieza de base
{
	use "$bd\enaho01a-2007-500.dta", clear
	gen año=2007

	foreach x of numlist 2008/2020 {
	append using "$bd\enaho01a-`x'-500.dta", force
	replace año= `x' if año==.
	}

	save "$temp\empleo_2007_2020.dta", replace

	use "$temp\empleo_2007_2020.dta", clear

*Generamos la variable departamento
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)

	replace dpto=26 if dpto==15 & dominio!=8

	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"

	label values dpto dpto

*Generamos la variable filtro de residencia
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

*Generamos la variable filtro de residencia
	recode p208a (14/29=1) (30/64=2) (nonmissing=3), gen(grupo_edad)
	label define grupo_edad 1 "Jóvenes (14 a 29 años)" 2 "Adultos (30 a 64 años)" 3 "Adultos mayores (65 a más)"
	label values grupo_edad grupo_edad
	
*Generamos la variable rural
	gen rural=1 if estrato==7 | estrato==8 //rural
	replace rural=0 if rural==. //urbano

	label values rural label_rural
	label define label_rural 1 "rural" 0 "urbano"
}

*	3. Tabulaciones
{	
	*PET 
	gen pet=(p208a>=14)
	table año if filtro==1 & ocu500!=0  [iw=fac500a] , c(sum pet) format(%12.0fc) col
	table año grupo_edad if filtro==1 & ocu500!=0  [iw=fac500a] , c(sum pet) format(%12.0fc) col

	*PEA y PEA Ocupada 
	gen pea=(ocu500==1 | ocu500==2)
	gen peao=(ocu500==1)
	
	table año grupo_edad if filtro==1 [iw=fac500a] , c(sum pea sum peao) format(%12.0fc) col
	table grupo_edad rural if filtro==1 & año==2019 [iw=fac500a] , c(sum pea sum peao) format(%12.0fc) col
	
	table p301a if filtro==1 & año==2019 & grupo_edad==1 [iw=fac500a] , c(sum pea) format(%12.0fc) col
			
	*Desempleo por grupo de edad
	gen desempleo=(ocu500==2)
	table año grupo_edad if filtro==1 [iw=fac500a] , c(sum desempleo sum pea) format(%12.0fc) col
	table grupo_edad p207 if filtro==1 & año==2019 [iw=fac500a] , c(sum desempleo sum pea) format(%12.0fc) col
	
	*Empleo informal
	gen informal=(ocupinf==1)
	table año if filtro==1 & grupo_edad==1 [iw=fac500a] , c(sum informal sum peao) format(%12.0fc) col
	table año p207 if filtro==1 & grupo_edad==1 [iw=fac500a] , c(sum informal sum peao) format(%12.0fc) col
	table p301a if filtro==1 & grupo_edad==1 & año==2019 [iw=fac500a] , c(sum informal sum peao) format(%12.0fc) col
	
	table año ocu500 if filtro==1 & ocu500!=0 [iw=fac500a] , format(%12.0fc) col

	collapse (sum) ocu500 pea peao if filtro==1 [iw=fac500a] , by(a_o dpto)

	tab dpto ocu500 if filtro==1 & a_o=="2007" [iw=fac500a]

	*tab p301a if ocu500==1 & filtro==1 & dpto==8 [iw=fac500]

	*Empleo por sector

	gen r5=(p506r4/100)
	recode r5 (1/2.9 = 1) (3/3.22 = 2) (5/9.9 = 3) (10/33.2 = 4) (35/39 = 5) (41/43.9 = 6) (45/47.99 = 7)  (49/53.2 = 8)  (55/56.3 = 9) (64/66.3 = 10) (68/68.2 77/82.99 = 11) (84/84.3 = 12) (85/85.5= 13) (86/88.9= 14) (90/99.0= 15) (58/63.99 = 16)(69/75.0=17), gen(r51)
	label define r51 1 "Agricultura, ganadería, silvicultura" 2 "Pesca" 3 "Explotación de minas y canteras" 4 "Industrias manufactureras" 5 "Suministro de electricidad, agua y gas"  6 "Construcción" 7 "Comercio" 8 "Transporte y almacenamiento" 9 "Actividades de alojamiento y de comida" 10 "Servicios financieros"  11 "Actividades inmobiliarias, empresariales y alquiler" 12 "Defensa" 13 "Enseñanza" 14 "Servicios sociales y de salud" 15 "Otros servicios" 16 "Información y comunicaciones" 17 "Actividades profesionales, cientificas y tecnicas"
	label values r51 r51

	replace fac500a=fac500a7 if año==2011

	table dpto año if filtro==1 & r51==1 [iw=fac500a], c(sum peao) format(%12.0fc) col
	table año if filtro==1  [iw=fac500a] , c(sum peao) format(%12.0fc) col	
	
	

*Cálculo de ingresos
	recode i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t (.=0)
	egen ing_mensual= rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
	replace ing_mensual=ing_mensual/12

	gen horas_mensuales=i513t*4
	
	*TamaÃ±o de empresa
	gen tama=1 if (p512b <= 10) // menor a 10 trabajadores.
	replace tama=2 if (p512b > 10 & p512b <= 100)
	replace tama=3 if (p512b > 100 & p512b <= 250)
	replace tama=4 if (p512b > 250)
	replace tama=. if p512b==.

	label values tama tama
	label define tama 1 "Microempresa" 2 "Pequeña empresa" 3 "Mediana empresa" 4 "Gran empresa"
	
	
	*
	table año tama if filtro==1 & r51==3 [iw=fac500a] , c(sum peao) format(%12.0fc) col
	table año tama if filtro==1 & r51==3 & (ing_mensual>0 & ing_mensual<=30000) [iw=fac500a] , c(mean ing_mensual) format(%12.0fc) col
	table año tama if filtro==1 & r51==3 & (tama==3 | tama==4) & (ing_mensual>0 & ing_mensual<=30000) [iw=fac500a] , c(mean ing_mensual) format(%12.0fc) col

	table año  [iw=fac500a]  if filtro==1 & (ing_mensual>0 & ing_mensual<=30000) , c(mean ing_mensual) format(%12.0fc) col
}