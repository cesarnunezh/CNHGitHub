global up "C:\Users\oniquen\Desktop\Para Eliana\Bases"

/*******************************************************************************
					CREACIÓN DE LA VARIABLE SUBEMPLEO
*******************************************************************************/

*Trabajando con base 500
use "$up\enaho01a-2018-500.dta", clear

sort conglome vivienda hogar codperso

*CÁLCULO DE LA CONDICIÓN DE ACTIVIDAD
*------------------------------------

	#delimit ;
	recode ocu500
	(1=1 "Ocupado")
	(2=2 "Desocupado")
	(3/4=3 "Inactivo"), g(r3) ;
	#delimit cr

	lab var r3 "Condición de actividad"
	drop if r3==0

*CÁLCULO DEL INGRESO (R6)
*-------------------------

	* correcciones a las opre
	replace d529t=. if d529t==999999
	replace d536=. if d536==999999
	replace d540t=. if d540t==999999
	replace d543=. if d543==999999
	replace d544t=. if d544t==999999

	* calculando los recodes
	egen r6prin=rsum(i524a1 d529t i530a d536) if r3==1
	egen r6sec =rsum(i538a1 d540t i541a d543) if r3==1
	gen r6ext=d544t
	egen r6=rsum(r6prin r6sec r6ext) if r3==1
	replace r6=r6/12
	replace r6prin=r6prin/12
	replace r6sec=r6sec/12
	lab var r6 "Ingreso laboral mensual (ocup. princ. y secun.)" 
	lab var r6prin "Ingreso laboral mensual (ocup. princ.)"
	lab var r6sec "Ingreso laboral mensual (ocup. secundaria)"
	lab var r6ext "Ingreso no laboral"

*Primer save de la base 500 con ingresos y condición de actividad
	save "$up\enaho01a-2018-500.dta", replace

*CÁLCULO DE PERSONAS QUE PERCIBEN INGRESOS EN EL HOGAR
*------------------------------------------------------

	gen perchogar500=1 if r6>0 & r6!=. & p203!=8 & p203!=9
	replace perchogar500=0 if  perchogar500==.
	collapse (sum) perchogar500,by(conglome vivienda hogar)

	save "$up\mod500_hogares.dta", replace

	*Trabajando con sumaria
	use "$up\sumaria-2018.dta", clear
	sort conglome vivienda hogar
	merge 1:1 conglome vivienda hogar using "$up\mod500_hogares.dta"
	replace perchogar500=0 if perchogar500==.
	drop _merge

	gen peso=factor07*mieperho

	gen domgeo=1 if (estrato>=1 & estrato<=5) & (dominio>=1 & dominio<=3)
	replace domgeo=2 if (estrato>=6 & estrato<=8) & (dominio>=1 & dominio<=3)
	replace domgeo=3 if (estrato>=1 & estrato<=5) & (dominio>=4 & dominio<=6)
	replace domgeo=4 if (estrato>=6 & estrato<=8) & (dominio>=4 & dominio<=6)
	replace domgeo=5 if (estrato>=1 & estrato<=5) & (dominio==7)
	replace domgeo=6 if (estrato>=6 & estrato<=8) & (dominio==7)
	replace domgeo=7 if (dominio==8)

	label var domgeo "Dominio geográfico"

	label define domgeo /*
	*/ 1 "Costa urbana" /*
	*/ 2 "Costa rural" /*
	*/ 3 "Sierra urbana" /*
	*/ 4 "Sierra rural" /*
	*/ 5 "Selva urbana" /*
	*/ 6 "Selva rural" /*
	*/ 7 "Lima Metropolitana"

	label values domgeo domgeo

	collapse (mean) linea mieperho perchogar500 [pw=peso], by(domgeo)

*CÁLCULO DEL INGRESO MÍNIMO REFERENCIAL (IMR)
*---------------------------------------------
	gen imr=(linea*mieperho)/perchogar500

	label var imr "Ingreso Mínimo Referencial"

	keep domgeo imr

	sort domgeo

	save "$up\imr.dta", replace

