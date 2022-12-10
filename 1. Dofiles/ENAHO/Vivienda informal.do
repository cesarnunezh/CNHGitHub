******** VIVIENDA INFORMAL

clear
set more off
global inputs "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\4. BibliografÌa y data\Bases de datos compartidas\ENAHO\Enaho anual\inputs"

use "${inputs}\2018\enaho01-2018-100.dta", clear

append using "${inputs}\2017\enaho01-2017-100.dta" , force
append using "${inputs}\2016\enaho01-2016-100.dta" , force
append using "${inputs}\2015\enaho01-2015-100.dta" , force
append using "${inputs}\2014\enaho01-2014-100.dta" , force
append using "${inputs}\2013\enaho01-2013-100.dta" , force
append using "${inputs}\2012\enaho01-2012-100.dta" , force
append using "${inputs}\2011\enaho01-2011-100.dta" , force
append using "${inputs}\2010\enaho01-2010-100.dta" , force
append using "${inputs}\2009\enaho01-2009-100.dta" , force
append using "${inputs}\2008\enaho01-2008-100.dta" , force
append using "${inputs}\2007\enaho01-2007-100.dta" , force


destring ubigeo, replace
gen dpto=int(ubigeo/10000)

label define dpto 1 "Amazonas" 2 "¡Åncash" 3 "ApurÌmac" 4 "Arequipa" 5 "Ayacucho" 	/*
*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Hu·nuco" 11 "Ica" 12 	/* 
*/ "JunÌn" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San MartÌn" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"

label values dpto dpto

gen licencia_profesional=1 if p104b1==1 & p104b2==1
replace licencia_profesional=0 if p104b1!=1 & p104b1!=.
replace licencia_profesional=0 if p104b2!=1 & p104b2!=.

tab a—o p101 [iw=factor07]														/* tipo de vivienda */
tab a—o p104b1 [iw=factor07]													/* licencia de construcciÛn? */
tab a—o p104b2 [iw=factor07]													/* La construcciÛn contÛ con ing. o arq. */
tab a—o licencia_profesional [iw=factor07]										/* ConstrucciÛn c/ licencia Y profesional */
tab a—o p105a [iw=factor07]														/* Vivienda alquilada, propia */
tab a—o p106a [iw=factor07]														/* øTiene tÌtulo de propiedad? */
tab a—o p106b [iw=factor07]														/* øTÌtulo registrado en SUNARP? */
tab a—o p107b1 [iw=factor07] 													/* Comprar casa o departamento */
tab a—o p107b2 [iw=factor07] 													/* Comprar terreno para vivienda */
tab a—o p107b3 [iw=factor07] 													/* Mejora o ampliaciÛn vivienda */
tab a—o p107b4 [iw=factor07] 													/* ConstrucciÛn de vivienda nueva */
tab a—o p107e [iw=factor07] 													/* dificultades en pago */

replace p107b1=0 if p107b1==2
replace p107b2=0 if p107b2==2
replace p107b3=0 if p107b3==2
replace p107b4=0 if p107b4==2

* Dificultades en pago del crÈdito 
table a—o [iw=factor07] ,c (mean p107b1 mean p107b2 mean p107b3 mean p107b4)  	/* Comprar casa o departamento */

table a—o [iw=factor07], c(sum p107b1 sum p107b2 sum p107b3 sum p107b4) row col format(%12.0fc)

table a—o , c(sum p107b1 sum p107b2 sum p107b3 sum p107b4) row col format(%12.0fc)

rename (p107c11 p107c12 p107c13 p107c14 p107c15 p107c16 p107c17 p107c18 p107c19 p107c110) (banco_priv banco_nac caja_mun persona banco_materiales techo_propio financiera otro cooperativa derrama)

table a—o if p107b1==1 , c(sum banco_priv sum banco_nac sum caja_mun sum persona sum banco_materiales) row col format(%12.0fc)
table a—o if p107b1==1 , c(sum techo_propio sum financiera sum otro sum cooperativa sum derrama) row col format(%12.0fc)

table a—o pobreza if p107b1==1
