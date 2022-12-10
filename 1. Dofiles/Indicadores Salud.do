/*******************************************************************************
Proyecto: UNICEF - SITAN Niñas, niños y adolescentes
Objetivo: Cálculo de indicadores del Capítulo 1
Autores:  DR - CN

Objetivo: 	Realizar el cálculo de los indicadores del contexto donde se desenvuelven
			las niñas, niños y adolescentes.

Estructura:
	0. Direcciones
    1. Merge de bases
	2. Desnutrición Crónica
	3. Anemia
	4. Mortalidad neonatal e infantil
	5. Salud sexual y reproductiva
		
*******************************************************************************/
* 0. Direcciones

global base1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENDES"
global out1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\2. Output Stata"
global temp "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENDES\Temp"

*******************************************************************************/
* 1. Merge de bases 
{
* Merge para el cálculo de desnutrición y anemia
use 		"$base1\rech6_2019.dta", clear
rename  	hc0 hvidx
merge 		1:1 hhid hvidx using "$base1\rech1_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		m:1 hhid  using "$base1\rech23_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		1:1 hhid hvidx using "$base1\rech1_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

merge 		m:1 hhid  using "$base1\rech0_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge
rename 		hvidx  idxh4

merge 		1:1 hhid  idxh4 using  "$base1\rech4_2019.dta"
tab 		_merge
keep 		if _merge==3
drop 		_merge

preserve
use "$base1\rec91_2019.dta", clear
gen hc60=substr(caseid,-2,.)
destring hc60, replace
gen hhid=substr(caseid,1,15)
tempfile rec91
save `rec91'
restore

merge 		m:1 hhid hc60 using  `rec91', keepusing(s119)
tab 		_merge
keep 		if _merge!=2
drop 		_merge

rename hc60 v003
merge 		m:1 hhid v003 using  "$base1\rec0111_2019.dta", keepusing(v131 v190 v106 v025 v013 v008)
tab 		_merge
keep 		if _merge!=2
drop 		_merge

gen 		factor=hv005/1000000

gen filtro=(hv102==1)
gen filtro2=(hv103==1)

save "$temp\desn_anemia.dta", replace

* Merge para el cálculo de vacunas

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

save "$temp\vacunas.dta", replace

* Merge para el cálculo de indicadores de salud sexual y reproductiva

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

save "$temp\salud_sexual.dta", replace

}
*******************************************************************************/
*2. Desnutrición Crónica
{
use "$temp\desn_anemia.dta", clear

*2.1. Creando las variables para cortes

	*Lengua materna
	recode s119 (10=1) (1/9=2) (11/12=3), gen(lenguamat)
	label define lenguamat 1 "Castellano" 2 "Lengua nativa" 3 "Extranjera"
	label values lenguamat lenguamat
	
	recode v131 (1/9 =2) (10=1) (11/12=3), gen(lengua_materna)
	label define lengua_materna 1 "Castellano" 2 "Lengua nativa u originaria" 3 "Lengua extranjera"
	label val lengua_materna lengua_materna

	*Quintil de riqueza
	label define v190 1 "Quintil inferior" 2 "Segundo quintil" ///
	3 "Quintil intermedio" 4 "Cuarto quintil" 5 "Quintil superior"
	label values v190 v190

	*Nivel de educación
	label define v106 0 "Sin educación" 1 "Primaria" 2 "Secundaria" 3 "Superior"
	label values v106 v106
	 
	*Área
	label define hv025  1 "Urbano" 2 "Rural" 
	label values hv025 hv025

	*Edades
	label define v013  0 "12-14" 1 "15-19" 2 "20-24" 3 "25-29" ///
	4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49"
	label values v013 v013

*2.2. Generamos la variable de desnutrición

	gen 		desn_OMS=1 if filtro==1 & hc70<-200 
	replace 	desn_OMS=0 if filtro==1 & hc70>=-200 & hc70<601
	replace 	desn_OMS = . if filtro == 0 
	replace 	desn_OMS = . if hc70>= 9996 & hc70<=9999
	lab var 	desn_OMS "Porcentaje de menores de 5 años con desnutrición crónica"

	gen 		desnSEVERA_OMS=1 if hv103==1 & hc70<-300
	replace 	desnSEVERA_OMS=0 if hv103==1 & hc70>=-300 & hc70<601
	replace 	desnSEVERA_OMS = . if hv103 == 0 
	replace 	desnSEVERA_OMS = . if hc70>= 9996 & hc70<=9999

	lab var 	desnSEVERA_OMS "Porcentaje de menores de 5 años con desnutrición crónica"

	gen 		edad0a35=hc1<36
	gen 		edad0a59=hc1<60


	gen 		deswho=desn_OMS if edad0a59==1
	g 			amazonia=hv024==1|hv024==16|hv024==17|hv024==22|hv024==25
		
	svyset hv001 [pw=factor],strata(hv022)  singleunit(centered)

*2.3. Tabulamos 	desnutricion

	foreach v of varlist lenguamat lengua_materna v190 v106 shregion hv025 hc27 {
	tab `v' deswho [iw=factor] if (hc1>=0 & hc1<=59 & hv103==1), row 
	}
}
*******************************************************************************/
*3. Anemia
{
use "$temp\desn_anemia.dta", clear

*3.1. Creando las variables para cortes

	*Lengua materna
	recode s119 (10=1) (1/9=2) (11/12=3), gen(lenguamat)
	label define lenguamat 1 "Castellano" 2 "Lengua nativa" 3 "Extranjera"
	label values lenguamat lenguamat
	
	recode v131 (1/9 =2) (10=1) (11/12=3), gen(lengua_materna)
	label define lengua_materna 1 "Castellano" 2 "Lengua nativa u originaria" 3 "Lengua extranjera"
	label val lengua_materna lengua_materna

	*Quintil de riqueza
	label define v190 1 "Quintil inferior" 2 "Segundo quintil" ///
	3 "Quintil intermedio" 4 "Cuarto quintil" 5 "Quintil superior"
	label values v190 v190

	*Nivel de educación
	label define v106 0 "Sin educación" 1 "Primaria" 2 "Secundaria" 3 "Superior"
	label values v106 v106
	 
	*Área
	label define hv025  1 "Urbano" 2 "Rural" 
	label values hv025 hv025

	*Edades
	label define v013  0 "12-14" 1 "15-19" 2 "20-24" 3 "25-29" ///
	4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49"
	label values v013 v013
	
*3.2. Generamos la variable de anemia

	gen 		ed6_35mes=1 if hc1>5 & hc1<36
	gen 		ed6_59mes=1 if hc1>5 & hc1<60
	gen 		ed6_24mes=1 if hc1>5 & hc1<25

	recode 		hc1 (0/5=1) (6/17=2) (18/23=3) (24/35=4) (36/47=5) (48/59=6) ,gen(gr1_edad)
	la 			def gr1_edad 1 "0-5" 2 "6-17" 3 "18-23" 4 "24-35" 5 "36-47" 6 "48-59"
	la 			val gr1_edad gr1_edad

	recode 		hc1 (0/5=1) (6/11=2)(12/23=3) (24/35=4) (36/47=5) (48/59=6) ,gen(gr3_edad)
	la 			def gr3_edad 1 "0-5" 2 "6-11" 3 "12-23" 4 "24-35" 5 "36-47" 6 "48-59"
	la 			val gr3_edad gr3_edad

	g 			alt=(hv040/1000)*3.3
	g 			haj= hc53/10 -(-0.032*alt+0.022*alt*alt) 
	 
	g 			anemia=1 if (haj>1 & haj<11 ) & hv103==1
	replace 	anemia=0 if (haj>=11 & haj<30 ) & hv103==1

	la 			def anemia 1 "anemia" 0 "sin_anemia"
	la 			val anemia anemia
		
	g 			anemia635=anemia if ed6_35mes==1
	g 			anemia659=anemia if ed6_59mes==1
	g 			anemia624=anemia if ed6_24mes==1
	
	
*3.3. Tabulamos anemia

	foreach v of varlist lenguamat lengua_materna v190 v106 shregion hv025 hc27 {
	tab `v' anemia [iw=factor] if (ed6_35mes==1 & hv103==1), row 
	}
	
}
*******************************************************************************/
*4. Vacunación
{

use 		"$temp\vacunas.dta", clear

*4.1. Creando las variables para cortes

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


*4.2. Variables vacunas

	label 	define vacuna  1 "Sí" 0 "No"
	foreach v of varlist 	h2 s45b0 s45pv1 s45pv2 s45pv3 h4 h6 h8 h9 ///
							s45sp1 s45sp2 s45d4 s45p4 s45nm1 ///
							s45nm2 s45nm3 s45rt1 s45rt2 s45if1 s45if2 {
	recode `v' (1/3 =1) (8=0)
	label values `v' vacuna
	}

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
	replace vacutot2=1 if (bedad<4 & h2==1 & pentavalente>=1 & antipolio>=1 & rotavirus>=1 & neumococo>=1)
	replace vacutot2=1 if (bedad<6 & h2==1 & pentavalente>=2 & antipolio>=2 & rotavirus>=2 & neumococo>=2)
	replace vacutot2=1 if (bedad<12 & h2==1 & pentavalente>=3 & antipolio>=3 & rotavirus>=2 & neumococo>=2)
	replace vacutot2=1 if (bedad<18 & h2==1 & pentavalente>=3 & antipolio>=3 & h9==1 & rotavirus>=2 & neumococo>=3)
	*s45sp1 está vacío
	replace vacutot2=1 if (bedad<=36 & h2==1 & pentavalente>=3 & antipolio>=3 & h9==1 & rotavirus>=2 & neumococo>=3 & s45sp2==1 & s45d4==1 & s45p4==1)					

*4.3. Tablas

	*	Esquema anterior
	tab vacutot1 if bedad<36 
	
	foreach v of varlist lenguamat v190 v106 sregion v025 {
	tab `v' vacutot1 [iw=factor] if (edadhijo<36 & b5==1), row 
	}

	*	Esquema nuevo
	foreach v of varlist lenguamat v190 v106 sregion v025 {
	tab `v' vacutot2 [iw=factor] if (edadhijo<36 & b5==1), row 
	}


}
*******************************************************************************/
*5. Salud sexual y reproductiva
{
use "$temp\salud_sexual.dta", clear
*use "$temp\salud_sexual2015.dta", clear

* 5.1. Creando las variables para cortes

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

* 5.2. Variables anticonceptivos

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

	recode v326 (11/19=1) (21 23/29=2) (22=3) (nonmissing=2), gen(fuente_metodo)
	label define fuente_metodo  1 "Sector Público" 2 "Otra fuente privada " 3 "Farmacia o botica"
	label values fuente_metodo fuente_metodo // fuente del método de anticonceptivo usado

	recode v301 (0/2=0) (3=1), gen(conoce_metodo)
	label define conoce_metodo  0 "No conoce" 1 "Conoce"
	label values conoce_metodo conoce_metodo // conocimiento de método de anticonceptivo moderno
	
*5.3. Tablas 


	* Uso actual de métodos anticonceptivos en mujeres actualmente unidas (15-49)
	foreach v of varlist lenguamat v190 v106 sregion v025 {
	tab `v' usa_metodo [iw=factor]  if v013!=0 & unidas==1  , row  
	}

	* Uso actual de métodos anticonceptivos en mujeres actualmente unidas (12-19)
	foreach v of varlist lenguamat v190 v106 sregion v025 {
	tab `v' usa_metodo [iw=factor] if (v013==0 | v013==1) & unidas==1, row  
	}

	*_________________________________________________________

	*Conocimiento de métodos anticonceptivos modernos, mujeres (15-49)
	foreach v of varlist s119 v190 v106 sregion v025 {
	tab `v' conoce_metodo [iw=factor]  if v013!=0 & unidas==1, row  
	}

	*Conocimiento de métodos anticonceptivos modernos, mujeres (12-19)
	foreach v of varlist s119 v190 v106 sregion v025 {
	tab `v' conoce_metodo [iw=factor]  if (v013==0 | v013==1) & unidas==1, row  
	}

	*Fuente del método utilizado para mujeres (15-49)
	tab  fuente_metodo if v013!=0 [iw=factor]
	*Fuente del método utilizado para mujeres (12-19)
	tab  fuente_metodo if (v013==0 | v013==1) [iw=factor]

}