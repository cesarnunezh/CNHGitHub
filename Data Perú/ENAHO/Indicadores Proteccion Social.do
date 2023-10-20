/*******************************************************************************
Proyecto: UNICEF - SITAN
Objetivo: Cálculo de indicadores del Capítulo 4 - Protección Social
Autores:  MG - CN

Objetivo: 	Realizar el cálculo de los indicadores de pobreza y pobreza multidi 
			mensional entre las niñas, niños y adolescentes, acceso a seguro de 
			salud, entre otros

Estructura:
	0. Direcciones
    1. Pobreza monetaria y multidimensional
	2. Acceso a seguros de salud
	3. Programas sociales
	4. Acceso a la identidad
		
*******************************************************************************/

* 	0. Direcciones
{
	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data\Anual"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"
}
********************************************************************************
*	1. Pobreza monetaria y multidimensional - ENAHO
{
* 1.1. Merge de bases 	
	use "$temp1\modulo200.dta", clear
	keep año conglome vivienda hogar codperso fac* p208a p203 p204 p205 p206
	merge m:1 año conglome vivienda hogar using "$temp1\modulo100.dta", keepusing(p11* p103 dominio fac*)
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp1\sumaria.dta", keepusing(pobreza area fac* dpto quintil*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo300.dta", keepusing(p300a p301a p303 fac*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo400.dta", keepusing(p409* fac*)
	drop if _m==2
	drop _m
	
	save "$temp1\pobreza.dta", replace

* 1.2. Creación de variables IPM - Privaciones

	use "$temp1\pobreza.dta", clear

	*	Jefe del hogar tiene primaria completa o menos
	gen educ_jefe=(p203==1 & p301a<=4)
	bys año conglome vivienda hogar: egen priv_1=max(educ_jefe)
	
	*	Hogar con niño en edad escolar (6-18) que no está matriculado y aún no termina la secundaria
	gen edad_escolar=(p208a<=18 & p301a<=5 & p303==2)
	gen edad_escolar_aux=cond(p208a==.,.,cond(p208a<=18,1,0))
	bys año conglome vivienda hogar: egen priv_2=max(edad_escolar)
	bys año conglome vivienda hogar: egen ninos=total(edad_escolar_aux)
	replace priv_2=0 if ninos==0
	
	* Sin acceso a servicios de salud porque: no tiene dinero, el CC.SS. se encuentra lejos de su vivienda o no tiene seguro de salud.
	gen salud=cond(p4091==. & p4092 ==. & p4097==.,.,cond(p4091==1 | p4092 ==1 | p4097==1,1,0))
	bys año conglome vivienda hogar: egen priv_3=max(salud)
	replace priv_3=1 if priv_3==0.5
	
	* Su vivienda no tiene electricidad	
	gen priv_5=cond(p1121==.,.,cond(p1121==1,0,1))
	
	* Su vivienda no tiene acceso adecuado a agua potable
	gen priv_6=cond(p110==.,.,cond(p110==1 | p110==2,0,1))
	
	* Su vivienda no tiene desagüe con conexión a red pública
	gen priv_7=cond(p111a==.,.,cond(p111a==1 | p111a==2,0,1))
	
	* El piso de su vivienda está sucio, con arena o estiércol
	gen priv_8=cond(p103==.,.,cond(p103==6| p103==7,1,0))
	
	* En su vivienda se usa generalmente carbón o leña para cocinar
	gen priv_9=(p113a==5 | p113a==6)
	replace priv_9=0 if (p113a==.)
	
* 1.3. Creación de el IPM

	gen ipm=priv_1/6+ priv_2/6+ priv_3/3+ priv_5/15+ priv_6/15+ priv_7/15+ priv_8/15+ priv_9/15
	gen pobre_ipm=cond(ipm==.,.,cond(ipm>1/3,1,0))*100
	
* 1.4. Creando variables de pobreza y edad

	*Filtro de residentes en el hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	*Variables de pobreza y pobreza extrema 
	gen pobre_extremo=cond(pobreza==1,100,cond(pobreza==.,.,0))
	gen pobre=cond(pobreza==1 | pobreza==2,100,cond(pobreza==.,.,0))

	*Variable de categorías de edad
	recode p208a (0/5=1) (6/11=2) (12/17=3) (nonmissing =4), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18 a más"
	label val grupo_edad grupo_edad

	*Variable de educación del jefe de hogar (máximo nivel completado)
	gen educ_jefe2=p301a if p203==1 
	bys año conglome vivienda hogar: egen educ_jefe3=max(educ_jefe2)
	recode educ_jefe3 (1/3=1) (4/5=2) (6 7 9 =3) (8 10 11 = 4)
	label define educ_jefe3 1 "Sin nivel o inicial" 2 "Primaria completa" 3 "Secundaria completa" 4 "Educación superior"
	label val educ_jefe3 educ_jefe3 

	*Variable de lengua materna
	recode p300a (1 =1 ) (2=2) (3 = 3) (4 = 4) (5/9=.), gen(lenguamat)
	label define lenguamat 1 "Quechua" 2 "Aymara" 3 "Otra lengua originaria" 4 "Castellano" 
	label val lenguamat lenguamat
	
	*Variable de dominio geográfico
	recode dominio (1/3=1) (4/6=2) (7=3) (8=4), gen(dominio2)
	label define dominio2 1 "Resto costa" 2 "Sierra" 3 "Selva" 4 "Lima Metropolitana"
	label val dominio2 dominio2
	
* 1.5. Tablas finales
	
	table año [iw=facpob07] if filtro==1, c(mean pobre_ipm mean pobre mean pobre_extremo)
	table año [iw=facpob07] if grupo_edad<=3, c(mean pobre mean pobre_extremo)

	
	table area año [iw=facpob07] if grupo_edad<=3 & (año==2015 | año==2019), c(mean pobre mean pobre_extremo)

	table dominio2 año [iw=facpob07] if grupo_edad<=3 & (año==2015 | año==2019), c(mean pobre mean pobre_extremo)	
	
	table lenguamat año [iw=facpob07] if grupo_edad<=3 & (año==2015 | año==2019), c(mean pobre_extremo)	
	
	*Tabla general
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(año)  
	gen nac="Nacional"
	reshape wide pobre_ipm pobre pobre_extremo, i(nac) j(año)
	order nac pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetreplace firstrow(variables) 
	restore

	*Por área de residencia
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(area año)  
	reshape wide pobre_ipm pobre pobre_extremo, i(area) j(año)
	order area pobre2* pobre_e* pobre_i* 
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A5)
	restore

	*Por departamento
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(dpto año)  
	reshape wide pobre_ipm pobre pobre_extremo, i(dpto) j(año)
	order dpto pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A10)
	restore
	
	*Por grupo de edad
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(grupo_edad año)  
	reshape wide pobre_ipm pobre pobre_extremo, i(grupo_edad) j(año)
	order grupo_edad pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A37)
	restore

	*Por lengua materna
	preserve
	keep if grupo_edad<=3
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(lenguamat año)  
	reshape wide  pobre_ipm pobre pobre_extremo, i(lenguamat) j(año)
	order lenguamat pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A43)
	restore
	
	*Por educacion del jefe de hogar
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(educ_jefe3 año)  
	reshape wide pobre_ipm pobre pobre_extremo, i(educ_jefe3) j(año)
	order educ_jefe3 pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A52)
	restore

	*Por dominio geográfico
	preserve
	collapse (mean) pobre_ipm pobre pobre_extremo if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(dominio2 año)  
	reshape wide pobre_ipm pobre pobre_extremo, i(dominio2) j(año)
	order dominio2 pobre2* pobre_e* pobre_i*
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A64)
	restore
	
	*Por privaciones
	preserve
	foreach x of varlist priv_1-priv_9 {
	replace `x'=`x' * 100
	}
	collapse (mean) pobre_ipm priv_* if filtro==1 &  grupo_edad<=3 [iw=facpob07], by(año)  
	export excel using "$out1/proteccion_social", sheet("pobreza") sheetmodify firstrow(variables) cell(A74)
	restore
		
}
********************************************************************************
*	2. Acceso a seguros de salud - ENAHO
 {  
	use "$temp1\modulo400.dta", clear
	
	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo300.dta", keepusing(p300a fac*)
	drop if _m==2
	drop _m

	merge m:1 año conglome vivienda hogar using "$temp1\sumaria.dta", keepusing(pobreza dominio area fac* dpto quintil*)
	drop if _m==2
	drop _m

	*Se genera la variable de no afiliado para los años posteriores al 2011
	replace p4199= cond(p4191==2 & p4192==2 & p4193==2 & p4194==2 & p4195==2 & p4196==2 & p4197==2 & p4198==2, 1,cond(p4191==. & p4192==. & p4193==. & p4194==. & p4195==. & p4196==. & p4197==. & p4198==.,.,0)) if (p4199==. & (año!=2007 | año!=2008 | año!=2009 | año!=2010 | año!= 2011))
 
	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	gen sin_seguro = cond(p4199==1,100,cond(p4199==0,0,.))
	
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	* Dominio geográfico
	recode dominio (1/3=1) (4/6=2) (7=3) (8=4), gen(dominio2)
	label define dominio2 1 "Resto costa" 2 "Sierra" 3 "Selva" 4 "Lima Metropolitana"
	label val dominio2 dominio2
	
	keep if año==2015 | año==2019
	
	table area año [iw=factora07] if filtro==1 & grupo_edad<=3, c(mean sin_seguro)
	
	*Niños, niñas y adolescentes con seguro de salud
	preserve
	collapse (mean) con_seguro if filtro==1 & grupo_edad<=3 [iw=factora07], by(año)
	gen nac="Nacional"
	reshape wide con_seguro, i(nac) j(año) 
	rename con_seguro* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetreplace firstrow(variables)
	restore
 
    *Población con seguro de salud por area de residencia
	preserve
	collapse (mean) con_seguro if filtro==1 & grupo_edad<=3 [iw=factora07], by(area año)
	reshape wide con_seguro, i(area) j(año) 
	rename con_seguro* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetmodify firstrow(variables) cell(A10)
	restore

    *Niños, niñas y adolescentes con seguro de salud por grupo de edad 
	preserve
	collapse (mean) con_seguro if filtro==1 & grupo_edad<=3 [iw=factora07], by(dominio2 año)
	reshape wide con_seguro, i(dominio2) j(año) 
	rename con_seguro* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetmodify firstrow(variables) cell(A20)
	restore

	*Niños, niñas y adolescentes con seguro de salud por tipo de seguro de salud
	gen essalud=cond(p4191==1,100,cond(p4191==.,.,0))	
	gen privado=cond(p4192==1,100,cond(p4192==.,.,0))	
	gen eps=cond(p4193==1,100,cond(p4193==.,.,0))	
	gen ffaaffpp=cond(p4194==1,100,cond(p4194==.,.,0))	
	gen sis=cond(p4195==1,100,cond(p4195==.,.,0))	
	gen univ=cond(p4196==1,100,cond(p4196==.,.,0))	
	gen escolar=cond(p4197==1,100,cond(p4197==.,.,0))	
	gen otro=cond(p4198==1,100,cond(p4198==.,.,0))	
	gen ninguno=cond(p4199==1,100,cond(p4199==.,.,0))	
	preserve
	collapse (mean) con_seguro (mean) essalud privado eps ffaaffpp sis univ escolar otro ninguno if filtro==1 & grupo_edad<=3 [iw=factora07], by(año)
	gen nac="Nacional"
	reshape wide con_seguro essalud privado eps ffaaffpp sis univ escolar otro ninguno, i(nac) j(año)
	order nac con* ess* priv* eps* ff* sis* univ* escolar* otro* ninguno*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetmodify firstrow(variables) cell(A30)
	restore
    
	*Niñas, niños y adolescentes con seguro de salud por lengua materna
	preserve
	recode p300a (1/3=3) (4=4) (5 6 7= 5) (8 9 = 6), gen(lengua)
	label define lengua 1 "Quechua" 2 "Aymara" 3 "Otra lengua nativa" 4 "Castellano" 5 "Lengua extranjera" 6 "Sordomudo o lenguaje de señas"
	label values lengua lengua 
	drop p300a
	collapse (mean) con_seguro if filtro==1 & grupo_edad<=3 [iw=factora07], by(lengua año)  
	reshape wide con_seguro , i(lengua) j(año)
	rename con_seguro* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetmodify firstrow(variables) cell(A40)
	restore

	*Niñas, niños y adolescentes con seguro de salud por quintil de ingresos
	preserve
	collapse (mean) con_seguro if filtro==1 & grupo_edad<=3 [iw=factora07], by(quintil_i año)  
	reshape wide con_seguro , i(quintil_i) j(año)
	rename con_seguro* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a salud") sheetmodify firstrow(variables) cell(A50)
	restore
	
* SIS

	gen sis=cond(p4195==1,100,cond(p4195==.,.,0))	

	*Niños, niñas y adolescentes con seguro de salud
	preserve
	collapse (mean) sis if filtro==1 & grupo_edad<=3 & pobreza <3 [iw=factora07], by(año)
	gen nac="Nacional"
	reshape wide sis, i(nac) j(año) 
	rename sis* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a SIS") sheetreplace firstrow(variables)
	restore
 
    *Población con seguro de salud por area de residencia
	preserve
	collapse (mean) sis if filtro==1 & grupo_edad<=3 & pobreza <3 [iw=factora07], by(area año)
	reshape wide sis, i(area) j(año) 
	rename sis* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a SIS") sheetmodify firstrow(variables) cell(A10)
	restore

    *Niños, niñas y adolescentes con seguro de salud por grupo de edad 
	preserve
	collapse (mean) sis if filtro==1 & grupo_edad<=3 & pobreza <3 [iw=factora07], by(dominio2 año)
	reshape wide sis, i(dominio2) j(año) 
	rename sis* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a SIS") sheetmodify firstrow(variables) cell(A20)
	restore

	*Niñas, niños y adolescentes con seguro de salud por lengua materna
	preserve
	recode p300a (1/3=3) (4=4) (5 6 7= 5) (8 9 = 6), gen(lengua)
	label define lengua 1 "Quechua" 2 "Aymara" 3 "Otra lengua nativa" 4 "Castellano" 5 "Lengua extranjera" 6 "Sordomudo o lenguaje de señas"
	label values lengua lengua 
	drop p300a
	collapse (mean) sis if filtro==1 & grupo_edad<=3 & pobreza <3 [iw=factora07], by(lengua año)  
	reshape wide sis , i(lengua) j(año)
	rename sis* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a SIS") sheetmodify firstrow(variables) cell(A30)
	restore

	*Niñas, niños y adolescentes con seguro de salud por quintil de ingresos
	preserve
	collapse (mean) sis if filtro==1 & grupo_edad<=3 & pobreza <3 [iw=factora07], by(quintil_i año)  
	reshape wide sis , i(quintil_i) j(año)
	rename sis* a*
	export excel using "$out1/proteccion_social", sheet("Acceso a SIS") sheetmodify firstrow(variables) cell(A40)
	restore
	
	
}
********************************************************************************
*	3. Programas sociales - ENAHO
{
	use "$base1\enaho01-2015-700.dta", clear
		
	forval			i=2016/2022 {
	append using "$base1\enaho01-`i'-700.dta"
	}
	
	rename a?o año
	destring año, replace
	
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	
	drop dominio
	merge 1:1 año conglome vivienda hogar using "$temp1\sumaria.dta", keepusing(pobreza dominio dpto area fac* quintil_i quintil_g)
	drop if _m==2
	drop _m

	preserve
	use "$temp1\modulo200.dta", clear
	keep año conglome vivienda hogar codperso fac* p208a p203 p204 p205 p206
	
	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo300.dta", keepusing(p300a p301a)
	drop if _merge==2
	drop _merge
	
	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo500.dta", keepusing(ocu500 )
	drop if _merge==2
	drop _merge
	
	gen menor_edad=cond(p208a==.,.,cond(p208a<18,1,0))
	gen menor_3años=cond(p208a==.,.,cond(p208a<3,1,0))
	gen jovenes=cond(p208a==.,.,cond(p208a<30 & p208a>14 & (ocu500==2 | ocu500==3) & (p301a<=7 | p301a==9 ),1,0)) 
	
	
	*Variable de educación del jefe de hogar (máximo nivel completado)
	gen educ_jefe2=p301a if p203==1 
	bys año conglome vivienda hogar: egen educ_jefe3=max(educ_jefe2)
	recode educ_jefe3 (1/3=1) (4/5=2) (6 7 9 =3) (8 10 11 = 4)
	label define educ_jefe3 1 "Sin nivel o inicial" 2 "Primaria completa" 3 "Secundaria completa" 4 "Educación superior"
	label val educ_jefe3 educ_jefe3 

	*Variable de lengua materna
	recode p300a (1/3 =1 ) (4=2) (5/7 = 3) (8/9 = 4), gen(lenguamat)
	gen lengua_menor=lenguamat if p208a<18
	bys año conglome vivienda hogar: egen lengua_menor2=max(lengua_menor)

	
	collapse (sum) menor_edad menor_3años jovenes (mean) educ_jefe3 lengua_menor2 , by(año conglome vivienda hogar)
	replace menor_edad=1 if menor_edad>0
	replace menor_3años=1 if menor_3años>0
	replace jovenes=1 if jovenes>0
	
	tempfile ninos
	save `ninos'
	restore
	
	merge 1:1 año conglome vivienda hogar using `ninos', keepusing(menor_edad menor_3años jovenes educ_jefe3 lengua_menor2)
	drop if _m==2
	drop _m
	
	
	replace p710_14=1 if p710_14==14
	
	save "$temp1\programas.dta", replace
	
*	3.1. Creación de variables

	use "$temp1\programas.dta", clear
	
	* Variables de programas sociales
	rename (p701_01 p701_02 p701_03 p701_04 p701_05 p710_01 p710_02 p710_03 p710_04 p710_05 p710_06 p710_07 p710_08 p710_09 p710_10) (vaso_leche comedor_pop qali_desayuno qali_almuerzo cuna_diurno1 cuna_diurno2 cuna_acomp violencia juntos pension65 alfabet jov_prod trabaja_peru impulsa_peru beca18)
	
	gen no_programa=cond(p701_09==1 & p710_14==1,100,cond(p701_09==. & p710_14==.,.,0))
	gen qali_warma=cond(qali_desayuno==1 | qali_almuerzo==1, 100, cond(qali_desayuno==. & qali_almuerzo==., .,0))
	gen cuna_mas=cond(cuna_diurno1==1 | cuna_diurno2==1 | cuna_acomp==1, 100, cond(cuna_diurno1==. & cuna_diurno2==. & cuna_acomp==., .,0))
	gen prog_trabajo=cond(jov_prod==1 | trabaja_peru==1 | impulsa_peru==1,100,cond(jov_prod==. & trabaja_peru==. & impulsa_peru==.,.,0))
	egen programa=rowtotal(qali_warma jov_prod cuna_mas juntos comedor_pop)
	replace programa=100 if programa>100
	
	foreach x of varlist p701_09 p710_14 vaso_leche comedor_pop qali_desayuno qali_almuerzo cuna_diurno1 cuna_diurno2 cuna_acomp violencia juntos pension65 alfabet jov_prod trabaja_peru impulsa_peru beca18 {
	replace `x'=100 if `x'==1
	}
	
	* Dominio geográfico
	recode dominio (1/3=1) (4/6=2) (7=3) (8=4), gen(dominio2)
	label define dominio2 1 "Resto costa" 2 "Sierra" 3 "Selva" 4 "Lima Metropolitana"
	label val dominio2 dominio2

	label define lengua_menor2 1 "Lengua nativa u originaria" 2 "Castellano" 3 "Lengua extranjera" 4 "Sordomudo o lenguaje de señas"
	label val  lengua_menor2 lengua_menor2

	label define educ_jefe3 1 "Sin nivel o inicial" 2 "Primaria completa" 3 "Secundaria completa" 4 "Educación superior"
	label val educ_jefe3 educ_jefe3 
	
*	3.2. Tablas

	table area [iw=factor07] if año==2019 & pobreza<3 & menor_edad==1, c(mean juntos mean qali_warma mean comedor_pop mean pension65 mean jov_prod) row col
	table dominio2 [iw=factor07] if año==2019 & pobreza<3 & menor_edad==1, c(mean juntos mean qali_warma mean comedor_pop mean pension65 mean jov_prod) row col
	table quintil_i  [iw=factor07] if año==2019 & pobreza<3 & menor_edad==1, c(mean juntos mean qali_warma mean comedor_pop mean pension65 mean jov_prod) row col
	table educ_jefe3  [iw=factor07] if año==2019 & pobreza<3 & menor_edad==1, c(mean juntos mean qali_warma mean comedor_pop mean pension65 mean jov_prod) row col
	table lengua_menor2 [iw=factor07] if año==2019 & pobreza<3 & menor_edad==1, c(mean juntos mean qali_warma mean comedor_pop mean pension65 mean jov_prod) row col

	table area [iw=factor07] if año==2015 & pobreza<3 & menor_3años==1, c(mean cuna_mas) row col
	table dominio2 [iw=factor07] if año==2015 & pobreza<3 & menor_3años==1, c(mean cuna_mas) row col
	table quintil_i  [iw=factor07] if año==2015 & pobreza<3 & menor_3años==1, c(mean cuna_mas) row col
	table educ_jefe3  [iw=factor07] if año==2015 & pobreza<3 & menor_3años==1, c(mean cuna_mas) row col
	table lengua_menor2 [iw=factor07] if año==2015 & pobreza<3 & menor_3años==1, c(mean cuna_mas) row col
	
	table area [iw=factor07] if año==2019 & pobreza<3 & jovenes==1, c(mean jov_prod) row col
	table dominio2 [iw=factor07] if año==2019 & pobreza<3 & jovenes==1, c(mean jov_prod) row col
	table quintil_i  [iw=factor07] if año==2019 & pobreza<3  & jovenes==1, c(mean jov_prod) row col
	table educ_jefe3  [iw=factor07] if año==2019 & pobreza<3 & jovenes==1, c(mean jov_prod) row col
	table lengua_menor2 [iw=factor07] if año==2019 & pobreza<3 & jovenes==1, c(mean jov_prod) row col
	
	*Hogares pobres con NNA sin acceso a programas alimentarios ni sociales 
	preserve
	collapse (mean) no_programa if pobreza<3 & menor_edad==1 [iw=factor07], by(año)
	export excel using "$out1/proteccion_social", sheet("Programas sociales") sheetreplace firstrow(variables) 
	restore

	*Hogares pobres con NNA sin acceso a programas alimentarios ni sociales por área de residencia
	preserve
	collapse (mean) no_programa if pobreza<3 & menor_edad==1 [iw=factor07], by(area año)
	reshape wide no_programa, i(area) j(año)
	rename (no_programa*) (a*)
	export excel using "$out1/proteccion_social", sheet("Programas sociales") sheetmodify firstrow(variables) cell(A8)
	restore

	*Hogares pobres con NNA con acceso a programas sociales seleccionados 
	preserve
	collapse (mean) programa if pobreza<3 & menor_edad==1 [iw=factor07], by(año)
	export excel using "$out1/proteccion_social", sheet("Programas sociales") sheetmodify firstrow(variables) cell(A14)
	restore

	*Hogares pobres con NNA con acceso a programas sociales seleccionados por área de residencia
	preserve
	collapse (mean) programa if pobreza<3 & menor_edad==1 [iw=factor07], by(area año)
	reshape wide programa, i(area) j(año)
	rename (programa*) (a*)
	export excel using "$out1/proteccion_social", sheet("Programas sociales") sheetmodify firstrow(variables) cell(A22)
	restore

	*Hogares pobres con NNA con acceso a programas alimentarios o sociales según programa
	preserve
	collapse (mean) vaso_leche comedor_pop qali_warma cuna_mas violencia juntos pension65 alfabet prog_trabajo beca18 no_programa if pobreza<3 & menor_edad==1 [iw=factor07], by(año)
	export excel using "$out1/proteccion_social", sheet("Programas sociales") sheetmodify firstrow(variables) cell(A28)
	restore
	
	*CONTIGO - CALCULO ESPECIAL
	
	use "$base1\enaho01a-2015-400.dta", clear
	global var_4 "conglome vivienda hogar codperso estrato dominio ubigeo p401 p401h* p4021 p4022 p4023 p4024 p4025 p4031-p40314 p4091-p40911 p4151_* p4152_* p4153_* p4154_* p417_02 p417_08 p417_11 p417_12 p417_13 p417_14 p419* i416* p419* p2* fac*"
	keep $var_4
	gen año=2015
	forvalues i= 2016/2019{
    append using "$base1\enaho01a-`i'-400.dta", force keep($var_4)
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	
	foreach x of varlist p401h1 p401h2 p401h3 p401h4 p401h5 p401h6{
	replace `x'=0 if `x'==2
	}
	
	egen discapacidad=rowtotal(p401h1-p401h6)
	replace discapacidad=1 if discapacidad>1
	
	save "$temp1\discapacidad.dta",replace
	
	use "$temp1\modulo200.dta", clear
	keep año conglome vivienda hogar codperso fac* p208a p203 p204 p205 p206
	merge m:1 año conglome vivienda hogar using "$temp1\modulo100.dta", keepusing(p11* p103 fac*)
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp1\sumaria.dta", keepusing(pobreza area fac* dpto quintil*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp1\modulo300.dta", keepusing(p300a p301a p303 fac*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp1\discapacidad.dta", keepusing(p401h* discapacidad)
	drop if _m==2
	drop _m
	
	save "$temp1\discapacidad.dta", replace

	*Variable de categorías de edad
	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	*Filtro de residentes en el hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	table año discapacidad [iw=factora07] if filtro==1 & pobreza<3 & grupo_edad<=3, format(%12.0fc) col
	
	
}	
********************************************************************************
*	4. Acceso a la identidad - ENDES
{
	use "$base2\rec94_2019.dta", clear
	
	merge 		m:1 caseid using "$base2/rec0111_2019.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	rename 		 idx94 bord

	merge 		1:1 caseid bord using "$base2/rec21_2019.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	rename 		bord hidx

	merge 		m:1 caseid using "$base2/rec91_2019.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	rename 		hidx idx95

	merge 		1:1 caseid idx95 using "$base2/rec95_2019.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	
*	gen hhid=substr(caseid,1,15)
	
*	merge 		m:1 hhid using "$base2/rech0_2015.dta", keepusing(hv005 hv025)

	gen 		factor=v005/1000000

	save "$temp2\identidad.dta", replace

	
	*4.1. Creando las variables para cortes

	use "$temp2\identidad.dta", clear

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


	*4.2. Creando la variable para identidad
	recode s430c (0 8 = 0) (1 2 = 1), gen(identidad)
	label define identidad 0 "No tiene o no sabe" 1 "Sí tiene"
	label values identidad identidad 

	*4.3. Tablas

	*	Esquema anterior
	foreach v of varlist lenguamat v190 v106 sregion v025 {
	tab `v' identidad [iw=factor] if b5==1 & bedad<60 & bedad>5 , row 
	}

	*2015
	
	use "$base2\rec94_2015.dta", clear
	
	rename 		 idx94 bord

	merge 		1:1 caseid bord using "$base2/rec21_2015.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	rename 		bord hidx

	merge 		m:1 caseid using "$base2/rec91_2015.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	rename 		hidx idx95

	merge 		1:1 caseid idx95 using "$base2/rec95_2015.dta"
	tab 		_merge
	keep 		if _merge==3
	drop 		_merge
	
	gen hhid=substr(caseid,1,15)
	
	merge 		m:1 hhid using "$base2/rech0_2015.dta", keepusing(hv005* hv025)

	gen 		factor=hv005x/1000000

	save "$temp2\identidad_2015.dta", replace

	
	*4.1. Creando las variables para cortes

	use "$temp2\identidad_2015.dta", clear

	*Lengua materna
	gen lenguamat=s119
	recode lenguamat (1=1) (2/4=2) (5=3)
	label define lenguamat 1 "Castellano" 2 "Lengua nativa" 3 "Extranjera"
	label values lenguamat lenguamat

	*Región natural
	label define sregion  1 "Lima Metropolitana" 2 "Resto Costa" ///
	3 "Sierra" 4 "Selva"
	label values sregion sregion

	*Área
	label define hv025  1 "Urbano" 2 "Rural" 
	label values hv025 hv025


	*4.2. Creando la variable para identidad
	recode s430c (0 8 = 0) (1 2 = 1), gen(identidad)
	label define identidad 0 "No tiene o no sabe" 1 "Sí tiene"
	label values identidad identidad 

	*4.3. Tablas

	*	Esquema anterior
	foreach v of varlist lenguamat sregion hv025 {
	tab `v' identidad [iw=factor] if b5==1 & q478<60 & q478>5 , row 
	}
	}

	
	
	
	
	
	
	
	