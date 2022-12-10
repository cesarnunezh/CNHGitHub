******* Gasto hogares por tipo de trabajador
clear all
set more off

global inputs "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\4. Bibliografía y data\Bases de datos compartidas\ENAHO\Enaho anual\inputs\2018"
global temp "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\4. Bibliografía y data\Bases de datos compartidas\ENAHO\Enaho anual\temp"

use "$inputs\sumaria-2018.dta", clear
merge 1:1 conglome vivienda hogar using "$temp\mantenimiento_vivienda.dta" 

gen pobre=(pobreza==2)
gen pobre_ext=(pobreza==1)

replace pobre=pobre*100
replace pobre_ext=pobre_ext*100

gen gmens_alim=gru11hd/12 // gasto en alimentos
gen gmens_salud=gru51hd/12 // gasto en cuidado, conservación de la salud y servicios médicos.
gen gas_mens_alim_salud=gmens_alim+gmens_salud // gasto salud + alimentos
gen g_mensual=gashog1d/12 // gasto total monetario
gen g_mant=i603b/12 // gasto imputado, deflactado y anualizado de mantenimiento de la vivienda
gen mantenimiento=gru41hd/12 // muebles, enseres y mantenimiento de la vivienda
gen transporte=gru61hd/12 // transportes y comunicaciones

save "$temp\gasto_hogares.dta", replace
sort conglome vivienda hogar
merge 1:m conglome vivienda hogar using "$inputs\enaho01a-2018-500.dta", gen (m)
keep if m==3
drop m
save "$temp\gasto_hogares_trabajo.dta", replace

******* PEA OCUPADA
keep if (ocu500==1 | ocu500==2) & p208a>=14
gen ocupado=1 if ocu500==1 & p512b!=.
replace ocupado=0 if ocu500==2
gen desempleo = (ocupado==0)

*tab p301a [iw=fac500a] if filtro==1 & ocu500==1 // PEA OCUPADA DE 16.8 millones // 16.597 MILLONES (con filtro y ocupada==1)

*************Agregando departamentos

g departamento=substr(ubigeo,1,2)
destring departamento, replace
replace departamento=15 if departamento==7 //Callao es Lima

label values departamento departamento
label define departamento 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" ///
6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" ///
13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" ///
19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna"	24 "Tumbes" 25 "Ucayali"	

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


**** filtro para sacar la pea ocupada ****
gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) & (p501>0 | p501!=.)


*** Dependientes
gen dependientes=1 if p507==4 | p507==3
replace dependientes = 0 if dependientes == .

*** Independientes
gen independientes= 1 if p507==2 | p507==7

*Para calcular trabajadores a tiempo completo

*Horas de trabajo de la ocupación principal y secundaria
******************
egen horas = rowtotal(p513t p518), m
replace horas = i513t if (ocu500==1 & i518==. & p519==1)
replace horas = i520 if (ocu500==1 & p519==2)
gen hor=.
replace hor = horas * 4 if horas !=.
replace hor = hor*12


*Part-time y full-time	
**********************
gen labsupply = (horas>=30) if horas<.
label define labsupply 0 "part-time" 1 "full-time"
label values labsupply labsupply	
g parttime=(labsupply==0)


*Clasificar por ingresos en la ocupación principal

egen ing_ocu_pri=rowtotal(i524a1 d529t d536) if ocu500==1 & !missing(ocu500)
replace ing_ocu_pri=ing_ocu_pri/12 

egen ing_ocu_sec=rowtotal(i538a1 d540t i541a d543) if ocu500==1 & !missing(ocu500)
replace ing_ocu_sec=ing_ocu_sec/12

egen ing_lab=rowtotal(ing_ocu_pri ing_ocu_sec) if ocu500==1 & !missing(ocu500)

