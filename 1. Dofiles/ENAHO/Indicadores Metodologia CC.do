/*******************************************************************************
Proyecto: UNICEF - Niñas, niños y adolescentes
Objetivo: Vulnerabilidades ante emergencias y desastres	
Autores:  DR - CN

Objetivo: 	Análisis de regresión (correlación) entre las variables de vulnerabilidad
			de las niñas, niños y adolescentes y la ocurrencia de los eventos priorizados.

Estructura:
	0. Direcciones
    1. Indicadores Enaho
	2. Ratio de dependencia
		
*******************************************************************************/
*	0. Direcciones

global base1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENAHO"
global base2 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\3. Entregables\3. Informe preliminar SITAN\1. Metodología de Cambio Climático\_old"
global out1 "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\2. Output Stata"
global temp "G:\.shortcut-targets-by-id\12iEHNJMWHBwqYCJyyBRAxdzil1-0PrOd\UNICEF - VIDENZA\2. Datos\1. Bases de datos\ENAHO\Temp"

*******************************************************************************/
*	1. Indicadores Enaho

	use "$temp\modulo200.dta", clear

	merge m:1 año conglome vivienda hogar using "$temp\modulo100.dta", keepusing(p110 p111a p1121 fac*)
	drop if _merge==2
	drop _merge

	tostring ubigeo, replace
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(quintil_i quintil_g fac* pobre* area)
	drop if _merge==2
	drop _merge
	
	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo500.dta", keepusing(ocu500 ocupinf fac500a)
	drop if _merge==2
	drop _merge

	gen dpto= real(substr(ubigeo,1,2))
	label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7 "Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
	*/12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" /*
	*/23"Tacna" 24"Tumbes" 25"Ucayali" , modify
	lab val dpto dpto 
	
	*Generando variables de acceso
	gen agua=cond(p110==1 | p110==2,100,cond(p110==.,.,0))
	gen desague=cond(p111a==1 | p111a==2,100,cond(p111a==.,.,0))
	gen electricidad=cond(p1121==1,100,cond(p1121==.,.,0))
	gen servicios=cond(agua==100 & desague==100 & electricidad==100,100,cond(agua==. & desague==. & electricidad==.,.,0))
	
	*Variable de filtro de residencia
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	*Variables de edad
	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	gen menores_5años=(grupo_edad==1)*100
	gen nna=(grupo_edad<=3)*100
	
	*Variable de ingresos
	gen nna_quintil_i=(grupo_edad<=3 & quintil_i<3)*100
	replace nna_quintil_i=. if grupo_edad>3
	
	*Desempleo en mujeres
	gen pea= cond(ocu500<3 & ocu500!=0,1,cond(ocu500==.,.,0))
	
	gen desempleo_mujeres=(p207==2 & ocu500==2)*100
	replace desempleo_mujeres=. if p207==1
	replace desempleo_mujeres=. if p207==2 & p208a<14
	replace desempleo_mujeres=. if pea==0
	
	*Variables de area de residencia
	gen nna_rural=(grupo_edad<=3 & area==2)*100
	replace nna_rural=. if grupo_edad>3
	
	preserve
	collapse (mean) agua desague electricidad servicios nna_quintil_i nna_rural if filtro==1 & grupo_edad<=3 [iw=facpob07], by(año dpto)
	tempfile variables_1
	save `variables_1'
	restore	

	preserve
	collapse (mean) desempleo_mujeres if filtro==1 [iw=fac500a], by(año dpto)
	tempfile variables_2
	save `variables_2'
	restore	

	preserve
	collapse (mean) menores_5años nna if filtro==1  [iw=facpob07], by(año dpto)
	tempfile variables_4
	save `variables_4'
	restore	

	*Informalidad
	preserve
	gen menor_edad=cond(p208a==.,.,cond(p208a<18,1,0))
	
	*Variable de educación del jefe de hogar (máximo nivel completado)
	gen informal=ocupinf if p203==1 
	replace informal=0 if informal==2
	
	bys año conglome vivienda hogar: egen informal2=max(informal)

	collapse (sum) menor_edad (mean) informal2 , by(año dpto conglome vivienda hogar factor07)
	keep if menor_edad>0
	collapse (mean) informal2 [iw=factor07], by(año dpto)
	replace informal2=informal2*100
	
	tempfile variables_3
	save `variables_3'
	restore	
	
	use "`variables_1'", clear
	
	merge 1:1 año dpto using "`variables_2'"
	tab _merge
	drop _merge

	merge 1:1 año dpto using "`variables_3'"
	tab _merge
	drop _merge

	merge 1:1 año dpto using "`variables_4'"
	tab _merge
	drop _merge

	preserve
	import excel "$base2\base indeci_stata.xlsx", sheet("base_indeci") firstrow clear
	tempfile base_indeci
	save `base_indeci'
	restore

	merge m:1 dpto using "`base_indeci'"
	tab _merge
	drop _merge

	preserve
	import excel "$base2\0. Vulnerabilidades.xlsx", sheet("base") firstrow clear
	tempfile vulnerabilidades
	save `vulnerabilidades'
	restore
	
	merge m:1 dpto using "`vulnerabilidades'"
	tab _merge
	drop _merge
	
	save "$base2\base_vulnerabilidad.dta", replace

	use "$base2\base_vulnerabilidad.dta", clear

