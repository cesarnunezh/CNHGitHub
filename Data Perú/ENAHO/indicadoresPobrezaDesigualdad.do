/*******************************************************************************
Objetivo: Cálculo de indicadores de pobreza 2007-2022
Autores:  CN

Estructura:
	0. Direcciones
    1. Pobreza y pobreza extrema monetaria
    2. Pobreza NBI
    3. Pobreza multidimensional
	4. Vulnerabilidad económica
	5. Coeficiente de Gini
		
*******************************************************************************/

* 0. Direcciones

	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data\Anual"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
*	1. Pobreza y pobreza extrema monetaria
{
	use "$temp\modulo200.dta", clear
	merge m:1 año conglome vivienda hogar using "$temp\modulo100.dta", keepusing(nbi* fac*)
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(pobreza pobrezav area fac*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo300.dta", keepusing(p300a fac*)
	drop if _m==2
	drop _m

	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (nonmissing=4), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18 a más"
	label val grupo_edad grupo_edad

	*Pobreza
	gen pobre_extremo=cond(pobreza==1,100,cond(pobreza==.,.,0))
	gen pobre=cond(pobreza==1 | pobreza==2,100,cond(pobreza==.,.,0))
	
	
	replace estrato = 1 if dominio ==8 
	gen area2 = estrato <7
	replace area2=2 if area==0
	label define area2 2 rural 1 urbana
	label val area2 area2
	
	recode p300a (1=1) (2=2) (3=3) (4 =4) (nonmissing =.), gen(lenguamat)
	label define lenguamat 1 "Quechua" 2 "Aymara" 3 "Lenguas Amazónicas" 4 "Castellano"
	label val lenguamat lenguamat

	*Tabla general
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(año)  
	gen nac="Nacional"
	reshape wide pobre pobre_extremo, i(nac) j(año)
	order nac pobre2* pobre_* 
	export excel using "$output/datos", sheet("pobreza") sheetreplace firstrow(variables) 
	restore

	*Por área de residencia
	preserve
	keep if grupo_edad<=3
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(area año)  
	reshape wide pobre pobre_extremo, i(area) j(año)
	order area pobre2* pobre_* 
	export excel using "$output/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A5)
	restore

	*Por departamento
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(dpto año)  
	reshape wide pobre pobre_extremo, i(dpto) j(año)
	order dpto pobre2* pobre_* 
	export excel using "$output/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A13)
	restore
	
	*Por grupo de edad
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(grupo_edad año)  
	reshape wide pobre pobre_extremo, i(grupo_edad) j(año)
	order grupo_edad pobre2* pobre_* 
	export excel using "$output/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A66)
	restore

	*Por lengua materna
	preserve
	keep if grupo_edad<=3
	recode p300a (5 6 = 7) (9 = 8)
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(p300a año)  
	label define p300a 9 "lengua de señas peruanas" ,modify
	drop if p300a==.
	reshape wide pobre pobre_extremo, i(p300a) j(año)
	order p300a pobre2* pobre_* 
	export excel using "$output/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A80)
	restore
}
**********************************************************************************************
*	2. Pobreza NBI	
{
	*Población con al menos una necesidad básica insatisfecha
	gen nbi_= cond(nbi1==1 | nbi2==1 | nbi3==1 | nbi4==1 | nbi5==1,1, cond(nbi1==. | nbi2==. | nbi3==. | nbi4==. | nbi5==.,.,0))
	preserve
	collapse (mean) nbi_ nbi1 nbi2 nbi3 nbi4 nbi5 if filtro==1 [iw=facpob07], by(año)  
	gen nac="Nacional"
	reshape wide nbi_ nbi1 nbi2 nbi3 nbi4 nbi5, i(nac) j(año)
	order nac nbi_* nbi1* nbi2* nbi3* nbi4* nbi5*
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A90)
	restore

   	*Población con al menos una nbi por área de residencia
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by( area año)  
	reshape wide nbi_, i(area) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A100)
	restore
 
   	*Población con al menos una nbi por departamento
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by( dpto año)  
	reshape wide nbi_, i(dpto) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A108)
	restore

   	*Población con al menos una nbi por departamento
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by(grupo_edad año)  
	reshape wide nbi_, i(grupo_edad) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A137)
	restore
}
**********************************************************************************************
*	3. Pobreza multidimensional - ENAHO
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
*	4. Vulnerabilidad económica
{
	use "$temp\modulo200.dta", clear
	merge m:1 año conglome vivienda hogar using "$temp\modulo100.dta", keepusing(nbi* fac*)
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(pobreza pobrezav lineav area fac*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo300.dta", keepusing(p300a fac*)
	drop if _m==2
	drop _m

	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (nonmissing=4), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18 a más"
	label val grupo_edad grupo_edad

	*Pobreza
	gen pobre_extremo=cond(pobreza==1,100,cond(pobreza==.,.,0))
	gen pobre=cond(pobreza==1 | pobreza==2,100,cond(pobreza==.,.,0))
	
	
	replace estrato = 1 if dominio ==8 
	gen area2 = estrato <7
	replace area2=2 if area==0
	label define area2 2 rural 1 urbana
	label val area2 area2
	
	recode p300a (1=1) (2=2) (3=3) (4 =4) (nonmissing =.), gen(lenguamat)
	label define lenguamat 1 "Quechua" 2 "Aymara" 3 "Lenguas Amazónicas" 4 "Castellano"
	label val lenguamat lenguamat
	
	svyset [pweight = factor07], psu(conglome)strata(estrato)
	
	svy: total pobre if filtro==1, over(año area)
	matrix define results = e(b)
	matlist results, format(%12.0fc)

	gen vulnerable = (pobrezav == 3)
	svy: total vulnerable if filtro==1, over(año area)
	matrix define results = e(b)
	matlist results, format(%12.0fc)
	
}
**********************************************************************************************
*	5. Coeficiente de gini
{
	use "$temp\sumaria.dta", clear

	forval			i=2007/2019 {
	capture 		noisily ginidesc ipcr_0 [aw=factornd07] if año==`i'
	nobreak
	}

	*Coeficiente de gini por ingresos y gastos 2007-2019
	ginidesc ipcr_0 [aw=factornd07], by(año) m(ing1) gk(ing2)
	ginidesc gpgru0 [aw=factornd07], by(año) m(gas1) gk(gas2)

	putexcel set "$out1/datos.xls", sheet("Coef. gini") modify
	putexcel A1=matrix(gas2), names
	putexcel A20=matrix(ing2), names
	}
**********************************************************************************************
