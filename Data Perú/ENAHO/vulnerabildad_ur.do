
set more off
cd "c:\tempo\"
use sumaria-2022.dta,clear


****************************************
gen gpcm=gashog2d/(mieperho*12)
***************************************
*estimacion de la variable de pobreza
gen pobreza=1  if gpcm <linpe
replace pobreza=2 if gpcm >linpe & gpcm <linea
replace pobreza=3 if gpcm >linea

label define pobreza 1"Pobre extremo" 2"Pobre No extremo" 3"No pobre" ,replace
label val pobreza pobreza
***estimacion de variuable pobreza y vulnerabilidad
gen pobrezav=.
replace pobrezav = 1 if gpcm < linpe
replace pobrezav = 2 if gpcm >= linpe & gpcm < linea
replace pobrezav = 3 if gpcm >= linea & gpcm < lineav 
replace pobrezav = 4 if gpcm>= lineav

***pobreza con distribucion ipc por hogar linea real por dominio

label define pobrezav 1"Pobre extremo" 2"Pobre No extremo" 3"Vulnerable No pobre" 4"No Vulnerable",replace
label val pobrezav pobrezav

label var pobrezav "Pobreza y vulnerabilidad" 
tab pobrezav aniorec [iw=factornd07],col nofre

drop gpcm aniorec - lineavc_18
 save,replace
