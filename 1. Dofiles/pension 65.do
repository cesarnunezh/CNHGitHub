
clear
set more off
global bd "D:\1. Documentos personales\0. Bases de datos\2. ENAHO\1. Data"

use "$bd\enaho01-2020-200.dta", clear

merge m:1 conglome vivienda hogar using "$bd\sumaria-2020.dta", keepusing(pobreza gas* ing*)
drop _merge
merge m:1 conglome vivienda hogar using "$bd\enaho01-2020-700.dta", keepusing(p70* p71*)
drop _merge

* pensión 65 p710_05

gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
gen adulto_mayor=(p208a>=65)
gen adulto_nuevo=(p208a>=60)

table pobreza adulto_mayor if filtro==1  [iw=facpob07], format(%12.0fc) row
table pobreza adulto_nuevo if filtro==1  [iw=facpob07], format(%12.0fc) row
tab pobreza p710_05 if filtro==1 & p208a>=65 [iw=facpob07]
