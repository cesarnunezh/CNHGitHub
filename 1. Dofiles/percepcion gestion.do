////////Percepción de la gestión

clear
use "C:\Users\ddavila\Desktop\Pendientes\Mayo\STATA\Modulo 85\basefinal-2018-1.dta"

gen departamento= real(substr(ubigeo,1,2))
label define departamento 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
label values departamento departamento  

keep if codinfor!="00"
svyset [pweight = facgob07], psu(conglome) strata(estrato)

set more off

** Percepción Gobierno Central
rename p2a1_1 pergobce
svy: tab departamento pergobce, row

** Percepción Gobierno Regional
rename p2a1_2 pergore
svy: tab departamento pergore, row

** Percepción Gobierno Local Provincial
rename p2a1_3 pergobprov
svy: tab departamento pergobprov, row

** Percepción Gobierno Local Distrital
rename p2a1_4 pergobdist
svy: tab departamento pergobdist, row
