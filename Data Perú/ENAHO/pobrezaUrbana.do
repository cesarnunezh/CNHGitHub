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

	merge 1:1 año conglome vivienda hogar using "$bd\base_variables_pobreza_vulnerabilidad-2007-2022.dta", keepusing( pobrezav)
	keep if _m==3
	drop _merge

	merge 1:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(ipc* gpc* gpg* percepho mieperho)
	keep if _m==3
	drop _merge

	gen area = estrato <6
	label values area area
	
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label values dpto dpto
	
	rename (p1141 p1142 p1143 p1144 p1145) (fijo celu tv internet ninguno)
	
	*Generando variables de acceso
	gen agua=cond(p110==1 | p110==2,1,cond(p110==.,.,0))
	gen desague=cond(p111a==1 | p111a==2,1,cond(p111a==.,.,0))
	gen electricidad=cond(p1121==1,1,cond(p1121==.,.,0))
	
	gen servicios=cond(agua==1 & desague==1 & electricidad==1,1,cond(agua==. & desague==. & electricidad==.,.,0))
	
	gen agua_dentro=cond(p110==1 ,1,cond(p110==.,.,0))

	gen acc_agua_24 = 1 if agua == 1 & p110c1 == 24
	replace acc_agua_24 = 0 if acc_agua_24==.
	replace acc_agua_24 = . if p110==.

	preserve
	use "$temp\modulo300.dta", clear
	keep if p203 == 1
	gen educ_jefe = p301a
	gen leng_jefe = p300a
	gen sex_jefe = p207
	gen edad_jefe = p208a 
	gen estado_civil_jefe = p209
	keep año conglome vivienda hogar educ_jefe leng_jefe sex_jefe edad_jefe estado_civil_jefe
	tempfile educ_jefe
	save `educ_jefe'
	restore
	
	merge 1:1 año conglome vivienda hogar using "`educ_jefe'", keepusing(educ_jefe leng_jefe sex_jefe edad_jefe estado_civil_jefe)
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
	keep año conglome vivienda hogar inf_jefe sector_jefe
	tempfile inf_jefe
	save `inf_jefe'
	restore
	
	merge 1:1 año conglome vivienda hogar using "`inf_jefe'", keepusing(inf_jefe sector_jefe)
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
	
	gen pct_perceptores = percepho/mieperho
	
	gen paredes = (p102 == 1)
	replace paredes =. if p102 ==.
	
	gen pisotierra = (p103 == 6)
	replace pisotierra =. if p103 ==.
	
	gen techo = (p103a == 1)
	replace techo =. if p103a ==.
}

probit vulnerable altitud agua_dentro acc_agua_24 internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes piso techo i.reg_natural i.lenguamat i.educ_jefe i.sector_jefe  if area==1 & año>=2010 & año <2013

logit vulnerable altitud agua_dentro acc_agua_24 internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo i.reg_natural i.lenguamat i.educ_jefe i.sector_jefe  if area==1 & año>=2020

margins , dyex(altitud)
margins , dydx(agua_dentro acc_agua_24 internet pct_perceptores desague sex_jefe inf_jefe nbi2 paredes pisotierra techo)
