/*******************************************************************************
Objetivo: Cálculo de indicadores del Capítulo 1 - Contexto
Autores:  CN

Estructura:
	0. Direcciones
    1. Ratio de dependencia
		
*******************************************************************************/

* 0. Direcciones

	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
* 1. RATIO DE DEPENDENCIA
{
	use "$temp\modulo200.dta", clear
	gen pob_dependiente = inrange(p208a,15,64)
	gen pob_trabajador= pob_dependiente
	replace pob_dependiente = cond(pob_dependiente==1,0,1)
	gen pob_dep_joven= cond(p208a<15,1,0)
	gen pob_dep_mayor= cond(p208a>64,1,0)

	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8

	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"

	label values dpto dpto

	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	*Tabla general
	preserve
	collapse (sum) pob_dependiente pob_trabajador pob_dep_joven pob_dep_mayor if filtro==1 [iw=facpob07], by(año)
	gen ratio_dep=pob_dependiente/pob_trabajador*100
	gen ratio_dep_joven=pob_dep_joven/pob_trabajador*100
	gen ratio_dep_mayor=pob_dep_mayor/pob_trabajador*100
	export excel using "$out1/datos", sheet("ratio_dependencia") sheetreplace firstrow(variables)
	restore

	*Tabla por departamento
	preserve
	collapse (sum) pob_dependiente pob_trabajador pob_dep_joven pob_dep_mayor if filtro==1 [iw=facpob07], by(dpto año)
	gen ratio_dep=pob_dependiente/pob_trabajador*100
	gen ratio_dep_joven=pob_dep_joven/pob_trabajador*100
	gen ratio_dep_mayor=pob_dep_mayor/pob_trabajador*100
	keep ratio_dep dpto año
	reshape wide ratio_dep, i(dpto) j(año)
	export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A17)
	restore

	*Población menor a 17 años
	preserve
	collapse (sum) filtro if filtro==1 [iw=facpob07], by(grupo_edad año)
	reshape wide filtro, i(grupo_edad) j(año)
	rename filtro* a*
	export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A47)
	restore

	*Población menor a 17 años por departamento
	preserve
	gen nna=(grupo_edad<4)
	collapse (sum) filtro nna if filtro==1 [iw=facpob07], by(dpto año)
	reshape wide filtro nna, i(dpto) j(año)
	order dpto nna* filtro*
	export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A57)
	restore
}