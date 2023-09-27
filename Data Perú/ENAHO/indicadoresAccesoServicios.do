/*******************************************************************************
Objetivo: Cálculo de indicadores de acceso a servicios 2007-2022
Autores:  CN

Estructura:
	0. Direcciones
    1. Acceso a TICs
    2. Acceso a servicios básicos
    3. Indicadores laborales - Jóvenes NiNis
		
*******************************************************************************/

* 0. Direcciones

	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

********************************************************************************
*	1. Acceso a TICs
{
	use "$temp\modulo100.dta", clear
	merge 1:m año conglome vivienda hogar using "$temp\modulo200.dta", keepusing(p208a p204 p205 p206 codperso)
	sort conglome vivienda hogar codperso
	keep if _merge==3
	
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label values area area

	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto
	
	rename (p1141 p1142 p1143 p1144 p1145) (fijo celu tv internet ninguno)
	
	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	*Acceso a TICs en el hogar
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (a?o)
	gen nac="Nacional"
	reshape wide fijo celu tv internet ninguno, i(nac) j(a?o) string
	order nac fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetreplace firstrow(variables) 
	restore

	*Acceso a TICs en el hogar por area de residencia 
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (area a?o)
	reshape wide fijo celu tv internet ninguno, i(area) j(a?o) string
	order area fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetmodify firstrow(variables) cell(A12)
	restore
  
	*Acceso a TICs en el hogar por grupo de edad
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (grupo_edad a?o)
	reshape wide fijo celu tv internet ninguno, i(grupo_edad) j(a?o) string
	order grupo_edad fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetmodify firstrow(variables) cell(A25)
	restore

}	
********************************************************************************
*	2. Acceso a servicios básicos 
{
	use "$temp\modulo100.dta", clear

	*área de residencia
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label val area area

	*Generando variables de acceso
	gen agua=cond(p110==1 | p110==2,100,cond(p110==.,.,0))
	gen desague=cond(p111a==1 | p111a==2,100,cond(p111a==.,.,0))
	gen electricidad=cond(p1121==1,100,cond(p1121==.,.,0))
	
	gen servicios=cond(agua==100 & desague==100 & electricidad==100,100,cond(agua==. & desague==. & electricidad==.,.,0))
	
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto
	
	*Por área de residencia
	preserve
	collapse (mean) agua desague electricidad servicios [iw=factor07], by(area año)
	reshape wide agua desague electricidad servicios , i(area) j(año) 
	order area agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetreplace firstrow(variables)
	restore

	*Por departamento 
	preserve
	collapse (mean) agua desague electricidad servicios [iw=factor07], by(dpto año)
	reshape wide agua desague electricidad servicios , i(dpto) j(año) 
	order dpto agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A15)
	restore
	
	merge 1:m año conglome vivienda hogar using "$temp\modulo200.dta", keepusing(p207 p208a facpob07)	/*Esto se debe correr 		*/
	drop if _merge==1																					/*antes de los siguientes 	*/
	gen nna=(p208a<18)																					/*puntos					*/

	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad
}
********************************************************************************
*	3. Tabulaciones
{
	*Seteamos el diseño muestral
	svyset [pweight = factor07], psu(conglome)strata(estrato)


	* Acceso a Agua

	gen acc_agua = 100 if p110==1 | p110==2 | p110==3
	replace acc_agua = 0 if acc_agua==.
	replace acc_agua = . if p110==.

	svy: mean acc_agua, over(dpto)

	svy: mean acc_agua, over(area)

	svy: mean acc_agua

	***** Acesso a agua al menos 12 horas (incluye 24 horas)

	gen acc_agua_12 = 100 if acc_agua == 100 & p110c1 > 11
	replace acc_agua_12 = 0 if acc_agua_12==.
	replace acc_agua_12 = . if p110==.

	svy: mean acc_agua_12, over(dpto)

	svy: mean acc_agua_12, over(area)

	svy: mean acc_agua_12

	***** Acesso a agua 24 horas

	gen acc_agua_24 = 100 if acc_agua == 100 & p110c1 == 24
	replace acc_agua_24 = 0 if acc_agua_24==.
	replace acc_agua_24 = . if p110==.

	svy: mean acc_agua_24, over(dpto)
	svy: mean acc_agua_24, over(area)
	svy: mean acc_agua_24

	* Acceso a Saneamiento

	gen acc_saneam = 100 if p111a == 1 | p111a == 2 | p111a == 4
	replace  acc_saneam = 0 if acc_saneam == .
	replace acc_saneam = . if p111a == .

	svy: mean acc_saneam, over(dpto)
	svy: mean acc_saneam, over(area)
	svy: mean acc_saneam

	* Acceso a Electrificación

	gen acc_elec = 100 if p1121 == 1
	replace  acc_elec = 0 if acc_elec == .
	replace acc_elec = . if p1121 == .

	svy: mean acc_elec, over(dpto)
	svy: mean acc_elec, over(area)
	svy: mean acc_elec

	* Acceso a Telefonía 

	gen acc_tel = 100 if p1142 == 1
	replace  acc_tel = 0 if acc_tel == .
	replace acc_tel = . if p1142 == .

	svy: mean acc_tel, over(dpto)
	svy: mean acc_tel, over(area)
	svy: mean acc_tel

	* Acceso a Internet 

	gen acc_inter = 100 if p1144 == 1
	replace  acc_inter = 0 if acc_inter == .
	replace acc_inter = . if p1144 == .

	svy: mean acc_inter, over(dpto)
	svy: mean  acc_inter, over(area)
	svy: mean acc_inter

	* Acceso a Agua, Saneamiento, Electrificación, Telefonía, Internet 

	gen acc_total = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100
	replace  acc_total = 0 if acc_total == .
	replace acc_total = . if p1144 == .

	svy: mean acc_total, over(dpto)
	svy: mean  acc_total, over(area)
	svy: mean acc_total

	***** Acceso a todos los servicios si tiene acceso a agua al menos 12 horas (incluye 24 horas)

	gen acc_total_12 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 > 11 & p110c1 != .
	replace  acc_total_12 = 0 if acc_total_12 == .
	replace acc_total_12 = . if p110==.

	svy: mean acc_total_12 , over(dpto)

	svy: mean acc_total_12, over(anio)

	***** Acceso a todos los servicios si tiene acceso a agua 24 horas

	gen acc_total_24 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 == 24
	replace  acc_total_24 = 0 if acc_total_24 == .
	replace acc_total_24 = . if if p110==.

	svy: mean acc_total_24 , over(dpto)

	svy: mean acc_total_24

	***** Acceso a todos los servicios si tiene acceso a agua menos de 12 horas

	gen acc_total_0 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 < 12  & p110c1 != .
	replace  acc_total_0 = 0 if acc_total_0 == .
	replace acc_total_0 = . if p110==.

	*local area_p = "2015 2016 2017 2018 2019 2020"

	svy: mean acc_total_0 , over(dpto)

	svy: mean acc_total_0
}
