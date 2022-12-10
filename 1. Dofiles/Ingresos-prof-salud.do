
/*********************************************************************
Ingresos profesionales de la salud
***********************************************************************/

clear all
set more off

global a "G:\Mi unidad\CPC 2019 (carpeta ordenada)\7. Bibliografía y data\ENAHO"
global b "G:\Mi unidad\CPC 2019 (carpeta ordenada)\2. Factores (mesas CPC)\8. Salud\Data\Enaho"

*********************************************************
********************* 2018 ******************************

use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace


**************
use "$a\Modulos empleo (500)\enaho01a-2018-500.dta", clear
keep nconglome - fac500a
gen ao=2016
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239


//230	PROFESIONALES DE LAS CIENCIAS BIOLOGICAS, LA MEDICINA Y LA S
//231	BACTERIOLOGOS, BIOLOGOS, BOTANICOS, ZOOLOGOS Y AFINES
//232	FARMACOLOGOS Y PATOLOGOS
//233	DIETISTAS-NUTRICIONISTAS
//234	AGRONOMOS Y AFINES
//235	MEDICOS Y PROFESIONALES AFINES (EXCEPTO EL PERSONAL DE ENFER
//236	ODONTOLOGO (CIRUJANOS)
//237	VETERINARIO
//238	FARMACEUTICO
//239	PERSONAL DE ENFERMERIA DE NIVEL SUPERIOR (DIPLOMADOS)

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5 
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12

gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2018.dta", replace

*********************************************************
********************* 2017 ******************************

use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace


**************
use "$a\Modulos empleo (500)\enaho01a-2017-500.dta", clear
keep nconglome - fac500a
gen ao=2016
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239


//230	PROFESIONALES DE LAS CIENCIAS BIOLOGICAS, LA MEDICINA Y LA S
//231	BACTERIOLOGOS, BIOLOGOS, BOTANICOS, ZOOLOGOS Y AFINES
//232	FARMACOLOGOS Y PATOLOGOS
//233	DIETISTAS-NUTRICIONISTAS
//234	AGRONOMOS Y AFINES
//235	MEDICOS Y PROFESIONALES AFINES (EXCEPTO EL PERSONAL DE ENFER
//236	ODONTOLOGO (CIRUJANOS)
//237	VETERINARIO
//238	FARMACEUTICO
//239	PERSONAL DE ENFERMERIA DE NIVEL SUPERIOR (DIPLOMADOS)

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5 
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12

gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2017.dta", replace

*********************************************************
********************* 2016 ******************************

use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace


**************
use "$a\Modulos empleo (500)\enaho01a-2016-500.dta", clear
keep nconglome - fac500a
gen ao=2016
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239


//230	PROFESIONALES DE LAS CIENCIAS BIOLOGICAS, LA MEDICINA Y LA S
//231	BACTERIOLOGOS, BIOLOGOS, BOTANICOS, ZOOLOGOS Y AFINES
//232	FARMACOLOGOS Y PATOLOGOS
//233	DIETISTAS-NUTRICIONISTAS
//234	AGRONOMOS Y AFINES
//235	MEDICOS Y PROFESIONALES AFINES (EXCEPTO EL PERSONAL DE ENFER
//236	ODONTOLOGO (CIRUJANOS)
//237	VETERINARIO
//238	FARMACEUTICO
//239	PERSONAL DE ENFERMERIA DE NIVEL SUPERIOR (DIPLOMADOS)

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5 
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12

gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2016.dta", replace

*********************************
******* 2015 ********************
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

*********************************

use "$a\Modulos empleo (500)\enaho01a-2015-500.dta", clear

keep conglome - fac500a
gen ao=2015
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239

//230	PROFESIONALES DE LAS CIENCIAS BIOLOGICAS, LA MEDICINA Y LA S
//231	BACTERIOLOGOS, BIOLOGOS, BOTANICOS, ZOOLOGOS Y AFINES
//232	FARMACOLOGOS Y PATOLOGOS
//233	DIETISTAS-NUTRICIONISTAS
//234	AGRONOMOS Y AFINES
//235	MEDICOS Y PROFESIONALES AFINES (EXCEPTO EL PERSONAL DE ENFER
//236	ODONTOLOGO (CIRUJANOS)
//237	VETERINARIO
//238	FARMACEUTICO
//239	PERSONAL DE ENFERMERIA DE NIVEL SUPERIOR (DIPLOMADOS)

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5

gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
 save "$b\2015.dta", replace

 
 
 *********************************
******* 2014 ********************
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

*********************************

use "$a\Modulos empleo (500)\enaho01a-2014-500.dta", clear

keep conglome - fac500a
gen ao=2014
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239

