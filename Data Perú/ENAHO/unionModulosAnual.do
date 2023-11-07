/*******************************************************************************
Objetivo: Unión de los módulos de la ENAHO para el periodo 2007-2022
Autores:  CN


Estructura:
	0. Direcciones
    1. Compilado de años para las bases de datos
		
*******************************************************************************/

* 0. Direcciones

/*global bd "D:\1. Documentos\0. Bases de datos\2. ENAHO\1. Data"
global out1 "D:\1. Documentos\0. Bases de datos\2. ENAHO\3. Output"
global temp "D:\1. Documentos\0. Bases de datos\2. ENAHO\2. Temp"
*/
	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data\Anual"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
* 1. Compilado de años para las bases de datos
	*Módulo 100 - Características de la vivienda y el hogar
{   
*	global var_1 "conglome vivienda hogar ubigeo estrato dominio nbi* p10* p104* p1121 p103 p110* p111* p113* p1141 p1142 p1143 p1144 p1145 dominio fac* a?o alt* latitud longitud"
	use "$bd\enaho01-2007-100.dta", clear
*	keep $var_1
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01-`i'-100.dta", force
    replace año=`i' if año==.
	}
	
	
	replace p111a=p111 if p111a==.
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	
	replace altitud = altura if año ==2019
	drop altura

	save "$temp\modulo100.dta", replace
}
	*Módulo 200 - Características de los miembros del hogar
{	
*    global var_2 "conglome vivienda hogar codperso estrato dominio ubigeo p20* facpob07"
	use "$bd\enaho01-2007-200.dta", clear
*	keep $var_2
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01-`i'-200.dta", force
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)

	save "$temp\modulo200.dta", replace
}
	*Módulo 300 - Educación
{	
*    global var_3 "conglome vivienda hogar codperso estrato dominio ubigeo p20* p301* p303 p306 p307 p310 p300a fac*"
	use "$bd\enaho01a-2007-300.dta", clear
*	keep $var_3
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01a-`i'-300.dta", force
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo300.dta", replace
}	
	*Módulo 400 - Salud
{	
*    global var_4 "conglome vivienda hogar codperso estrato dominio ubigeo p401  p4021 p4022 p4023 p4024 p4025 p4031-p40314 p4091-p40911 p4151_* p4152_* p4153_* p4154_* p417_02 p417_08 p417_11 p417_12 p417_13 p417_14 p419* i416* p419* p2* fac*"
	use "$bd\enaho01a-2007-400.dta", clear
*	keep $var_4
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01a-`i'-400.dta", force 
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo400.dta", replace
}	
	*Módulo 500 - Empleo e Ingresos
{
*    global var_5 "conglome vivienda hogar codperso estrato dominio ubigeo p20* p301a p505* p506* p507 p511* p512* p513t i513t i518 i520 p517* p518 p520 p523 fac500a ocu500 ocupinf i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t mes"
	use "$bd\enaho01a-2007-500.dta", clear
*	keep $var_5
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01a-`i'-500.dta", force
	replace año=`i' if año==.
    }
	replace fac500a=fac500a7 if año==2011
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo500.dta", replace
}	
	*Módulo 612 - Equipamiento del hogar
{
	use "$bd\enaho01-2007-612.dta", clear
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01-`i'-612.dta", force
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo612.dta", replace
}	
	*Módulo 700 - Programas Sociales
{
    global var_7 "conglome vivienda hogar estrato dominio ubigeo mes p7* "
	use "$bd\enaho01-2007-700.dta", clear
	keep $var_7
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\enaho01-`i'-700.dta", keep($var_7) 
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	
	save "$temp\modulo700.dta", replace

	
	use "$bd\enaho01-2012-700a.dta", clear
	keep $var_7
	gen año=2012
	forvalues i= 2013/2022{
    append using "$bd\enaho01-`i'-700a.dta", keep($var_7) 
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo700a.dta", replace



	use "$bd\enaho01-2012-700b.dta", clear
	keep $var_7
	gen año=2012
	forvalues i= 2013/2022{
    append using "$bd\enaho01-`i'-700b.dta", keep($var_7) 
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo700b.dta", replace
}	
	*Sumaria
{														
	use "$bd\sumaria-2007.dta", clear
	gen año=2007
	forvalues i= 2008/2022{
    append using "$bd\sumaria-`i'.dta"
	replace año=`i' if año==.
    }

	destring conglome, replace
	tostring conglome, replace format(%06.0f)

	recode g01hd ig0* insedthd1 paesechd1 ing* *gru* gas* tipocuesti* tipoentre* estrsocial lin* pobrezav ld pobreza (.=0)

	gen aniorec=año
	gen dpto= real(substr(ubigeo,1,2))
	replace dpto=15 if (dpto==7)


	sort aniorec dpto
	merge aniorec dpto using "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\0. Documentación\Gasto2022\Bases\deflactores_base2022_new.dta"
	tab _m
	drop if _merge==2
	drop _m

	*ámbito urbano/rural
	replace estrato = 1 if dominio ==8 
	gen area = estrato <6
	replace area=2 if area==0
	label define area 2 rural 1 urbana
	label val area area

	*dominios geográficos
	gen domin02=1 if dominio>=1 & dominio<=3 & area==1
	replace domin02=2 if dominio>=1 & dominio<=3 & area==2
	replace domin02=3 if dominio>=4 & dominio<=6 & area==1
	replace domin02=4 if dominio>=4 & dominio<=6 & area==2
	replace domin02=5 if dominio==7 & area==1
	replace domin02=6 if dominio==7 & area==2
	replace domin02=7 if dominio==8

	label define domin02 1 "Costa_urbana" 2 "Costa_rural" 3 "Sierra_urbana" 4 "Sierra_rural" 5 "Selva_urbana" 6 "Selva_rural" 7 "Lima_Metropolitana"
	label value domin02 domin02

	gen     dominioA=1 if dominio==1 & area==1
	replace dominioA=2 if dominio==1 & area==2
	replace dominioA=3 if dominio==2 & area==1
	replace dominioA=4 if dominio==2 & area==2
	replace dominioA=5 if dominio==3 & area==1
	replace dominioA=6 if dominio==3 & area==2
	replace dominioA=7 if dominio==4 & area==1
	replace dominioA=8 if dominio==4 & area==2
	replace dominioA=9 if dominio==5 & area==1
	replace dominioA=10 if dominio==5 & area==2
	replace dominioA=11 if dominio==6 & area==1
	replace dominioA=12 if dominio==6 & area==2
	replace dominioA=13 if dominio==7 & area==1
	replace dominioA=14 if dominio==7 & area==2
	replace dominioA=15 if dominio==7 & (dpto==16 | dpto==17 | dpto==25) & area==1
	replace dominioA=16 if dominio==7 & (dpto==16 | dpto==17 | dpto==25) & area==2
	replace dominioA=17 if dominio==8 & area==1
	replace dominioA=17 if dominio==8 & area==2

	label define dominioA 1 "Costa norte urbana" 2 "Costa norte rural" 3 "Costa centro urbana" 4 "Costa centro rural" /*
	*/ 5 "Costa sur urbana" 6 "Costa sur rural"	7 "Sierra norte urbana"	8 "Sierra norte rural"	9 "Sierra centro urbana" /* 
	*/ 10 "Sierra centro rural"	11 "Sierra sur urbana" 12 "Sierra sur rural" 13 "Selva alta urbana"	14 "Selva alta rural" /*
	*/ 15 "Selva baja urbana" 16 "Selva baja rural" 17"Lima Metropolitana"
	lab val dominioA dominioA 

	drop ld

	sort  dominioA

	merge dominioA using "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\0. Documentación\Gasto2022\Bases\despacial_ldnew.dta"
	tab _m
	drop _m

	gen factornd07=round(factor07*mieperho,1)

	gen p = 12 //periodo anual

	svyset [pweight = factornd07], psu(conglome)


	****************************************************
	******Gasto por 8  grupos de la canastas************
	****************************************************

	gen 		gpcrg3= (gru11hd + gru12hd1 + gru12hd2 + gru13hd1 + gru13hd2 + gru13hd3 )/(p*mieperho*ld*i01) 
	gen 		gpcrg6 = ((g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 +g05hd6 +ig06hd)/(p*mieperho*ld*i01)) 
	gen 		gpcrg8= ((sg23 + sig24)/(p*mieperho*ld*i01)) 
	gen 		gpcrg9= ((gru14hd + gru14hd1 +  gru14hd2 + gru14hd3 + gru14hd4 + gru14hd5 + sg25 + sig26)/(p*mieperho*ld*i01)) 
	gen    		gpcrg10= ((gru21hd + gru22hd1 + gru22hd2 + gru23hd1 + gru23hd2 + gru23hd3 + gru24hd)/(p*mieperho*ld*i02)) 
	gen     	gpcrg12= ((gru31hd + gru32hd1 + gru32hd2 + gru33hd1 + gru33hd2 + gru33hd3 + gru34hd)/(p*mieperho*ld*i03)) 
	gen     	gpcrg14= ((gru41hd + gru42hd1 + gru42hd2 + gru43hd1 + gru43hd2 + gru43hd3 + gru44hd + sg421 + sg42d1 + sg423 + sg42d3)/(p*mieperho*ld*i04)) 
	gen    		gpcrg16= ((gru51hd + gru52hd1 + gru52hd2 + gru53hd1 + gru53hd2 + gru53hd3 + gru54hd)/(p*mieperho*ld*i05)) 
	gen     	gpcrg18= ((gru61hd + gru62hd1 + gru62hd2 + gru63hd1 + gru63hd2 + gru63hd3 + gru64hd + g07hd + ig08hd + sg422 + sg42d2)/(p*mieperho*ld*i06)) 
	gen     	gpcrg19= ((gru71hd + gru72hd1 + gru72hd2 + gru73hd1 + gru73hd2 + gru73hd3 + gru74hd + sg42 + sg42d)/(p*mieperho*ld*i07)) 
	gen     	gpcrg21= ((gru81hd + gru82hd1 + gru82hd2 + gru83hd1 + gru83hd2 + gru83hd3 + gru84hd)/(p*mieperho*ld*i08)) 

	label var gpcrg3	"Preparados dentro del hogar"
	label var gpcrg6	"Adquiridos Fuera del hogar 559"
	label var gpcrg8	"Adquiridos de instituciones beneficas 602a "
	label var gpcrg9	"Adquiridos fuera del hogar item 47 y 50 y 602"
	label var gpcrg10	"Vestido y calzado"
	label var gpcrg12	"Gasto Alquiler de vivienda y combustible"
	label var gpcrg14	"Muebles y enseres"
	label var gpcrg16	"Cuidados de la salud"
	label var gpcrg18	"Transporte y comunicaciones"
	label var gpcrg19	"Esparcimiento diversión y cultura"
	label var gpcrg21	"Otros gastos de bienes y servicios"

	*RECODIFICANDO POR grupo de gastos
	**********************************
	gen 	gpgru2= gpcrg3
	gen		gpgru3= gpcrg6 + gpcrg8 + gpcrg9
	gen		gpgru4 = gpcrg10
	gen		gpgru5 = gpcrg12
	gen		gpgru6 = gpcrg14
	gen		gpgru7= gpcrg16
	gen		gpgru8 = gpcrg18
	gen		gpgru9 = gpcrg19
	gen		gpgru10 = gpcrg21 
	gen 	gpgru1 = gpgru2 + gpgru3
	gen  	gpgru0 = gpgru1 + gpgru4 + gpgru5 + gpgru6 + gpgru7 + gpgru8 + gpgru9 + gpgru10 

	label var gpgru1 "G01.Total en Alimentos real"
	label var gpgru2 "G011.Alimentos dentro del hogar real"
	label var gpgru3 "G012.Alimentos fuera del hogar real"
	label var gpgru4 "G02.Vestido y calzado real"
	label var gpgru5 "G03.Alquiler de Vivienda y combustible real"
	label var gpgru6 "G04.Muebles y enseres real"
	label var gpgru7 "G05.Cuidados de la salud real"
	label var gpgru8 "G06.Transportes y comunicaciones real"
	label var gpgru9 "G07.Esparcimiento diversion y cultura real"
	label var gpgru10 "G08.otros gastos en bienes y servicios real"

	*******************************
	*TIPOS DE ADQUISICION DE GASTOS

	gen   	  	gpcnr1 =(((gru11hd +gru14hd + sg23 + g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 + g05hd6  +sg25)/(p*mieperho *  ld*i01))/*
						*/ + (gru21hd/(p*mieperho *  ld*i02)) + /*
						*/ (gru31hd/(p*mieperho *  ld*i03)) + ((gru41hd + sg421 + sg423)/(p*mieperho *  ld*i04)) + /*
						*/ (gru51hd/(p*mieperho *  ld*i05)) + ((gru61hd + g07hd + sg422)/(p*mieperho *  ld*i06)) + /*
						*/ ((gru71hd + sg42)/(p*mieperho *  ld*i07)) + (gru81hd/(p*mieperho *  ld*i08))) 

	gen     	gpcnr2 =(((gru12hd1 + gru14hd1)/(p*mieperho *  ld*i01)) + (gru22hd1/(p*mieperho *  ld*i02)) + /*
						*/ (gru32hd1/(p*mieperho *  ld*i03)) + (gru42hd1/(p*mieperho *  ld*i04)) + /*
						*/ (gru52hd1/(p*mieperho *  ld*i05)) + (gru62hd1/(p*mieperho *  ld*i06)) + /*
						*/ (gru72hd1/(p*mieperho *  ld*i07)) + (gru82hd1/(p*mieperho *  ld*i08)))  
						
	gen     	gpcnr3 = (((gru12hd2 + gru14hd2)/(p*mieperho *  ld*i01)) + (gru22hd2/(p*mieperho *  ld*i02)) + /*
						*/ (gru32hd2/(p*mieperho *  ld*i03)) + (gru42hd2/(p*mieperho *  ld*i04)) + /*
						*/ (gru52hd2/(p*mieperho *  ld*i05)) + (gru62hd2/(p*mieperho *  ld*i06)) + /*
						*/ (gru72hd2/(p*mieperho *  ld*i07)) + (gru82hd2/(p*mieperho *  ld*i08)))   
						
	gen    		gpcnr4 =(((gru13hd1 + gru14hd3+ sig24 +sig26)/(p*mieperho *  ld*i01)) + (gru23hd1/(p*mieperho *  ld*i02)) + /*
						*/ (gru33hd1/(p*mieperho *  ld*i03)) + (gru43hd1/(p*mieperho *  ld*i04)) + /*
						*/ (gru53hd1/(p*mieperho *  ld*i05)) + (gru63hd1/(p*mieperho *  ld*i06)) + /*
						*/ (gru73hd1/(p*mieperho *  ld*i07)) + (gru83hd1/(p*mieperho *  ld*i08)))  
						
	gen     	gpcnr5 =(((gru13hd2 + gru14hd4 + ig06hd)/(p*mieperho *  ld*i01)) + (gru23hd2/(p*mieperho *  ld*i02)) + /*
						*/ (gru33hd2/(p*mieperho *  ld*i03)) + ((gru43hd2 + sg42d1 + sg42d3)/(p*mieperho *  ld*i04)) + /*
						*/ (gru53hd2/(p*mieperho *  ld*i05)) + ((gru63hd2 +ig08hd + sg42d2)/(p*mieperho *  ld*i06)) + /*
						 */ ((gru73hd2 + sg42d)/(p*mieperho *  ld*i07)) + (gru83hd2/(p*mieperho *  ld*i08)))  
					
	gen   		  gpcnr6 =(((gru13hd3 + gru14hd5)/(p*mieperho *  ld*i01)) + (gru23hd3/(p*mieperho *  ld*i02)) + /*
						*/ (gru33hd3/(p*mieperho *  ld*i03)) + (gru43hd3/(p*mieperho *  ld*i04)) + /*
						*/ (gru53hd3/(p*mieperho *  ld*i05)) + (gru63hd3/(p*mieperho *  ld*i06)) + /*
						*/ (gru73hd3/(p*mieperho *  ld*i07)) + (gru83hd3/(p*mieperho *  ld*i08))) 
						
	gen   		 gpcnr7 =((gru24hd/(p*mieperho *  ld*i02)) + (gru34hd/(p*mieperho *  ld*i03)) + /*
						*/ (gru44hd/(p*mieperho *  ld*i04)) + (gru54hd/(p*mieperho *  ld*i05)) + /*
						*/ (gru64hd/(p*mieperho *  ld*i06)) + (gru74hd/(p*mieperho *  ld*i07)) + /*
						*/ (gru84hd/(p*mieperho *  ld*i08))) 

						
	gen gpcnr0 = gpcnr1 + gpcnr2 + gpcnr3 + gpcnr4 + gpcnr5 + gpcnr6 + gpcnr7

	label var gpcnr0 "gasto nueva metodologia"
	label var gpcnr1 "Compra"
	label var gpcnr2 "Autoconsumo"
	label var gpcnr3 "Pago en especie"
	label var gpcnr4 "gasto donaciones publicas"
	label var gpcnr5 "gasto donaciones privadas"
	label var gpcnr6 "gasto otro grupo"	
	label var gpcnr7 "gasto imputado"


	****************************************************/
	**************  POR  GRUPO  Y  Tipo  ***************/
	****************************************************/
	* Comprado
	gen        gpctg1= gpcnr1
	gen        gpctg2= (gru11hd + gru14hd + sg23 + g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 + g05hd6  +sg25)/(p*mieperho*ld*i01) 
	gen        gpctg3= (gru21hd)/(p*mieperho*ld*i02) 
	gen        gpctg4= (gru31hd)/(p*mieperho*ld*i03) 
	gen        gpctg5= (gru41hd + sg421 + sg423)/(p*mieperho*ld*i04) 
	gen        gpctg6= (gru51hd)/(p*mieperho*ld*i05) 
	gen        gpctg7= (gru61hd + g07hd + sg422)/(p*mieperho*ld*i06) 
	gen        gpctg8= (gru71hd + sg42)/(p*mieperho*ld*i07) 
	gen        gpctg9= (gru81hd)/(p*mieperho*ld*i08) 

	recode gpctg2 gpctg3 gpctg4 gpctg5 gpctg5 gpctg6 gpctg7 gpctg7 gpctg8 gpctg9(.=0)


	*Autoconsumo (ajustado alquiler de vivienda)
	gen        gpctg10= gpcnr2
	gen        gpctg11= (gru12hd1 + gru14hd1)/(p*mieperho*ld*i01) 
	gen        gpctg12= (gru22hd1)/(p*mieperho*ld*i02) 
	gen        gpctg13= (gru32hd1)/(p*mieperho*ld*i03) 
	gen        gpctg14= (gru42hd1)/(p*mieperho*ld*i04) 
	gen        gpctg15= (gru52hd1)/(p*mieperho*ld*i05) 
	gen        gpctg16= (gru62hd1)/(p*mieperho*ld*i06) 
	gen        gpctg17= (gru72hd1)/(p*mieperho*ld*i07) 
	gen        gpctg18= (gru82hd1)/(p*mieperho*ld*i08) 

	* Pago en especie
	gen        gpctg19= gpcnr3
	gen        gpctg20= (gru12hd2 + gru14hd2)/(p*mieperho*ld*i01) 
	gen        gpctg21= (gru22hd2)/(p*mieperho*ld*i02) 
	gen        gpctg22= (gru32hd2)/(p*mieperho*ld*i03) 
	gen        gpctg23= (gru42hd2)/(p*mieperho*ld*i04) 
	gen        gpctg24= (gru52hd2)/(p*mieperho*ld*i05) 
	gen        gpctg25= (gru62hd2)/(p*mieperho*ld*i06) 
	gen        gpctg26= (gru72hd2)/(p*mieperho*ld*i07) 
	gen        gpctg27= (gru82hd2)/(p*mieperho*ld*i08) 

	* Donacion Pública
	gen        gpctg28= gpcnr4
	gen        gpctg29= (gru13hd1 + gru14hd3+ sig24 +sig26)/(p*mieperho*ld*i01) 
	gen        gpctg30= (gru23hd1)/(p*mieperho*ld*i02) 
	gen        gpctg31= (gru33hd1)/(p*mieperho*ld*i03) 
	gen        gpctg32= (gru43hd1)/(p*mieperho*ld*i04) 
	gen        gpctg33= (gru53hd1)/(p*mieperho*ld*i05) 
	gen        gpctg34= (gru63hd1)/(p*mieperho*ld*i06) 
	gen        gpctg35= (gru73hd1)/(p*mieperho*ld*i07) 
	gen        gpctg36= (gru83hd1)/(p*mieperho*ld*i08) 

	* Donación privada
	gen		gpctg37= gpcnr5
	gen     gpctg38= (gru13hd2 + gru14hd4 + ig06hd)/(p*mieperho*ld*i01) 
	gen     gpctg39= (gru23hd2)/(p*mieperho*ld*i02) 
	gen     gpctg40= (gru33hd2)/(p*mieperho*ld*i03) 
	gen     gpctg41= (gru43hd2 + sg42d1 + sg42d3)/(p*mieperho*ld*i04) 
	gen     gpctg42= (gru53hd2)/(p*mieperho*ld*i05) 
	gen     gpctg43= (gru63hd2 + ig08hd + sg42d2)/(p*mieperho*ld*i06) 
	gen     gpctg44= (gru73hd2 + sg42d)/(p*mieperho*ld*i07) 
	gen     gpctg45= (gru83hd2)/(p*mieperho*ld*i08) 

	* Otro grupo
	gen		gpctg46= gpcnr6
	gen     gpctg47= (gru13hd3 + gru14hd5)/(p*mieperho*ld*i01) 
	gen     gpctg48= (gru23hd3)/(p*mieperho*ld*i02) 
	gen     gpctg49= (gru33hd3)/(p*mieperho*ld*i03) 
	gen     gpctg50= (gru43hd3)/(p*mieperho*ld*i04) 
	gen     gpctg51= (gru53hd3)/(p*mieperho*ld*i05) 
	gen     gpctg52= (gru63hd3)/(p*mieperho*ld*i06) 
	gen     gpctg53= (gru73hd3)/(p*mieperho*ld*i07) 
	gen     gpctg54= (gru83hd3)/(p*mieperho*ld*i08) 


	* Imputado ajustado alquiler vivienda (gru34hd)
	gen         gpctg55= gpcnr7
	gen         gpctg56= (gru24hd)/(p*mieperho*ld*i02) 

	* Alquiler vivienda (gru34hd)
	gen		gpctg57= (gru34hd)/(p*mieperho*ld*i03) 
	gen     gpctg58= (gru44hd)/(p*mieperho*ld*i04) 
	gen     gpctg59= (gru54hd)/(p*mieperho*ld*i05) 
	gen     gpctg60= (gru64hd)/(p*mieperho*ld*i06) 
	gen     gpctg61= (gru74hd)/(p*mieperho*ld*i07) 
	gen     gpctg62= (gru84hd)/(p*mieperho*ld*i08) 
	gen     gpctg0 = gpctg1 + gpctg10 + gpctg19 + gpctg28 + gpctg37 + gpctg46 + gpctg55



	************* Ingresos ****************************************************************.

	gen ipcr_2 = (ingbruhd +ingindhd)/(p*mieperho*ld*i00) 
	gen ipcr_3 = (insedthd + ingseihd + insedthd1)/(p*mieperho*ld*i00) 
	gen ipcr_4 = (pagesphd + paesechd + ingauthd + isecauhd + paesechd1)/(p*mieperho*ld*i00) 
	gen ipcr_5 = (ingexthd)/(p*mieperho*ld*i00) 
	gen ipcr_1 = (ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5)

	gen ipcr_7 = (ingtrahd)/(p*mieperho*ld*i00) 
	gen ipcr_8 = (ingtexhd)/(p*mieperho*ld*i00) 
	gen ipcr_6 = (ipcr_7 + ipcr_8)

	gen ipcr_9  = (ingtprhd)/(p*mieperho*ld*i00) 
	gen ipcr_10 = (ingtpuhd)/(p*mieperho*ld*i00) 
	gen ipcr_11 = (ingtpu01)/(p*mieperho*ld*i00) 
	gen ipcr_12 = (ingtpu03)/(p*mieperho*ld*i00) 
	gen ipcr_13 = (ingtpu05)/(p*mieperho*ld*i00) 
	gen ipcr_14 = (ingtpu04)/(p*mieperho*ld*i00) 
	gen ipcr_15 = (ingtpu02 + ingtpu06 + ingtpu07 + ingtpu08 + ingtpu09 + ingtpu10 + ingtpu11 + ingtpu12 + ingtpu13 + ingtpu14 + ingtpu15 + ingtpu16)/(p*mieperho*ld*i00)
	gen ipcr_16 = (ingrenhd)/(p*mieperho*ld*i00) 
	gen ipcr_17 = (ingoexhd + gru13hd3 + gru23hd3 + gru33hd3 + gru43hd3 + gru53hd3 + gru63hd3 + gru73hd3 + /*
	*/  gru83hd3 + gru24hd +gru44hd + gru54hd + gru74hd + gru84hd + gru14hd5)/(p*mieperho*ld*i00) /*
	*/

	*ajuste por el alquiler imputado
	gen ipcr_18 =(ia01hd +gru34hd - ga04hd + gru64hd)/(p*mieperho*ld*i00) 

	gen ipcr_19 = (gru13hd1 + sig24 + gru23hd1 + gru33hd1 + gru43hd1 + gru53hd1 + gru63hd1 + gru73hd1 + gru83hd1 /* 
	*/+ gru14hd3 + sig26)/(p*mieperho*ld*i00) 

	gen ipcr_20 = (gru13hd2 + ig06hd + gru23hd2 + gru33hd2 + gru43hd2 + gru53hd2 + gru63hd2 + ig08hd + gru73hd2 + /*
	*/ gru83hd2 + gru14hd4 + sg42d + sg42d1 + sg42d2 + sg42d3)/(p*mieperho*ld*i00)/*
	*/ 

	gen  ipcr_0= ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5+ ipcr_7 + ipcr_8 + ipcr_16 + ipcr_17 + ipcr_18 + ipcr_19 + ipcr_20

	label var ipcr_0 "Ingreso percapita mensual a precios de Lima monetario "

	label var ipcr_1 "Ingreso percapita mensual a precios de Lima monetario por trabajo"
	label var ipcr_2 "Ingreso percapita mensual a precios de Lima monetario por trabajo principal"
	label var ipcr_3 "Ingreso percapita mensual a precios de Lima monetario por trabajo secundario"
	label var ipcr_4 "Ingreso percapita mensual a precios de Lima pago en especie y autocon"
	label var ipcr_5 "Ingreso percapita mensual a precios de Lima pago extraordinario por trabajo"
	label var ipcr_6 "Ingreso percapita mensual a precios de Lima transferencia corriente"
	label var ipcr_7 "Ingreso percapita mensual a precios de Lima transferencia monetaria del pais"
	label var ipcr_8 "Ingreso percapita mensual a precios de Lima transferencia monetaria extranjero"
	label var ipcr_9  "Ingreso percapita mensual a precios de Lima transferencia monetaria privada"
	label var ipcr_10 "Ingreso percapita mensual a precios de Lima transferencia monetaria Publica total"
	label var ipcr_11 "Ingreso percapita mensual a precios de Lima transferencia monetaria Publica Juntos"
	label var ipcr_12 "Ingreso percapita mensual a precios de Lima transferencia monetaria Publica Pensión65"
	label var ipcr_13 "Ingreso percapita mensual a precios de Lima transferencia monetaria Bono Gas"
	label var ipcr_14 "Ingreso percapita mensual a precios de Lima transferencia monetaria Beca 18"
	label var ipcr_15 "Ingreso percapita mensual a precios de Lima transferencia monetaria Otros Publica"
	label var ipcr_16 "Ingreso percapita mensual a precios de Lima renta"
	label var ipcr_17 "Ingreso percapita mensual a precios de Lima extraordinario"
	label var ipcr_18 "Ingreso percapita mensual a precios de Lima alquiler imputado"
	label var ipcr_19 "Ingreso percapita mensual a precios de Lima donacion publica"
	label var ipcr_20 "Ingreso percapita mensual a precios de Lima donacion privada"

	*** Ingreso real promedio percapita mensual ***

	svy:mean ipcr_0, over(aniorec)
	svy:mean ipcr_0 if aniorec==2018, over(area)
	svy:mean ipcr_0 if aniorec==2018, over(domin02)
	svy:mean ipcr_0 if aniorec==2018, over(dpto)

	*Generando deciles y quintiles de gasto
	gen quintil_g=.
	gen quintil_i=.
	foreach x of numlist 2007/2019{
	xtile quintil_g`x'=gpgru0 if año==`x' [pweight = factornd07], nq(5)
	replace quintil_g=quintil_g`x' if año==`x' 
	xtile quintil_i`x'=ipcr_0 if año==`x' [pweight = factornd07], nq(5)
	replace quintil_i=quintil_i`x' if año==`x' 

	}

	gen decil_g=.
	gen decil_i=.
	foreach x of numlist 2007/2019{
	xtile decil_g`x'=gpgru0 if año==`x' [pweight = factornd07], nq(10)
	replace decil_g=decil_g`x' if año==`x' 
	xtile decil_i`x'=ipcr_0 if año==`x' [pweight = factornd07], nq(10)
	replace decil_i=decil_i`x' if año==`x' 
}

	
	*** Salidas ***

	*** Gasto real promedio percapita mensual***
	table area año [iw=factornd07], stat(mean gpgru0) 
	table domin02 aniorec [iw=factornd07], stat(mean gpgru0) 
	table dpto aniorec [iw=factornd07], stat(mean gpgru0) 


	*** Ingreso real promedio percapita mensual ***
	table area aniorec [iw=factornd07], stat(mean ipcr_0) nformat(%6.0fc)
	table domin02 aniorec [iw=factornd07], stat(mean ipcr_0) nformat(%6.0g)
	table dpto aniorec [iw=factornd07], stat(mean ipcr_0) nformat(%6.0g)

	drop pobrezav lineav
	merge 1:1 año conglome vivienda hogar using "$bd\base_variables_pobreza_vulnerabilidad-2007-2022.dta", keepusing(pobrezav lineav) 
	drop if _m==2
	drop _merge
	
	*** Gasto e ingreso real promedio percapita mensual urbano según vulnerabilidad***
	table pobrezav año if area ==1  [iw=factornd07], stat(mean gpgru0) nformat(%6.0fc)
	table pobrezav año if area ==1  [iw=factornd07], stat(mean ipcr_0) nformat(%6.0fc)
	
	save "$temp\sumaria.dta", replace
}
