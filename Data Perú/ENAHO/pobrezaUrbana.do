/*******************************************************************************
Objetivo: Análisis de la pobreza y vulnerabilidad urbana
Autores:  CN


Estructura:
	0. Direcciones
    1. Base a nivel de hogares
    2. Base a nivel de personas
		
*******************************************************************************/

*	0. Direcciones

	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data\Anual"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
*	1. Base a nivel de hogares
{
	use "$temp\modulo100.dta", clear

	merge 1:1 anio conglome vivienda hogar using "$temp\sumaria.dta", keepusing(ipc* gpc* gpg* percepho mieperho pobre* quintil* decil*)
	keep if _m==3
	drop _merge

	gen area = estrato <6
	label values area area
	
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7 "Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
	*/12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" /*
	*/23"Tacna" 24"Tumbes" 25"Ucayali" 26 "Lima Provincias"
	lab val dpto dpto 
	
	rename (p1141 p1142 p1143 p1144 p1145) (fijo celu tv internet ninguno)
	
	*Generando variables de acceso
	gen agua=cond(p110==1 | p110==2,1,cond(p110==.,.,0))
	gen desague=cond(p111a==1 | p111a==2,1,cond(p111a==.,.,0))
	gen electricidad=cond(p1121==1,1,cond(p1121==.,.,0))
	
	gen servicios=cond(agua==1 & desague==1 & electricidad==1,1,cond(agua==. & desague==. & electricidad==.,.,0))
	
	gen agua_dentro=cond(p110==1 ,1,cond(p110==.,.,0))

	* Porcentaje de horas semanales con acceso a agua
	gen horas_agua = p110c1 if agua == 1 & p110c == 1
	replace horas_agua = p110c2*p110c3/7 if agua == 1 & p110c == 2
	replace horas_agua = . if p110==. | agua ==. | p110c1 ==.
	replace horas_agua = horas_agua /24
	
	gen agua_segura = 1 if p110a == 1
	replace agua_segura = 0 if p110a != 1
	replace agua_segura = . if p110a == .
	
	preserve
	use "$temp\modulo300.dta", clear
	keep if p203 == 1
	gen educ_jefe = p301a
	gen leng_jefe = p300a
	gen sex_jefe = p207
	gen edad_jefe = p208a 
	gen estado_civil_jefe = p209
	keep anio conglome vivienda hogar educ_jefe leng_jefe sex_jefe edad_jefe estado_civil_jefe
	tempfile educ_jefe
	save `educ_jefe'
	restore
	
	merge 1:1 anio conglome vivienda hogar using "`educ_jefe'", keepusing(educ_jefe leng_jefe sex_jefe edad_jefe estado_civil_jefe)
	sort conglome vivienda hogar 
	keep if _m==3
	drop _merge
	
	recode leng_jefe (1 =3 ) (2=2) (3 10/15 = 4) (4 = 1) (5/7=5) (8/9 = 6), gen(lenguamat)
	label define lenguamat 3 "Quechua" 2 "Aymara" 4 "Otra lengua originaria" 1 "Castellano" 5 "Lengua extranjera" 6 "Lenguaje de señas o mudo"
	label val lenguamat lenguamat
	
	*Variable de educación del jefe de hogar (máximo nivel completado)
	recode educ_jefe (1/3=1) (4/5=2) (6 7 9 =3) (8 10 11 = 4)
	label define educ_jefe 1 "Sin nivel o inicial" 2 "Primaria completa" 3 "Secundaria completa" 4 "Educación superior"
	label val educ_jefe educ_jefe 
	
	preserve
	use "$temp\modulo500.dta", clear
	keep if p203 == 1
	gen inf_jefe = ocupinf
	gen r5=(p506r4/100)
	recode r5 (1/9.9 = 1) (10/47.99 = 2)  (nonmissing = 3)  , gen(sector_jefe)
	label define sector_jefe 1 "Sector primario" 2 "Sector secundario" 3 "Sector terciario"
	label values sector_jefe sector_jefe
	keep anio conglome vivienda hogar inf_jefe sector_jefe
	tempfile inf_jefe
	save `inf_jefe'
	restore
	
	merge 1:1 anio conglome vivienda hogar using "`inf_jefe'", keepusing(inf_jefe sector_jefe)
	sort conglome vivienda hogar 
	keep if _m==3
	drop _merge
	
	replace inf_jefe = 0 if inf_jefe==2
	replace sex_jefe = 0 if sex_jefe==2
	
	recode altitud (0/500 = 1) (501/2300 = 2) (2301/3500 = 3) (3501/4000 = 4) (4001/4800 = 5) (4801/6768 = 6) , gen(reg_natural)
	replace reg_natural = 7 if altitud > 400 & dominio == 7 & altitud <= 1000
	replace reg_natural = 8 if altitud <= 400 & dominio == 7
	
	label define reg_natural 1 "Chala" 2 "Yunga" 3 "Quechua" 4 "Suni" 5 "Puna" 6 "Janca" 7 "Selva alta" 8 "Selva baja"
	label values reg_natural reg_natural
	
	gen vulnerable = (pobrezav == 3)
	replace vulnerable = . if pobrezav <3 | pobrezav ==.
	
	gen pobre = (pobrezav < 3)
	replace vulnerable = . if pobrezav ==.

	gen pct_perceptores = percepho/mieperho
	
	gen paredes = (p102 == 1)
	replace paredes =. if p102 ==.
	
	gen pisotierra = (p103 == 6)
	replace pisotierra =. if p103 ==.
	
	gen techo = (p103a == 1)
	replace techo =. if p103a ==.
}
**********************************************************************************************
*	2. Base a nivel de personas
{
	use "$temp\modulo200.dta", clear
	merge m:1 anio conglome vivienda hogar using "$temp\modulo100.dta", keepusing(nbi* fac*)
	drop if _m==2
	drop _m
	
	merge m:1 anio conglome vivienda hogar using "$temp\sumaria.dta", keepusing(quintil* decil* area fac*)
	drop if _m==2
	drop _m

	merge m:1 anio conglome vivienda hogar using "$bd\base_variables_pobreza_vulnerabilidad-2007-2022.dta", keepusing(pobre* fac*)
	drop if _m==2
	drop _m

	merge 1:1 anio conglome vivienda hogar codperso using "$temp\modulo300.dta", keepusing(p300a fac*)
	drop if _m==2
	drop _m
	
	merge 1:1 anio conglome vivienda hogar codperso using "$temp\modulo500.dta", keepusing(p558* fac* ocu*)
	drop if _m==2
	drop _m
	
	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (nonmissing=4), gen(grupo_edad)
	label define grupo_edad 1 "0-5 anios" 2 "6-11 anios" 3 "12-17 anios" 4 "18 a más"
	label val grupo_edad grupo_edad

	*Pobreza
	gen pobre_extremo=cond(pobreza==1,1,cond(pobreza==.,.,0))
	gen pobre=cond(pobreza==1 | pobreza==2,1,cond(pobreza==.,.,0))
	
	
	replace estrato = 1 if dominio ==8 
	gen area2 = estrato <7
	replace area2=2 if area==0
	label define area2 2 rural 1 urbana
	label val area2 area2
	
	recode p300a (1=1) (2=2) (3=3) (4 =4) (nonmissing =.), gen(lenguamat)
	label define lenguamat 1 "Quechua" 2 "Aymara" 3 "Lenguas Amazónicas" 4 "Castellano"
	label val lenguamat lenguamat
	
	gen ocupada = cond(ocu500==1,1,0)
	gen pea= cond(ocu500<3 & ocu500!=0,1,cond(ocu500==.,.,0))
	gen desempleo = pea - ocupada
	
	svyset [pweight = factor07], psu(conglome)strata(estrato)
	
	table area pobrezav anio if filtro==1 & anio >= 2011 [iw=facpob07], nototals	
	
	table area pobrezav anio if filtro==1 & anio >=2012 [iw = fac500a], stat(mean ocupada) nototals
	table area pobrezav anio if filtro==1 & anio >=2012 [iw = fac500a], stat(mean desempleo) nototals
	
}
**********************************************************************************************
*	3. Estimaciones
{	
	quietly: logit pobre altitud agua_dentro horas_agua internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo i.reg_natural i.lenguamat i.educ_jefe i.sector_jefe  if dpto==1 & anio>=2010 

	margins , dyex(altitud horas_agua)
	margins , dydx(agua_dentro  internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo)

	quietly: logit pobre altitud agua_dentro horas_agua internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo i.reg_natural i.lenguamat i.educ_jefe i.sector_jefe  if estrato==1 & anio>2020

	margins , dyex(altitud horas_agua)
	margins , dydx(agua_dentro  internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo)
}