//230	PROFESIONALES DE LAS CIENCIAS BIOLOGICAS, LA MEDICINA Y LA S
//231	BACTERIOLOGOS, BIOLOGOS, BOTANICOS, ZOOLOGOS Y AFINES
//232	FARMACOLOGOS Y PATOLOGOS
//233	DIETISTAS-NUTRICIONISTAS
//234	AGRONOMOS Y AFINES
//235	MEDICOS Y PROFESIONALES AFINES (EXCEPTO EL PERSONAL DE ENFER
//236	ODONTOLOGO (CIRUJANOS)
//237	VETERINARIO
//238	FARMACEUTICO
//239	PERSONAL DE ENFERMERIA DE NIVEL SUPERIOR (DIPLOMADOS)

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)


keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
 save "$b\2014.dta", replace

 
*********************************
******* 2013 **********
*********************************

use "$a\Modulos empleo (500)\enaho01a-2013-500.dta", clear

keep conglome - fac500a
gen ao=2013
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)


keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4


keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a

 save "$b\2013.dta", replace
 
 
*********************************
******* 2012 **********
*********************************

use "$a\Modulos empleo (500)\enaho01a-2012-500.dta", clear

keep conglome - fac500a
gen ao=2012
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
 save "$b\2012.dta", replace
 
 *********************************
******* 2011 **********
*********************************

use "$a\Modulos empleo (500)\enaho01a-2011-500.dta", clear

keep conglome - fac500a7
rename fac500a7 fac500a
gen ao=2011
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2011.dta", replace

 *********************************
******* 2010 **********
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

use "$a\Modulos empleo (500)\enaho01a-2010-500.dta", clear

keep conglome - fac500a
*rename fac500a7 fac500a
gen ao=2010
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2010.dta", replace


*********************************
******* 2009 **********
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

use "$a\Modulos empleo (500)\enaho01a-2009-500.dta", clear

keep conglome - fac500a
*rename fac500a7 fac500a
gen ao=2009
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2009.dta", replace

*********************************
******* 2008 **********
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

use "$a\Modulos empleo (500)\enaho01a-2008-500.dta", clear

keep conglome - fac500a
*rename fac500a7 fac500a
gen ao=2008
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2008.dta", replace

*********************************
******* 2007 **********
*********************************
use "$a\enaho-tabla-ciiu-rev4.dta", clear
drop if codrev4==""
save "$a\enaho-tabla-ciiu-rev4-2.dta", replace

use "$a\enaho-tabla-ciiu-rev3.dta",clear
drop if length(codrev3)!=4
save "$a\enaho-tabla-ciiu-rev3-2.dta", replace

use "$a\Modulos empleo (500)\enaho01a-2007-500.dta", clear

keep conglome - fac500a
*rename fac500a7 fac500a
gen ao=2007
order ao

gen area= estrato>=1 & estrato <=5 if estrato !=.
replace area=1 if substr(ubigeo,1,4)=="1501" & estrato==7
replace area=2 if (estrato>=6 & estrato<=8) & substr(ubigeo,1,4)!="1501" 
gen rural=area==2

gen lima=(substr(ubigeo,1,4)=="1501")

keep if p505==233 | p505==235 | p505==236 | p505==238 | p505==239 //verificar

tostring p506 p506r4, gen(codrev3 codrev4)
replace codrev3="0"+codrev3 if length(codrev3)==3
replace codrev4="0"+codrev4 if length(codrev4)==3
merge m:1 codrev3 using "$a\enaho-tabla-ciiu-rev3-2.dta"
drop if _merge==2
rename rnombre p506nombre
drop _merge

merge m:1 codrev4 using "$a\enaho-tabla-ciiu-rev4-2.dta"
drop if _merge==2
rename rnombre p506r4nombre
drop _merge
order p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre, after(p505b)
erase "$a\enaho-tabla-ciiu-rev4-2.dta" 
erase "$a\enaho-tabla-ciiu-rev3-2.dta"

keep if p506nombre=="CONSULTORIOS DE MEDICINA GENERAL" /*
*/ | p506nombre=="HOSPITALES GENERALES Y ESPECIALIZADOS"

drop if p507==5
gen publico=(p510==1 | p510==2 | p510==3)
drop if p510==1 //quitar FFAA y PNP
label var publico "trabaja en el sector publico"

// tiempo p513t p519

egen ing_mensual=rsum(i524a1 i530a) if i524a1!=. | i530!=.
replace ing_mensual=ing_mensual/12
gen horas_mensuales=i513t*4

keep ao area lima p505 p506 codrev3 p506nombre p506r4 codrev4 p506r4nombre p507 i513t publico p513t p519 i524a1 i530a ing_mensual horas_mensuales fac500a
save "$b\2007.dta", replace

 use "$b\2018.dta", clear
 append using "$b\2017.dta"
 append using "$b\2016.dta"
 append using "$b\2015.dta"
 append using "$b\2014.dta"
 append using "$b\2013.dta"
 append using "$b\2012.dta"
 append using "$b\2011.dta"
 append using "$b\2010.dta"
 append using "$b\2009.dta"
 append using "$b\2008.dta"
 append using "$b\2007.dta"
 
