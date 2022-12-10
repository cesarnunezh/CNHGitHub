/////////////////  ENAHO 2017 "CORRUPCCION Y DEMOCRACIA"  //////////////////////

clear
use "F:\Data\basefinal-2017-1.dta"

gen aniorec=real(year)
keep if codinfor!="00"
gen corrup = p2_1_01*100

table aniorec [pw=facgob07], c(mean corrup) format(%5.1f)

svyset [pweight = facgob07], psu(conglome)strata(estrato)
svy: mean corrup, over(aniorec)

gen dpto= real(substr(ubigeo,1,2))
label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

svyset [pweight = facgob07], psu(conglome)strata(estrato)
svy: tab dpto corrup

local dpto = "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25"
foreach j of local dpto {
display  "Cuadro corrupcion segun dpto`j'"
svy: mean corrup if dpto==`j', over(aniorec)
}

********************************************************************************

svy: tab p7

local dpto = "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25"
foreach j of local dpto {
display  "Cuadro democracia segun dpto`j'"
svy: tab p7 if dpto==`j'
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/////////////////  ENAHO 2018 "CORRUPCCION Y DEMOCRACIA"  //////////////////////

clear
use "F:\Data\basefinal-2018-1.dta"

gen aniorec=real(anio)
keep if codinfor!="00"
gen corrup = p2_1_01*100

rename famiegob07 facgob07 

table aniorec [pw=facgob07], c(mean corrup) format(%5.1f)

svyset [pweight = facgob07], psu(conglome)strata(estrato)
svy: mean corrup, over(aniorec)

********************************************************************************

gen dpto= real(substr(ubigeo,1,2))
label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 7"Callao" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
*/12"Junin" 13"La Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San Martin" /*
*/23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

svyset [pweight = facgob07], psu(conglome)strata(estrato)
svy: tab dpto corrup

local dpto = "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25"
foreach j of local dpto {
display  "Cuadro corrupcion segun dpto`j'"
svy: mean corrup if dpto==`j', over(aniorec)
}


********************************************************************************

svy: tab p7

local dpto = "01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25"
foreach j of local dpto {
display  "Cuadro democracia segun dpto`j'"
svy: tab p7 if dpto==`j'
}

