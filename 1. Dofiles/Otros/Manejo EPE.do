clear all
set more off

global inputs "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\3. Factores (mesas CPC)\2. Mercado Laboral\Data\EPE\input/"
global temp "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\3. Factores (mesas CPC)\2. Mercado Laboral\Data\EPE\temp/"
global output "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\3. Factores (mesas CPC)\2. Mercado Laboral\Data\EPE\output/"

********************* Pasar Bases de BDF a Stata ***********************
import dbase using "${inputs}Trim Ene-Feb-Mar19.dbf", clear
destring PANO, replace
destring PMES, replace
save "${inputs}ene-feb-mar19.dta", replace

import dbase using "${inputs}Trim Ene-Feb-Mar20.dbf", clear
destring PANO, replace
destring PMES, replace
save "${inputs}ene-feb-mar20.dta", replace

import dbase using "${inputs}Trim Abr-May-Jun20.dbf",clear
destring PANO, replace
destring PMES, replace
save "${inputs}abr-may-jun20.dta", replace

import dbase using "${inputs}Trim Jun-Jul-Ago20.dbf",clear
drop if PMES=="06"
destring PANO, replace
destring PMES, replace
save "${inputs}jul-ago20.dta", replace

************************** Append Bases ******************************
use , clear
drop if PMES!=1
sort PANO PMES
append using "${inputs}ene-feb-mar20.dta"
append using "${inputs}abr-may-jun20.dta"
append using "${inputs}jul-ago20.dta"

save "${output}2019_2020.dta", replace

********************** Clasificación Formal e Informal ***********
gen ocupinf=0 if (P222==1 | P222==2 | P222==3) /*formal*/
replace ocupinf=1 if (P222==4 | P222==5 | P222==6) /*informal*/

label values ocupinf label_ocupinf
label define label_ocupinf 1 "informal" 0 "formal"

********************** Filtro ************************************
gen filtro=0
replace filtro=1 if ((P104==1 & P105==2) | (P104==2 & P106==1)) ///
& (P201>0 | P201!=.)

********************** Factor expansión EPE trimestral ***********
gen fac500a=FA_EFM19 if (PANO==2019 & PMES<=3 & PMES>=1)
replace fac500a=FA_EFM20 if (PANO==2020 & PMES<=3 & PMES>=1)
replace fac500a=FA_AMJ20 if (PANO==2020 & PMES<=6 & PMES>=4)
replace fac500a=FA_JJA20 if (PANO==2020 & PMES<=8 & PMES>=7)

********************* Réplica gráfico MTPE *********************
tab PMES ocupinf [iw=fac500a] if filtro==1 & OCU200==1& PANO==2020
tab PMES ocupinf [iw=fac500a] if filtro==1 & OCU200==1 & PANO==2019