*UNIENDO IMR EN LA BASE DE EMPLEO (MÓDULO 500)
*---------------------------------------------
	use "$up\enaho01a-2018-500.dta", clear

	gen domgeo=1 if (estrato>=1 & estrato<=5) & (dominio>=1 & dominio<=3)
	replace domgeo=2 if (estrato>=6 & estrato<=8) & (dominio>=1 & dominio<=3)
	replace domgeo=3 if (estrato>=1 & estrato<=5) & (dominio>=4 & dominio<=6)
	replace domgeo=4 if (estrato>=6 & estrato<=8) & (dominio>=4 & dominio<=6)
	replace domgeo=5 if (estrato>=1 & estrato<=5) & (dominio==7)
	replace domgeo=6 if (estrato>=6 & estrato<=8) & (dominio==7)
	replace domgeo=7 if (dominio==8)

	label var domgeo "Dominio geográfico"

	label define domgeo /*
	*/ 1 "Costa urbana" /*
	*/ 2 "Costa rural" /*
	*/ 3 "Sierra urbana" /*
	*/ 4 "Sierra rural" /*
	*/ 5 "Selva urbana" /*
	*/ 6 "Selva rural" /*
	*/ 7 "Lima Metropolitana"

	label values domgeo domgeo

	sort domgeo
	merge m:1 domgeo using "imr.dta"
	drop _merge

	sort conglome vivienda hogar codperso

*CÁLCULO DEL RANGO DE HORAS TRABAJADAS A LA SEMANA
*--------------------------------------------------

	egen    r11 = rsum(i513t i518) if (r3==1 & p519==1)
	replace r11 = i520 if (r3==1 & p519==2)
	replace r11 = . if r3~=1
	lab var r11 "Horas normales semanales (ocup. princ. y ocup. secun.)"

	#delimit ;
	recode r11 
	(min/14=1 "Menos de 15 hrs") 
	(15/34.49=2 "15 a 34 hrs") 
	(34.5/47.49=3 "35 a 47 hrs") 
	(47.5/48.49=4 "48 hrs") 
	(48.5/59.59=5 "49 a 59 hrs") 
	(60/max=6 "60 a más hrs")
	(.=8 "No ocupado"), gen (r11r) ;
	#delimit cr
	lab var r11r "Rango de horas normales semanales (ocup. princ. y ocup. secun.)"

*CÁLCULO DE LOS NIVELES DE EMPLEO
*--------------------------------------------------

	gen r13=.
	replace r13=1 if (r3==2 & p552==1)
	replace r13=2 if (r3==2 & p552==2)
	replace r13=3 if (r3==1 & r11r>=1 & r11r<=2 & p521==1 & p521a==1)
	replace r13=4 if (r3==1 & r6<imr & r11r>=3 & r11r<=6)
	replace r13=4 if (r3==1 & r6<imr & r11r>=1 & r11r<=2 & p521==1 & p521a==2)
	replace r13=4 if (r3==1 & r6<imr & r11r>=1 & r11r<=2 & p521==2)
	replace r13=5 if (r3==1 & r6>=imr & r11r>=3 & r11r<=6)
	replace r13=5 if (r3==1 & r6>=imr & r11r>=1 & r11r<=2 & p521==1 & p521a==2)
	replace r13=5 if (r3==1 & r6>=imr & r11r>=1 & r11r<=2 & p521==2)
	replace r13=3 if (r3==1 & r6<imr  & r11r>=1 & r11r<=2 & p521==.)
	replace r13=5 if (r3==1 & r6>=imr & r11r>=1 & r11r<=2 & p521==.)
	replace r13=4 if (r3==1 & r6<imr & r11r>=1 & r11r<=2 & p521==1 & p521a==.)
	replace r13=3 if (r3==1 & r6>=imr & r11r>=1 & r11r<=2 & p521==1 & p521a==.)
	replace r13=7 if (r3==3)

	label var r13 "Niveles de Empleo" 

	label define r13 1 "Desempleo cesante" 2 "Desempleo aspirante" 3 "Subempleo por horas" 4 "Subempleo por ingresos" 5 "Empleo adecuado" /* 
*/ 6 "No especificado" 7 "Inactivo"

label values r13 r13 
	
*CÁLCULOS CON FILTRO DE RESIDENTES HABITUALES DEL HOGAR
*--------------------------------------------------------
qui svyset conglome [pweight=fac500a], strata(estrato) vce(linearized) singleunit(missing)
svy, subpop(if (p204==1&p205==2)|(p204==2&p206==1)):tab r13, count format(%12,0f)
