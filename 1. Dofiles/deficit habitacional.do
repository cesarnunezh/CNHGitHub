*DEFICIT HABITACIONAL CUANTITATIVO

*Los hogares con d�ficit cuantitativo de vivienda, son aquellos que presentan d�ficit tradicional (hogares secundarios), asimismo los hogares que habitan en viviendas no
*adecuadas; es decir hogares que habitan en viviendas improvisadas, locales no destinados para habitaci�n humana u otro tipo de vivienda (cueva, veh�culo abandonado u otro
*refugio natural); y adem�s los hogares que habitan en viviendas improvisadas cuya condici�n de ocupaci�n de la vivienda es alquilada, cedida por otro hogar, cedida por el centro
*de trabajo, cedida por otra instituci�n u otro tipo ocupaci�n como la anticresis.


gen def_cuant=(hogar>1 | (p101>=6 & (p106==1 | p106>=5)))
replace def_cuant=def_cuant*100
table nombredd  [iw=factor] , c(mean def_cuant)