gen cat_ing = 1 if ing_ocu_pri>0 & ing_ocu_pri < 930
replace cat_ing = 2 if ing_ocu_pri >= 930 & ing_ocu_pri <1400
replace cat_ing = 3 if ing_ocu_pri >= 1400 & ing_ocu_pri <2000
replace cat_ing = 4 if ing_ocu_pri >= 2000 & ing_ocu_pri <3000
replace cat_ing = 5 if ing_ocu_pri >= 3000 & ing_ocu_pri <99999


*Cuadro: Número de trabajadores dependientes

*TamaÃ±o de empresa
gen tama=1 if (p512b <= 10) // menor a 10 trabajadores.
replace tama=2 if (p512b > 10 & p512b <= 100)
replace tama=3 if (p512b > 100 & p512b <= 250)
replace tama=4 if (p512b > 250)
replace tama=. if p512b==.

label values tama tama
label define tama 1 "Microempresa" 2 "Pequeña empresa" 3 "Mediana empresa" 4 "Gran empresa"


*Tamaño de empresa

gen tam=1 if (p512b <= 10) //& dependiente==1) //Micro
replace tam=2 if (p512b > 10 & p512b<= 100) //Pequeña
replace tam=4 if (p512b > 100) //Gran y Mediana
replace tam=. if p512b==. //No hay información


*Información: Empresas informales o formales que emplean trabajadores informales
* formales.

*PEA ocupada que trabaja en empresas formales para ocupación principal
gen emp_inf=1 if (p510a1==1 | p510a1==2) // Formal
replace emp_inf=0 if p510a1==3 // Informal

label values emp_inf label_empresa_formal
label define label_empresa_formal 1 "Formal" 0 "Informal"

*Ocupacion
gen r5=(p506r4/100)
recode r5 (1/3.22 = 1) (5/9.9 = 2) (10/33.2 = 3) (35/39 = 4) (41/43.9 = 5) (45/47.99 = 6)  (49/53.2 = 7)  (55/56.3 = 8) (58/60.2 = 9) (62/63.99 = 9) (61/61.9 = 10) (64/66.3 = 11) (68/99 = 12), gen(r51)
label define r51 1 "Agricultura, ganaderÃ­a, silvicultura y pesca" 2 "ExplotaciÃ³n de minas y canteras" 3 "Industrias manufactureras" 4 "Suministro de electricidad, agua y gas"  5 "ConstrucciÃ³n" 6 "Comercio" 7 "Transporte y almacenamiento" 8 "Actividades de alojamiento y de comida" 9 "InformaciÃ³n" 10 "Telecomunicaciones"  11"Servicios financieros"  12 "Otros servicios" 
label values r51 r51

gen agropecuario = (r5>=1 & r5<2) 
gen tala = (r5>=2 & r5<3) 
gen pesca = (r5>=3 & r5<4) 
gen mina = (r51 == 2) 
gen manufactura = (r51 == 3) 
gen construccion = (r51 == 5) 
gen comercio = (r51 == 6)
gen servicios = (r51>=7)


gen agroindustria = (r5>=10 & r5<11)  
replace agroindustria = 1 if (r5>=1 & r5<2) & dependiente==1 & tama>1


gen sector = 9
replace sector = 1 if agropecuario == 1
replace sector = 3 if pesca == 1
replace sector = 4 if mina == 1
replace sector = 5 if tala == 1
replace sector = 6 if construccion == 1
replace sector = 7 if manufactura == 1
replace sector = 2 if agroindustria == 1
replace sector = 8 if comercio == 1


label define sector 1 "Agropecuario" 2 "Agroindustria" 3 "Pesca" 4 "Energético" 5 "Tala"  6 "Construcción" 7 "Manufactura" 8 "Comercio" 9 "Servicios" 
label values sector sector

************************ Regiones naturales
gen regiones_naturales=.
replace regiones_naturales=1 if (dominio==1 | dominio==2 | dominio==3 | dominio==8) // Costa
replace regiones_naturales=2 if (dominio==4 | dominio==5 | dominio==6) // Sierra
replace regiones_naturales=3 if (dominio==7) // Selva

label define regiones_nat 1 "Costa" 2 "Sierra" 3 "Selva" 
label values regiones_naturales regiones_nat