gen lima2="provincia"
replace lima2="lima" if lima==1

drop if ing_mensual==.

save "$b\base_ing_profsalud.dta", replace


 erase "$b\2018.dta"
 erase "$b\2017.dta"
 erase "$b\2016.dta"
 erase "$b\2015.dta"
 erase "$b\2014.dta"
 erase "$b\2013.dta"
 erase "$b\2012.dta"
 erase "$b\2011.dta"
 erase "$b\2010.dta"
 erase "$b\2009.dta"
 erase "$b\2008.dta"
 erase "$b\2007.dta"
 
 
 // SOLO DEPENDIENTES
* keep if p507==3 //

*keep if ao>=2014
 /*
preserve
 collapse (min) mining=ing_mensual (max) maxing=ing_mensual (p50) meding=ing_mensual (mean) i513t [pw=fac500a], by(p505 publico)
 sort publico p505
 list
 
restore

preserve
 collapse (min) mining=ing_mensual (max) maxing=ing_mensual (p50) meding=ing_mensual (mean) i513t [pw=fac500a], by(p505 publico lima2)
 reshape wide  mining maxing meding i513t, i (p505 lima2) j(publico)
 sort  lima2 p505
list
 
restore

mean ing_mensual [pw=fac500a] if publico==0,  over(p505)
mean ing_mensual [pw=fac500a] if publico==1,  over(p505)

mean ing_mensual [pw=fac500a] if publico==0 & lima2=="lima",  over(p505)
mean ing_mensual [pw=fac500a] if publico==1 & lima2=="lima",  over(p505)

mean ing_mensual [pw=fac500a] if publico==0 & lima2=="provincia",  over(p505)
mean ing_mensual [pw=fac500a] if publico==1 & lima2=="provincia",  over(p505)
*/



//  mas de 36, quitar 1 o 2% del nro obs max quitar dos obs, solo medicos y enfermeras, lima


use "$b\base_ing_profsalud.dta", clear

*Filtro para los médicos (p505==235) que trabajan más de 35 horas.
keep if i513t>=35 & p505==235
sort ing_mensual 
recode ao (2016/2018 = 3) (2013/2015=2) (2010/2012=1), gen(grupo_ao)

*Cálculo media + p5 y p95
table publico [pw=fac500a] if grupo_ao==3, c(p5 ing_mensual mean ing_mensual p95 ing_mensual)
table publico [pw=fac500a] if grupo_ao==3, c(p5 ing_mensual p25 ing_mensual p50 ing_mensual p75 ing_mensual p95 ing_mensual)

table publico [pw=fac500a] if grupo_ao==2, c(p5 ing_mensual mean ing_mensual p95 ing_mensual)
table publico [pw=fac500a] if grupo_ao==2, c(p5 ing_mensual p25 ing_mensual p50 ing_mensual p75 ing_mensual p95 ing_mensual)

*Test de medias para salarios entre grupos de años
*Pool 13-15 vs Pool 16-18
ttest ing_mensual if grupo_ao!=1 & publico==0, by(grupo_ao)

*Medias móviles
gen pool_07_09=(ao<=2009)
gen pool_08_10=(ao>2007 & ao<=2010)
gen pool_09_11=(ao>2008 & ao<=2011)
gen pool_10_12=(ao>2009 & ao<=2012)
gen pool_11_13=(ao>2010 & ao<=2013)
gen pool_12_14=(ao>2011 & ao<=2014)
gen pool_13_15=(ao>2012 & ao<=2015)
gen pool_14_16=(ao>2013 & ao<=2016)
gen pool_15_17=(ao>2014 & ao<=2017)
gen pool_16_18=(ao>2015 & ao<=2018)

*para los privados
mean ing_mensual if publico==0 & pool_07_09==1
mean ing_mensual if publico==0 & pool_08_10==1
mean ing_mensual if publico==0 & pool_09_11==1
mean ing_mensual if publico==0 & pool_10_12==1
mean ing_mensual if publico==0 & pool_11_13==1
mean ing_mensual if publico==0 & pool_12_14==1
mean ing_mensual if publico==0 & pool_13_15==1
mean ing_mensual if publico==0 & pool_14_16==1
mean ing_mensual if publico==0 & pool_15_17==1
mean ing_mensual if publico==0 & pool_16_18==1

*para los públicos
mean ing_mensual if publico==1 & pool_07_09==1
mean ing_mensual if publico==1 & pool_08_10==1
mean ing_mensual if publico==1 & pool_09_11==1
mean ing_mensual if publico==1 & pool_10_12==1
mean ing_mensual if publico==1 & pool_11_13==1
mean ing_mensual if publico==1 & pool_12_14==1
mean ing_mensual if publico==1 & pool_13_15==1
mean ing_mensual if publico==1 & pool_14_16==1
mean ing_mensual if publico==1 & pool_15_17==1
mean ing_mensual if publico==1 & pool_16_18==1
