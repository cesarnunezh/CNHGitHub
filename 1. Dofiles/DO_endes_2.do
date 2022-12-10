/*******************************************************************************
Proyecto: UNICEF - SITAN Niñas, niños y adolescentes
Objetivo: Cálculo de indicadores del Capítulo 1
Autores:  DR

Objetivo: 	Realizar el cálculo de los indicadores del contexto donde se desenvuelven
			las niñas, niños y adolescentes.

Estructura:
	0. Direcciones
    1. Merge de bases
	2. Variables para cortes
	3. Variables anticonceptivos
	4. Tablas
		

*******************************************************************************/
* 0. Direcciones

*global base1 "/Users/deliaruiz/Downloads/ENDES"
global base1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENDES"
global out1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\2. Output Stata"
global temp "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENDES\Temp"



* 1. Merge de bases

use 		"$base1/re223132_2019.dta", clear

merge 		1:1 caseid using "$base1/rec0111_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		1:1 caseid using "$base1/re516171_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		1:1 caseid using "$base1/rec91_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

gen 		factor=v005/1000000


*******************************************************************************/
*	2. variables para cortes

*Lengua materna
gen lenguamat=s119
recode lenguamat (10=1) (1/9=2) (11/12=3)
label define lenguamat 1 "Castellano" 2 "Lengua nativa" 3 "Extranjera"
label values lenguamat lenguamat

*Quintil de riqueza
label define v190 1 "Quintil inferior" 2 "Segundo quintil" ///
3 "Quintil intermedio" 4 "Cuarto quintil" 5 "Quintil superior"
label values v190 v190

*Nivel de educación
label define v106 0 "Sin educación" 1 "Primaria" 2 "Secundaria" 3 "Superior"
label values v106 v106
 
*Región natural
label define sregion  1 "Lima Metropolitana" 2 "Resto Costa" ///
3 "Sierra" 4 "Selva"
label values sregion sregion

*Área
label define v025  1 "Urbano" 2 "Rural" 
label values v025 v025

*Edades
label define v013  0 "12-14" 1 "15-19" 2 "20-24" 3 "25-29" ///
4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49"
label values v013 v013


*******************************************************************************/
*	3. Variables anticonceptivos

gen unidas=.
replace unidas=1 if v501==1 | v501==2
replace unidas=2 if v501==0 | v501==3 | v501==4 | v501==5
label define unidas 1 "Sí" 2 "No"
label values unidas unidas   // unida=tiene pareja

gen usa_metodo=.
replace usa_metodo=2 if v313==2 | v313==1
replace usa_metodo=1 if v313==3
replace usa_metodo=3 if v313==0
label define usa_metodo  1 "Moderno" 2 "Tradicional folklorico" 3 "No usa"
label values usa_metodo usa_metodo  // método de anticonceptivos usado

gen usa_metodo2=.
replace usa_metodo2=1 if usa_metodo==1 | usa_metodo==2
replace usa_metodo2=2 if usa_metodo==3
label define usa_metodo2  1 "Sí" 2 "No"
label values usa_metodo2 usa_metodo2  // si usa o no anticonceptivos

*******************************************************************************/

*	4. Tablas 

svyset v001 [iw=factor],strata(v022)  singleunit(centered)

* Uso actual de métodos anticonceptivos en mujeres actualmente unidas (15-49)
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' usa_metodo [iw=factor]  if v013!=0 & unidas==1  , row  
}

* Uso actual de métodos anticonceptivos en mujeres actualmente unidas (12-19)
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' usa_metodo [iw=factor] if (v013==0 | v013==1) & unidas==1, row  
}

*_________________________________________________________

*Uso de métodos anticonceptivos, mujeres (15-49)
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' usa_metodo2 [iw=factor]  if v013!=0 & unidas==1, row  
}

*Uso de métodos anticonceptivos, mujeres (12-19)
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' usa_metodo2 [iw=factor]  if (v013==0 | v013==1) & unidas==1, row  
}










