*DEFICIT HABITACIONAL CUANTITATIVO

*Los hogares con déficit cuantitativo de vivienda, son aquellos que presentan déficit tradicional (hogares secundarios), asimismo los hogares que habitan en viviendas no
*adecuadas; es decir hogares que habitan en viviendas improvisadas, locales no destinados para habitación humana u otro tipo de vivienda (cueva, vehículo abandonado u otro
*refugio natural); y además los hogares que habitan en viviendas improvisadas cuya condición de ocupación de la vivienda es alquilada, cedida por otro hogar, cedida por el centro
*de trabajo, cedida por otra institución u otro tipo ocupación como la anticresis.


gen def_cuant=(hogar>1 | (p101>=6 & (p106==1 | p106>=5)))
replace def_cuant=def_cuant*100
table nombredd  [iw=factor] , c(mean def_cuant)
