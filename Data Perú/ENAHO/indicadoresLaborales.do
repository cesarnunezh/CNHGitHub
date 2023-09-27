/*******************************************************************************
Objetivo: Cálculo de indicadores laborales 2007-2022
Autores:  CN

Estructura:
	0. Direcciones
    1. Indicadores laborales - Generales
    2. Indicadores laborales - Género
    3. Indicadores laborales - Jóvenes NiNis
		
*******************************************************************************/

* 0. Direcciones

	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
*	1. POBLACIÓN ECONÓMICAMENTE OCUPADA
{
	use "$temp\modulo500.dta", clear

	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(quintil* pobre*)
	drop if _m==2

	* Se genera la variable de población ocupada
	gen ocupada = cond(ocu500==1,1,0)
	gen pea= cond(ocu500<3 & ocu500!=0,1,cond(ocu500==.,.,0))

	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label drop dpto
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto

	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p507 (1=1) (3 4 = 2) (2=3) (5=4) (6=5) (7=6), gen(categoria)
	label define tipo 1 "empleador" 2 "asalariado" 3 "independiente" 4 "Trabajador familiar no remunerado" 5 "Trabajador del hogar" 6 "Otro"
	label values categoria tipo

	recode p208a (14/24 =1) (25/44 =3) (45/64 =4) (nonmissing=5), gen(grupo_edad)
	label define grupo_edad 1 "14-24 años" 3 "25-44 años" 4 "45-64 años" 5 "65 años a más"
	label val grupo_edad grupo_edad

	gen area = estrato <6
	label drop area
	label define area 0 rural 1 urbana
	label val area area

	recode p512a (1 2 =2) (3 4 5=3),gen(tama)
	replace tama=1 if p512b<=10
	label define tama 1 "Menos de 10 trabajadores" 2 "Entre 11 y 50 trabajadores" 3 "Más de 50 trabajadores"
	label val tama tama

	recode i513t (0/30=1) (31/40=2) (41/50=3) (51/70=4) (nonmissing=5), gen(horasem)
	label define horasem 1 "Menos de 31 horas" 2 "Entre 31 y 40 horas" 3 "Entre 41 y 50 horas" 4 "Entre 51 y 70 horas" 5 "De 71 a más horas"
	label val horasem horasem

	*Tabla general
	preserve
	collapse (sum) ocupada pea (count) ocu500 if filtro==1 [iw=fac500a], by(año)
	gen tasa_desempleo=100-ocupada/pea*100
	gen tasa_actividad=pea/ocu500*100
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetreplace firstrow(variables) 
	restore

	*Tabla por departamento
	preserve
	collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(dpto año)
	gen tasa_desempleo=100-ocupada/pea*100
	keep tasa_desempleo dpto año
	reshape wide tasa_desempleo, i(dpto) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A17)
	restore

	*Tabla por sexo
	preserve
	collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(p207 año)
	gen tasa_desempleo=100-ocupada/pea*100
	drop pea
	reshape wide tasa_desempleo ocupada , i(p207) j(año)
	order p207 ocupada* tasa_desempleo*
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A46)
	restore

	*Tabla por categoria de empleo
	preserve
	collapse (sum) ocupada if filtro==1 [iw=fac500a] , by(categoria año)
	reshape wide ocupada, i(categoria) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A54)
	restore

	*Empleo informal
	preserve
	collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf año)
	reshape wide ocupada, i(ocupinf) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A65)
	restore

	*Empleo informal por grupos de edad
	preserve
	collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf grupo_edad año)
	reshape wide ocupada, i(ocupinf grupo_edad) j(año)
	rename (ocupada*) (a*) 
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A69)
	restore

	*Empleo informal por sexo
	preserve
	collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf p207 año)
	reshape wide ocupada, i(ocupinf p207) j(año)
	rename (ocupada*) (a*) 
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A83)
	restore


	*Tabla por area de residencia
	preserve
	collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(area año)
	gen tasa_desempleo=100-ocupada/pea*100
	drop pea
	reshape wide tasa_desempleo ocupada , i(area) j(año)
	order area ocupada* tasa_desempleo*
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A90)
	restore

	*Tabla por grupos de edad
	preserve
	collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(grupo_edad año)
	gen tasa_desempleo=100-ocupada/pea*100
	drop pea
	reshape wide tasa_desempleo ocupada, i(grupo_edad) j(año)
	order grupo_edad ocupada* tasa_desempleo*
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A98)
	restore

	*PEAO por tamaño de empresa
	preserve
	collapse (sum) ocupada if filtro==1 [iw=fac500a], by(tama año)
	reshape wide  ocupada, i(tama) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A108)
	restore

	*PEAO por horas semanales
	preserve
	collapse (sum) ocupada if filtro==1 [iw=fac500a], by(horasem año)
	reshape wide  ocupada, i(horasem) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A115)
	restore

	*PEAO por acceso a seguro de salud
	preserve
	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo400.dta", keepusing(p419*)
	drop if _merge==2

	replace p4199= cond(p4191==2 & p4192==2 & p4193==2 & p4194==2 & p4195==2 & p4196==2 & p4197==2 & p4198==2, 1,cond(p4191==. & p4192==. & p4193==. & p4194==. & p4195==. & p4196==. & p4197==. & p4198==.,.,0)) if (p4199==. & (año!=2007 | año!=2008 | año!=2009 | año!=2010 | año!=2011))

	gen essalud=cond(p4191==1,100,cond(p4191==.,.,0))	
	gen privado=cond(p4192==1,100,cond(p4192==.,.,0))	
	gen eps=cond(p4193==1,100,cond(p4193==.,.,0))	
	gen ffaaffpp=cond(p4194==1,100,cond(p4194==.,.,0))	
	gen sis=cond(p4195==1,100,cond(p4195==.,.,0))	
	gen univ=cond(p4196==1,100,cond(p4196==.,.,0))	
	gen escolar=cond(p4197==1,100,cond(p4197==.,.,0))	
	gen otro=cond(p4198==1,100,cond(p4198==.,.,0))	
	gen ninguno=cond(p4199==1,100,cond(p4199==.,.,0))	

	collapse (mean) essalud privado eps ffaaffpp sis univ escolar otro ninguno if filtro==1 & ocupada==1 [iw=fac500a], by(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A124)
	restore

	*Informalidad por quintiles de ingreso
	preserve
	replace ocupinf=0 if ocupinf==2
	replace ocupinf=100 if ocupinf==1
	collapse (mean) ocupinf if filtro==1 [iw=fac500a], by(quintil_i año)
	reshape wide  ocupinf, i(quintil_i) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A139)
	restore

	*Informalidad por nivel de educación
	preserve
	replace ocupinf=0 if ocupinf==2
	replace ocupinf=100 if ocupinf==1
	recode p301a (1/3=1) (4/5=2) (6 7 9 =3) (8=4) (10=5) (11=6) (12=7) (99=.), gen(edu_max)
	label define edu_max 1 "Sin nivel o inicial" 2 "Primaria" 3 "Secundaria" 4 "Sup. No Universitaria" 5 "Sup. Universitaria" 6 "Post-grado" 7 "Básica especial"
	label val edu_max edu_max
	collapse (mean) ocupinf if filtro==1 [iw=fac500a], by(edu_max año)
	reshape wide  ocupinf, i(edu_max) j(año)
	export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A147)
	restore

}
*	2. Indicadores laborales - Género
{
	*Mujeres en cargos populares

	use "$temp\modulo500.dta", clear
	
	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	*Generamos la variable mujer
	gen mujer=cond(p207==2,100,cond(p207==.,.,0))

	*Generamos la variable cargo directivo
	recode p505 (111/148=1) (nonmissing=0), gen(cargo_directivo)
	recode p505r4 (1100/1499=1) (nonmissing=0), gen(cargo_directivo1)
	
	preserve
	collapse (mean) mujer if filtro==1 & cargo_directivo==1 [iw=fac500a], by(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetreplace firstrow(variables) 
	restore

	preserve
	collapse (mean) mujer if filtro==1 & cargo_directivo1==1 [iw=fac500a], by(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(D1)
	restore

	*Proporción del ingreso real de las mujeres respecto al de los hombres

	**A continuación, limpiamos las variables de las fuentes de ingresos
	recode i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t (.=0)
	**Con las variables limpias, obtenemos el ingreso anual total proveniente del trabajo. Luego lo hacemos mensual e incluimos las etiquetas a las nuevas variables:
	egen ingtrabw = rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
	gen ingtram=ingtrabw/(12)
	label var ingtrabw "Ingreso por trabajo anual"
	label var ingtram "Ingreso por trabajo mensual"
	
	**Finalmente, calculamos el ingreso promedio mensual proveniente del trabajo por sexo
   	preserve
	collapse (mean) ingtram if filtro==1 & ocu500==1 & ingtram>0 [iw=fac500a], by(p207 año)
	reshape wide ingtram, i(p207) j(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(A16)
	restore

	**Ingreso promedio mensual proveniente del trabajo por sexo por niveles de educación
   	recode p301a (1/3=1) (4/5=2) (6 7 9 =3) (8=4) (10=5) (11=6) (12=7) (99=.), gen(edu_max)
	label define edu_max 1 "Sin nivel o inicial" 2 "Primaria" 3 "Secundaria" 4 "Sup. No Universitaria" 5 "Sup. Universitaria" 6 "Post-grado" 7 "Básica especial"
	label val edu_max edu_max
	preserve
	collapse (mean) ingtram if filtro==1 & ocu500==1 & ingtram>0 [iw=fac500a], by(edu_max p207 año)
	reshape wide ingtram, i(edu_max p207) j(año)
	drop if edu_max==.
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(A20)
	restore
}
*	3. Jóvenes NiNis 
{
	use "$temp\modulo300.dta", clear
	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo500.dta", keepusing(ocu500 fac*)
	sort conglome vivienda hogar codperso
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(pobreza decil_g quintil_g decil_i quintil_i) nolabel 
	drop if _m==2
	drop _m

	tab p306 p307, nol
	tab p306 p310 if p208a>14 & p208a<25, nol
	
	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	replace fac500a=fac500a7 if año==2011
	*Generamos los departamentos
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)

	replace dpto=26 if dpto==15 & dominio!=8

	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"

	label values dpto dpto
	
	*Área de residencia
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label val area area
	
	*Generamos la variable de no estudia, que incluye a los no matriculados y a los matriculados que no asisten
	gen no_estudia=(p306==2 | p307==2) 
	gen no_capacita=(p310==2)
	
	*Generamos la variable que no trabaja
	gen no_trabaja=(ocu500!=1 & ocu500!=.)
	
	*Generamos la variable nini
	gen nini=(no_estudia==1 & no_trabaja==1 & no_capacita==1)
	
	*Por año
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año)  
	gen id="Nacional"
	replace nini=nini*100
	reshape wide nini, i(id) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetreplace firstrow(variables)
	restore

	*Por departamento
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año dpto)  
	replace nini=nini*100
	reshape wide nini, i(dpto) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A5)
	restore

	*Por sexo
	preserve
	label define sexo 1 "Hombre" 2 "Mujer"
	label values p207 sexo
	gen nini_2=nini
	collapse (mean) nini (sum) nini_2 if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año p207)  
	replace nini=nini*100
	reshape wide nini nini_2, i(p207) j(año)
	order p207 nini_* nini*	
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A34)
	restore

	*Por área de residencia
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año area)  
	replace nini=nini*100
	reshape wide nini, i(area) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A39)
	restore

	*Por quintil de ingresos
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año quintil_i)  
	replace nini=nini*100
	reshape wide nini, i(quintil_i) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A45)
	restore

	*Por decil de ingresos
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año decil_i)  
	replace nini=nini*100
	reshape wide nini, i(decil_i) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A55)
	restore
}	