drop if año<2014 | año>2018


*	1.		LLUVIAS INTENSAS
***************************************************
{	
	
global 	variables 		nna_agua_rio agua desague nna_altura menores_5años nna
	
*ocurrencias
	pwcorr lluvia_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr lluvia_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr lluvia_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr lluvia_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr lluvia_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr lluvia_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr lluvia_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr lluvia_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr lluvia_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr lluvia_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Lluvia) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}	
}

*	2.		BAJAS TEMPERATURAS
***************************************************
{	
global 	variables 		nna nna_quintil_i menores_5años 
	
*ocurrencias
	pwcorr bajas_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr bajas_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr bajas_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr bajas_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr bajas_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr bajas_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr bajas_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr bajas_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr bajas_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr bajas_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Temperatura) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}	
}

*	3.		SISMOS
***************************************************
{	
global 	variables 		desempleo_mujeres agua nna_rural menores_5años nna victimizacion
	
*ocurrencias
	pwcorr sismo_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr sismo_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr sismo_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr sismo_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr sismo_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr sismo_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr sismo_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr sismo_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr sismo_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr sismo_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Sismo) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}	
	
	
}	

*	4.		HUAYCO
***************************************************
{	
global 	variables 		nna_agua_rio agua desague menores_5años nna
	
*ocurrencias
	pwcorr huayco_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr huayco_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr huayco_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr huayco_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr huayco_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr huayco_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr huayco_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr huayco_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr huayco_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr huayco_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Huayco) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}	
}

*	5.		EPIDEMIA
***************************************************
{	
global 	variables 		informal2 nna_madrefuma nna_covid menores_5años nna 
	
*ocurrencias
	pwcorr epidemias_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr epidemias_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr epidemias_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr epidemias_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr epidemias_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr epidemias_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr epidemias_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr epidemias_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr epidemias_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr epidemias_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Epidemia) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}		
}	


*	6.		INCENDIOS
***************************************************
{	
global 	variables 		nna_respira menores_5años nna
	
*ocurrencias
	pwcorr incend_14_18 $variables , sig	
	mat A1=r(C)
	mat B1=r(sig)
		
*personas
	pwcorr incend_14_18_fallecidos $variables , sig	
	mat A2=r(C)
	mat B2=r(sig)
	pwcorr incend_14_18_damnificados $variables , sig	
	mat A3=r(C)
	mat B3=r(sig)
	pwcorr incend_14_18_afectados $variables , sig	
	mat A4=r(C)
	mat B4=r(sig)
	
*estructuras
	pwcorr incend_14_18_viv_dest $variables , sig
	mat A5=r(C)
	mat B5=r(sig)
	pwcorr incend_14_18_viv_afec $variables , sig
	mat A6=r(C)
	mat B6=r(sig)
	pwcorr incend_14_18_iiee_dest $variables  , sig	
	mat A7=r(C)
	mat B7=r(sig)
	pwcorr incend_14_18_iiee_afec $variables  , sig
	mat A8=r(C)
	mat B8=r(sig)
	pwcorr incend_14_18_ccss_dest $variables  , sig	
	mat A9=r(C)
	mat B9=r(sig)
	pwcorr incend_14_18_ccss_afec $variables  , sig	
	mat A10=r(C)
	mat B10=r(sig)	
	
global i=2

forv x=1/10 {
	putexcel set "$base2\Matrices.xlsx", sheet(Incendio) modify 
	putexcel A$i = matrix(A`x') , names
	putexcel I$i = matrix(B`x') , names	
	global i=$i + rowsof(A`x') +1
}		
}	
	