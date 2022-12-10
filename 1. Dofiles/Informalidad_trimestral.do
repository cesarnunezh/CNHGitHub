******************* PL ***************************
*Estimar la población objetivo.
clear all
set more off
global temp "D:\1. Documentos personales\0. Bases de datos\2. ENAHO\2. Temp"
global outputs "D:\1. Documentos personales\0. Bases de datos\2. ENAHO\3. Output"
global inputs "D:\1. Documentos personales\0. Bases de datos\2. ENAHO\1. Data\Trimestral"

foreach año in 2018 2019 2020{
	foreach term in t1 t2 t3 t4{
		use "$inputs\enaho01_`año'_200_`term'.dta", clear
		egen id = concat (conglome vivienda hogar codperso)
		gen trimestre= "`term'"
		sort conglome vivienda hogar codperso
		save, replace
		
		use "$inputs\enaho01a_`año'_500_`term'.dta", clear
		egen id = concat (conglome vivienda hogar codperso)
		sort conglome vivienda hogar codperso
		sort id
		merge 1:1 id using "$inputs\enaho01_`año'_200_`term'.dta", gen(m)
		keep if m==3
		drop m
		save "$temp/`año'_`term'.dta", replace
}
}


***** Adjuntar las bases trimestrales
foreach año in 2018 2019 2020 {
use "$temp/`año'_t1.dta",clear
foreach x in t2 t3 t4 {
	append using "$temp/`año'_`x'.dta", force
	
	}
gen year= `año'
save "$temp/`año'.dta", replace
}

use "$temp/2018.dta", clear
append using "$temp/2019.dta"
append using "$temp/2020.dta"
save "$outputs/enaho_laboral_trimestral.dta", replace

************************** Informalidad *****************************
******* PEA OCUPADA
use "$outputs/enaho_laboral_trimestral.dta", clear
keep if (ocu500==1 | ocu500==2) & p208a>=14
gen ocupado=1 if ocu500==1 & p512b!=.
replace ocupado=0 if ocu500==2
gen desempleo = (ocupado==0)

**** filtro para sacar la pea ocupada ****
gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) & (p501>0 | p501!=.)

tab p301a [iw=fac500a] if year==2018 & filtro==1 & ocupado==1 // PEA OCUPADA DE 16.597 MILLONES (con filtro y ocupada==1)

* Rural urbana
gen rural=1 if estrato==7 | estrato==8 //rural
replace rural=0 if rural==. //urbano

label values rural label_rural
label define label_rural 1 "rural" 0 "urbano"


*Nueva clasificación Dependientes e Independientes
*Trabaja para el sector público o privado?
** Sector publico o privado
gen privado =(p510==5| p510==6 |p510==7)

label values privado label_pub_priv
label define label_pub_priv 1 "privado" 0 "público"


*Clasificar si son informales o formales
replace ocupinf =0 if ocupinf==2
label define informal_label 0 "formal" 1 "informal"
label values ocupinf informal_label	
*Informal es 1; formal es 0

table year ocupinf [iw=fac500] if filtro==1 & trimestre!="T4", format(%12.0fc)


*** Dependientes
gen dependientes=1 if p507==4 | p507==3
replace dependientes = 0 if dependientes == .

*TamaÃ±o de empresa
gen tama=1 if (p512b <= 10) // menor a 10 trabajadores.
replace tama=2 if (p512b > 10 & p512b <= 100)
replace tama=3 if (p512b > 100 & p512b <= 250)
replace tama=4 if (p512b > 250)
replace tama=. if p512b==.

label values tama tama
label define tama 1 "Microempresa" 2 "Pequeña empresa" 3 "Mediana empresa" 4 "Gran empresa"


