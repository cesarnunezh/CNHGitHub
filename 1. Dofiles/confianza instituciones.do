//////////// Confianza en instituciones del estado por año ////////

clear
use "C:\Users\ddavila\Desktop\Pendientes\Mayo\STATA\Modulo 85\basefinal-2018-1.dta"

gen departamento= real(substr(ubigeo,1,2))
label define departamento 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
label values departamento departamento  

keep if codinfor!="00"
svyset [pweight = facgob07], psu(conglome) strata(estrato)

**Confianza en el Gob. Local Distrital
rename p1_05 confdis
svy: tab departamento confdis, row

**Confianza en Municipalidad Provincial
rename p1_04 confprov
svy: tab departamento confprov, row

**Confianza en Gobierno Regional
rename p1_08 confgore
svy: tab departamento confgore, row

**Confianza en el Congreso
rename p1_12 confcong
svy: tab departamento confcong, row

**Confianza en el JNE
rename p1_01 confjne
svy: tab departamento confjne, row

**Confianza en ONPE
rename p1_02 confonpe
svy: tab departamento confonpe, row

**Confianza en Poder Judicial
rename p1_09 confpj
svy: tab departamento confpj, row
