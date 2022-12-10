***********************Gasto de Bolsillo 2013 en adelante***********************
clear all
cd "C:\Users\USER\Documents\EVidenza\Bases ENAHO\Salud"

******Trabajando con las bases 

***Variables relevantes

forv x=13/18 {

use 400_`x'

keep aÑo mes conglome vivienda hogar codperso ubigeo dominio estrato p401 ///
 p4021 p4022 p4023 p4024 p4025 p4031 p4032 p4033 p4034 p4035 p4036 p4037 ///
 p4038 p4039 p40310 p40311 p40313 p40314 p4091 p4092 p4093 p4094 p4095 p4096 ///
 p4097 p4098 p4099 p40910 p40911 p4151_* p4152_* p4153_* p4154_* p417_02 ///
 p417_08 p417_11 p417_12 p417_13 p417_14 p419* i41601 i41602 i41603 i41604 ///
 i41605 i41606 i41607 i41608 i41609 i41610 i41611 i41612 i41613 i41614 i41615 ///
 i41616 factor07
 
 save 400_corto_`x', replace
 }
 ***Append
 
use 400_corto_13
append using 400_corto_14
append using 400_corto_15
append using 400_corto_16
append using 400_corto_17
append using 400_corto_18

save 400_corto_13_18, replace

*****

***Creación de variables de interés

destring aÑo,replace

*Generar departamentos
*Departamentos
gen ubigeor=real(ubigeo)
gen departamento=int(ubigeor/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" ///
 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" ///
 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" ///
 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" /// 
 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento


*Cambiar 2 por 0 para la opción no afiliado
forv x=1/8 {
replace p419`x'=0 if p419`x'==2
}

*Tipo de seguro
egen total_seguros=rowtotal(p4191 p4192 p4193 p4194 p4195 p4196 p4197 p4198)
replace total_seguros=. if p4191==.

gen tipo_seguro=.
replace tipo_seguro=1 if (p4191==1) & total_seguros==1
replace tipo_seguro=2 if (p4193==1 | (p4191==1 & p4193==1)) & (p4192==0 & ///
 p4194==0 & p4196==0 & p4197==0 & p4198==0)
replace tipo_seguro=3 if p4195==1 & total_seguros==1
replace tipo_seguro=4 if p4194==1 & total_seguros==1
replace tipo_seguro=5 if (p4192==1 | p4196==1 | p4197==1 | p4198==1) ///
& total_seguros==1
replace tipo_seguro=6 if (tipo_seguro!=2 & total_seguros>1 & total_seguros!=.)
replace tipo_seguro=7 if total_seguros==0

label define tipo_seguro 1 "Solo Essalud" 2 "EsSalud y/o EPS" 3 "Solo SIS" ///
 4 "Solo FFAA y PNP" 5 "Solo privado" 6 "Más de 1 seguro" 7"Sin Seguro" 
label values tipo_seguro tipo_seguro

gen seguro=.
replace seguro=0 if tipo_seguro==7
replace seguro=1 if total_seguros>0 & total_seguros!=.

label define seguro 0 "Sin" 1 "Con" 
label values seguro seguro

*Presenta síntoma, malestar, enfermedad o accidente

gen enfermo=.
replace enfermo=1 if p4021==1 | p4022==1 | p4023==1 | p4024==1
replace enfermo=0 if p4025==1
label define enfermo 1 "Enfermo" 0 "No enfermo"
label values enfermo enfermo

*Lugar de atención
gen lugar_atencion=.
replace lugar_atencion=0 if p40314==1
replace lugar_atencion=1 if p4031==1 | p4032==1 | p4033==1
replace lugar_atencion=2 if p4035==1
replace lugar_atencion=3 if p4034==1
replace lugar_atencion=4 if p4036==1
replace lugar_atencion=5 if p4037==1
replace lugar_atencion=6 if p4038==1 | p4039==1
replace lugar_atencion=7 if p40310==1
replace lugar_atencion=8  if p40311==1 | p40313==1
label variable lugar_atencion "Lugar de atencion"
label define lugar_atencion 0 "No atencion" 1 "Minsa 1nivel" 2"Minsa 2nivel" ///
 3"EsSalud 1nivel" 4"EsSalud 2nivel" 5"FFAA y PNP" 6"Privado" 7"Farmacia" 8"Otro" 
label values lugar_atencion lugar_atencion

/*Pq no se atendio (estaba variable también pregunta a los que se atienden en 
farmacia */

gen dinero=p4091
egen problemas_oferta = rowtotal (p4092 p4093 p40910), missing
gen no_necesario = p4095
gen sin_seguro = p4097
gen autoreceto= p4098
egen otros_no_atendio = rowtotal (p4094 p4096 p4099 p40911), missing

*Gasto de Bolsillo
forv x=1/9 {

gen oop_`x' = i4160`x' if p4151_0`x'==1 | p4152_0`x'==1 | p4153_0`x'==1 ///
| p4154_0`x'==1
}

gen oopmedicina_percapita= oop_2
replace oopmedicina_percapita=0 if oop_2==.

label variable oop_1 "OOP consulta"
label variable oop_2 "OOP medicinas"

forv x=10/16 {

gen oop_`x' = i416`x' if p4151_`x'==1 | p4152_`x'==1 | p4153_`x'==1 | ///
 p4154_`x'==1
}

egen ooptotal_percapita= rowtotal(oop_*)
egen ooptotal_xgastador= rowtotal (oop_*), missing
label variable ooptotal_percapita "OOP_total"
label variable ooptotal_xgastador "OOP_x_persona_que_gasta"
label variable oopmedicina_percapita "OOP_medicina_per_capita"
 
*Tendencia del OOP per capita Peru
table aÑo [pw=factor], c(mean oopttotal_percapita mean oopmedicina_percapita) 

*Tendencia OOP total Peru
table aÑo [pw=factor], c(sum oopttotal_percapita sum oopmedicina_percapita)

*Por departamento
table aÑo departamento [pw=factor], c((mean oopttotal_percapita mean oopmedicina_percapita)
