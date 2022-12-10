/*******************************************************************************
Proyecto: UNICEF - SITAN Niñas, niños y adolescentes
Objetivo: Cálculo de indicadores del Capítulo 1
Autores:  DR CN

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

global base1 "/Users/deliaruiz/Downloads/ENDES"
global out1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\2. Output Stata"
global temp "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENDES\Temp"


* 1. Merge de bases

use 		"$base1/rec91_2019.dta", clear

merge 		1:1 caseid using "$base1/rec0111_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		1:m caseid using "$base1/rec21_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge
rename 		bord hidx

merge 		1:1 caseid hidx using "$base1/rec43_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge
rename 		hidx idx95

merge 		1:1 caseid idx95 using "$base1/rec95_2019.dta"
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

*Edad del niño en meses
gen edadhijo = v008-b3 //es lo mismo que bedad


*******************************************************************************/
*	3. Variables vacunas

label 	define vacuna  1 "Sí" 0 "No"
foreach v of varlist 	h2 s45pv1 s45pv2 s45pv3 h4 h6 h8 h9 ///
						s45sp1 s45sp2 s45d4 s45p4 s45nm1 ///
						s45nm2 s45nm3 s45rt1 s45rt2 {
recode `v' (1/3 =1) (8=0)
label values `v' vacuna
}

/*
	*	Esquema anterior
gen vacutot1= 0
replace vacutot1=1 if (bedad<2 & h2==1)
replace vacutot1=1 if (bedad<4 & h2==1 & s45pv1==1 & h4==1)
replace vacutot1=1 if (bedad<6 & h2==1 & s45pv1==1 ///
						& s45pv2==1 & h4==1 & h6==1)
replace vacutot1=1 if (bedad<12 & h2==1 & s45pv1==1 & s45pv2==1 ///
						& s45pv3==1 & h4==1 & h6==1 & h8==1)
replace vacutot1=1 if (bedad<=36 & h2==1 & s45pv1==1 & s45pv2==1 ///
						& s45pv3==1 & h4==1 & h6==1 & h8==1 & h9==1)

	*	Esquema nuevo					
gen vacutot2=0
replace vacutot2=1 if (bedad<2 & h2==1)
replace vacutot2=1 if (bedad<4 & h2==1 & s45pv1==1 & h4==1 & ///
						s45rt1==1 & s45nm1==1)
replace vacutot2=1 if (bedad<6 & h2==1 & s45pv1==1 & s45pv2==1 & ///
						h4==1 & h6 & s45rt1==1 & s45rt2==1 & ///
						s45nm1==1 & s45nm2==1)
replace vacutot2=1 if (bedad<12 & h2==1 & s45pv1==1 & s45pv2==1 & s45pv3==1 & ///
						h4==1 & h6==1 & h8==1 & s45rt1==1 & s45rt2==1 & s45nm1==1 ///
						& s45nm2==1)
*s45sp1 está vacío
replace vacutot2=1 if (bedad<18 & h2==1 & s45pv1==1 & s45pv2==1 & s45pv3==1 & ///
						h4==1 & h6==1 & h8==1 & h9==1 & s45rt1==1 & s45rt2==1 & s45nm1==1 ///
						& s45nm2==1 & s45nm3==1)
replace vacutot2=1 if (bedad<=36 & h2==1 & s45pv1==1 & s45pv2==1 & s45pv3==1 & ///
						h4==1 & h6==1 & h8==1 & h9==1 & s45rt1==1 & s45rt2==1 & s45nm1==1 ///
						& s45nm2==1 & s45nm3==1 & s45sp2==1 & s45d4==1 & s45p4==1)						
*/


egen pentavalente= rowtotal(s45pv1 s45pv2 s45pv3)
egen antipolio= rowtotal(h4 h6 h8)
egen spr= rowtotal(s45sp1 s45sp2)
egen neumococo= rowtotal(s45nm1 s45nm2 s45nm3)
egen rotavirus= rowtotal(s45rt1 s45rt2)

	*	Esquema anterior
gen vacutot1= 0
replace vacutot1=1 if (bedad<2 & h2==1)
replace vacutot1=1 if (bedad<4 & h2==1 & pentavalente==1 & antipolio==1)
replace vacutot1=1 if (bedad<6 & h2==1 & pentavalente==2 & antipolio==2)
replace vacutot1=1 if (bedad<12 & h2==1 & pentavalente==3 & antipolio==3)
replace vacutot1=1 if (bedad<=36 & h2==1 & pentavalente==3 & antipolio==3 & h9==1)

	*	Esquema nuevo					
gen vacutot2= 0
replace vacutot2=1 if (bedad<2 & h2==1)
replace vacutot2=1 if (bedad<4 & h2==1 & pentavalente==1 & antipolio==1 & rotavirus==1 & neumococo==1)
replace vacutot2=1 if (bedad<6 & h2==1 & pentavalente==2 & antipolio==2 & rotavirus==2 & neumococo==2)
replace vacutot2=1 if (bedad<12 & h2==1 & pentavalente==3 & antipolio==3 & rotavirus==2 & neumococo==2)
replace vacutot2=1 if (bedad<18 & h2==1 & pentavalente==3 & antipolio==3 & ha9==1 ///
						& rotavirus==2 & neumococo==3)
*s45sp1 está vacío
replace vacutot2=1 if (bedad<=36 & h2==1 & pentavalente==3 & antipolio==3 & ha9==1 ///
						& rotavirus==2 & neumococo==3 & s45sp2==1 & s45d4==1 & s45p4==1)					


*	4. Tablas

*	Esquema antiguo

tab vacutot1 if bedad<36
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' vacutot1 [iw=factor] if (edadhijo<=36), row 
}	

*	Esquema nuevo
foreach v of varlist lenguamat v190 v106 sregion v025 {
tab `v' vacutot2 [iw=factor] if (edadhijo<=36), row 
}





