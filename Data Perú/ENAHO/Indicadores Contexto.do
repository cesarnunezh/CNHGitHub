/*******************************************************************************
Proyecto: UNICEF - Niñas, niños y adolescentes
Objetivo: Cálculo de indicadores del Capítulo 1 - Contexto
Autores:  MG - CN

Objetivo: 	Realizar el cálculo de los indicadores del contexto donde se desenvuelven
			las niñas, niños y adolescentes.

Estructura:
	0. Direcciones
    1. Compilado de años para las bases de datos
	2. Ratio de dependencia
		
*******************************************************************************/

* 0. Direcciones

/*global base1 "D:\1. Documentos\0. Bases de datos\2. ENAHO\1. Data"
global out1 "D:\1. Documentos\0. Bases de datos\2. ENAHO\3. Output"
global temp "D:\1. Documentos\0. Bases de datos\2. ENAHO\2. Temp"
*/
	global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\1. Data"
	global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\2. Temp"
	global output "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\02. ENAHO\3. Output"

**********************************************************************************************
* 1. Compilado de años para las bases de datos
   *Módulo 100
{   
	global var_1 "conglome vivienda hogar ubigeo estrato dominio nbi* p104* p1121 p103 p110 p111* p113* p1141 p1142 p1143 p1144 p1145 dominio fac* a?o"
	use "$base1\enaho01-2007-100.dta", clear
	keep $var_1
	gen año=2007
	forvalues i= 2008/2022{
    append using "$base1\enaho01-`i'-100.dta", keep($var_1)
    replace año=`i' if año==.
	}
	replace p111a=p111 if p111a==.
	destring conglome, replace
	tostring conglome, replace format(%06.0f)

	save "$temp\modulo100.dta", replace
	
   *Módulo 2 
	global var_2 "conglome vivienda hogar codperso estrato dominio ubigeo p20* facpob07"
	use "$base1\enaho01-2007-200.dta", clear
	keep $var_2
	gen año=2007
	forvalues i= 2008/2022{
    append using "$base1\enaho01-`i'-200.dta", keep($var_2) force
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)

	save "$temp\modulo200.dta", replace

   *Módulo 3 
	global var_3 "conglome vivienda hogar codperso estrato dominio ubigeo p20* p301* p303 p306 p307 p310 p300a fac*"
	use "$base1\enaho01a-2007-300.dta", clear
	keep $var_3
	gen año=2007
	forvalues i= 2008/2019{
    append using "$base1\enaho01a-`i'-300.dta", keep($var_3) force
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo300.dta", replace
	
	*Módulo 4
	global var_4 "conglome vivienda hogar codperso estrato dominio ubigeo p401  p4021 p4022 p4023 p4024 p4025 p4031-p40314 p4091-p40911 p4151_* p4152_* p4153_* p4154_* p417_02 p417_08 p417_11 p417_12 p417_13 p417_14 p419* i416* p419* p2* fac*"
	use "$base1\enaho01a-2007-400.dta", clear
	keep $var_4
	gen año=2007
	forvalues i= 2008/2019{
    append using "$base1\enaho01a-`i'-400.dta", force keep($var_4)
	replace año=`i' if año==.
    }
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo400.dta", replace
	
	*Módulo 5
	global var_5 "conglome vivienda hogar codperso estrato dominio ubigeo p20* p301a p505* p506* p507 p512* p513t i513t i518 i520 p517* p518 p520 fac500a ocu500 ocupinf i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t"
	use "$base1\enaho01a-2007-500.dta", clear
	keep $var_5
	gen año=2007
	forvalues i= 2008/2019{
    append using "$base1\enaho01a-`i'-500.dta", keep($var_5) force
	replace año=`i' if año==.
    }
	replace fac500a=fac500a7 if año==2011
	destring conglome, replace
	tostring conglome, replace format(%06.0f)
	save "$temp\modulo500.dta", replace
	
	{														/*Solo es para minimizar el codigo de sumarias*/
	*Sumaria
	use "$base1\sumaria-2007.dta", clear
	gen año=2007
	forvalues i= 2008/2022{
    append using "$base1\sumaria-`i'.dta"
	replace año=`i' if año==.
    }

	destring conglome, replace
	tostring conglome, replace format(%06.0f)

	recode gru52hd2-gashog2d (.= 0)
	recode ingtpu01 ingtpu02 ingtpu03 ingtpu04 ingtpu05 ig03hd1 ig03hd2 ig03hd3 ig03hd4 (.= 0)

	gen aniorec=año
	gen dpto= real(substr(ubigeo,1,2))
	replace dpto=15 if (dpto==7)
	label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" /*
	*/12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" /*
	*/23"Tacna" 24"Tumbes" 25"Ucayali" 
	lab val dpto dpto 

	sort aniorec dpto
	merge aniorec dpto using "D:\1. Documentos\0. Bases de datos\2. ENAHO\0. Documentación\Gasto2019\Bases\deflactores_base2019_new.dta"
	tab _m
	drop if _merge==2
	drop _m

	replace estrato = 1 if dominio ==8 
	gen area = estrato <7
	replace area=2 if area==0
	label define area 2 rural 1 urbana
	label val area area


	**REGION NATURAL*
	gen domin02=1 if dominio>=1 & dominio<=3 & area==1
	replace domin02=2 if dominio>=1 & dominio<=3 & area==2
	replace domin02=3 if dominio>=4 & dominio<=6 & area==1
	replace domin02=4 if dominio>=4 & dominio<=6 & area==2
	replace domin02=5 if dominio==7 & area==1
	replace domin02=6 if dominio==7 & area==2
	replace domin02=7 if dominio==8

	label define domin02 1 "Costa_urbana" 2 "Costa_rural" 3 "Sierra_urbana" 4 "Sierra_rural" 5 "Selva_urbana" 6 "Selva_rural" 7 "Lima_Metropolitana"
	label value domin02 domin02

	gen region=1 if dominio>=1 & dominio<=3 
	replace region=1 if dominio==8
	replace region=2 if dominio>=4 & dominio<=6 
	replace region=3 if dominio==7 

	label define region 1 "Costa" 2 "Sierra" 3 "Selva"

	gen areag = dominio == 8
	replace areag = 2 if dominio >= 1 & dominio <= 7 & estrato >= 1 & estrato <= 5
	replace areag = 3 if dominio >= 1 & dominio <= 7 & estrato >= 6 & estrato <= 8
	lab define areag 1 "Lima_Metro" 2 "Resto_Urbano" 3 "Rural" 
	label values areag  areag

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

	merge dominioA using "D:\1. Documentos\0. Bases de datos\2. ENAHO\0. Documentación\Gasto2019\Bases\despacial_ldnew.dta"
	tab _m
	drop _m

	gen factornd07=round(factor07*mieperho,1)

	recode dpto (1=24) (2=10)(3=17) (4=9)(5=18) (6=16)(8=12) (9=19) (10=15) (11=6)(12=11) (13=3)(14=7) (15=1)(16=23) /*
	*/(17=20) (18=4)(19=14) (20=8)(21=13)(22=22)(23=2)(24=5)(24=5)(25=21), gen(recdpto)
	label define recdpto 1 "Lima" 2 "Tacna" 3 "La Libertad" 4 "Moquega" 5 "Tumbes" 6 "Ica" 7 "Lambayeque" 8 "Piura" 9 "Arequipa" 10 "Ancash" /*
	*/ 11"Junín" 12 "Cusco" 13 "Puno" 14 "Pasco" 15 "Huanuco" 16 "Cajamarca" 17 "Apurimac" 18 "Ayacucho" 19 "Huancavelica"/*
	*/ 20 "Madre de Dios" 21 "Ucayali" 22 "San Martín" 23 "Loreto"24 "Amazonas"
	label val  recdpto recdpto

	gen limareg=1 if(substr(ubigeo,1,4))=="1501"
	replace limareg=2 if(substr(ubigeo,1,2))=="07"
	replace limareg=3 if((substr(ubigeo,1,4))>="1502" & (substr(ubigeo,1,4))<"1599")

	label define limareg 1 "Lima Prov" 2 "Prov Const. Callao" 3 "Región Lima"
	label val limareg limareg

	svyset [pweight = factornd07], psu(conglome)


	*GASTOS REALES
	***************************************************************************/
	***CREANDO VARIABLES DEL GASTO DEFLACTADO A PRECIOS DE LIMA Y BASE 2019****/
	***************************************************************************/
	******Gasto por 8  grupos de la canastas************
		
	gen 		gpcrg3= (gru11hd + gru12hd1 + gru12hd2 + gru13hd1 + gru13hd2 + gru13hd3 )/(12*mieperho*ld*i01)
	gen 		gpcrg6 = ((g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 +g05hd6 +ig06hd)/(12*mieperho*ld*i01))
	gen 		gpcrg8= ((sg23 + sig24)/(12*mieperho*ld*i01))
	gen 		gpcrg9= ((gru14hd + gru14hd1 +  gru14hd2 + gru14hd3 + gru14hd4 + gru14hd5 + sg25 + sig26)/(12*mieperho*ld*i01))
	gen    		gpcrg10= ((gru21hd + gru22hd1 + gru22hd2 + gru23hd1 + gru23hd2 + gru23hd3 + gru24hd)/(12*mieperho*ld*i02))
	gen     	gpcrg12= ((gru31hd + gru32hd1 + gru32hd2 + gru33hd1 + gru33hd2 + gru33hd3 + gru34hd)/(12*mieperho*ld*i03))
	gen     	gpcrg14= ((gru41hd + gru42hd1 + gru42hd2 + gru43hd1 + gru43hd2 + gru43hd3 + gru44hd + sg421 + sg42d1 + sg423 + sg42d3)/(12*mieperho*ld*i04))
	gen    		gpcrg16= ((gru51hd + gru52hd1 + gru52hd2 + gru53hd1 + gru53hd2 + gru53hd3 + gru54hd)/(12*mieperho*ld*i05))
	gen     	gpcrg18= ((gru61hd + gru62hd1 + gru62hd2 + gru63hd1 + gru63hd2 + gru63hd3 + gru64hd + g07hd + ig08hd + sg422 + sg42d2)/(12*mieperho*ld*i06))
	gen     	gpcrg19= ((gru71hd + gru72hd1 + gru72hd2 + gru73hd1 + gru73hd2 + gru73hd3 + gru74hd + sg42 + sg42d)/(12*mieperho*ld*i07))
	gen     	gpcrg21= ((gru81hd + gru82hd1 + gru82hd2 + gru83hd1 + gru83hd2 + gru83hd3 + gru84hd)/(12*mieperho*ld*i08))

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

	gen   	  	gpcnr1 =(((gru11hd +gru14hd + sg23 + g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 + g05hd6  +sg25)/(12*mieperho *  ld*i01))/*
						*/ + (gru21hd/(12*mieperho *  ld*i02)) + /*
						*/ (gru31hd/(12*mieperho *  ld*i03)) + ((gru41hd + sg421 + sg423)/(12*mieperho *  ld*i04)) + /*
						*/ (gru51hd/(12*mieperho *  ld*i05)) + ((gru61hd + g07hd + sg422)/(12*mieperho *  ld*i06)) + /*
						*/ ((gru71hd + sg42)/(12*mieperho *  ld*i07)) + (gru81hd/(12*mieperho *  ld*i08)))

	gen     	gpcnr2 =(((gru12hd1 + gru14hd1)/(12*mieperho *  ld*i01)) + (gru22hd1/(12*mieperho *  ld*i02)) + /*
						*/ (gru32hd1/(12*mieperho *  ld*i03)) + (gru42hd1/(12*mieperho *  ld*i04)) + /*
						*/ (gru52hd1/(12*mieperho *  ld*i05)) + (gru62hd1/(12*mieperho *  ld*i06)) + /*
						*/ (gru72hd1/(12*mieperho *  ld*i07)) + (gru82hd1/(12*mieperho *  ld*i08)))
						
	gen     	gpcnr3 = (((gru12hd2 + gru14hd2)/(12*mieperho *  ld*i01)) + (gru22hd2/(12*mieperho *  ld*i02)) + /*
						*/ (gru32hd2/(12*mieperho *  ld*i03)) + (gru42hd2/(12*mieperho *  ld*i04)) + /*
						*/ (gru52hd2/(12*mieperho *  ld*i05)) + (gru62hd2/(12*mieperho *  ld*i06)) + /*
						*/ (gru72hd2/(12*mieperho *  ld*i07)) + (gru82hd2/(12*mieperho *  ld*i08)))
						
	gen    		gpcnr4 =(((gru13hd1 + gru14hd3+ sig24 +sig26)/(12*mieperho *  ld*i01)) + (gru23hd1/(12*mieperho *  ld*i02)) + /*
						*/ (gru33hd1/(12*mieperho *  ld*i03)) + (gru43hd1/(12*mieperho *  ld*i04)) + /*
						*/ (gru53hd1/(12*mieperho *  ld*i05)) + (gru63hd1/(12*mieperho *  ld*i06)) + /*
						*/ (gru73hd1/(12*mieperho *  ld*i07)) + (gru83hd1/(12*mieperho *  ld*i08)))
						
	gen     	gpcnr5 =(((gru13hd2 + gru14hd4 + ig06hd)/(12*mieperho *  ld*i01)) + (gru23hd2/(12*mieperho *  ld*i02)) + /*
						*/ (gru33hd2/(12*mieperho *  ld*i03)) + ((gru43hd2 + sg42d1 + sg42d3)/(12*mieperho *  ld*i04)) + /*
						*/ (gru53hd2/(12*mieperho *  ld*i05)) + ((gru63hd2 +ig08hd + sg42d2)/(12*mieperho *  ld*i06)) + /*
						 */ ((gru73hd2 + sg42d)/(12*mieperho *  ld*i07)) + (gru83hd2/(12*mieperho *  ld*i08)))
					
	gen   		  gpcnr6 =(((gru13hd3 + gru14hd5)/(12*mieperho *  ld*i01)) + (gru23hd3/(12*mieperho *  ld*i02)) + /*
						*/ (gru33hd3/(12*mieperho *  ld*i03)) + (gru43hd3/(12*mieperho *  ld*i04)) + /*
						*/ (gru53hd3/(12*mieperho *  ld*i05)) + (gru63hd3/(12*mieperho *  ld*i06)) + /*
						*/ (gru73hd3/(12*mieperho *  ld*i07)) + (gru83hd3/(12*mieperho *  ld*i08)))
						
	gen   		 gpcnr7 =((gru24hd/(12*mieperho *  ld*i02)) + (gru34hd/(12*mieperho *  ld*i03)) + /*
						*/ (gru44hd/(12*mieperho *  ld*i04)) + (gru54hd/(12*mieperho *  ld*i05)) + /*
						*/ (gru64hd/(12*mieperho *  ld*i06)) + (gru74hd/(12*mieperho *  ld*i07)) + /*
						*/ (gru84hd/(12*mieperho *  ld*i08)))

						
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
	gen        gpctg2= (gru11hd + gru14hd + sg23 + g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 + g05hd6  +sg25)/(12*mieperho*ld*i01)
	gen        gpctg3= (gru21hd)/(12*mieperho*ld*i02)
	gen        gpctg4= (gru31hd)/(12*mieperho*ld*i03)
	gen        gpctg5= (gru41hd + sg421 + sg423)/(12*mieperho*ld*i04)
	gen        gpctg6= (gru51hd)/(12*mieperho*ld*i05)
	gen        gpctg7= (gru61hd + g07hd + sg422)/(12*mieperho*ld*i06)
	gen        gpctg8= (gru71hd + sg42)/(12*mieperho*ld*i07)
	gen        gpctg9= (gru81hd)/(12*mieperho*ld*i08)

	recode gpctg2 gpctg3 gpctg4 gpctg5 gpctg5 gpctg6 gpctg7 gpctg7 gpctg8 gpctg9(.=0)


	*Autoconsumo (ajustado alquiler de vivienda)
	gen        gpctg10= gpcnr2
	gen        gpctg11= (gru12hd1 + gru14hd1)/(12*mieperho*ld*i01)
	gen        gpctg12= (gru22hd1)/(12*mieperho*ld*i02)
	gen        gpctg13= (gru32hd1)/(12*mieperho*ld*i03)
	gen        gpctg14= (gru42hd1)/(12*mieperho*ld*i04)
	gen        gpctg15= (gru52hd1)/(12*mieperho*ld*i05)
	gen        gpctg16= (gru62hd1)/(12*mieperho*ld*i06)
	gen        gpctg17= (gru72hd1)/(12*mieperho*ld*i07)
	gen        gpctg18= (gru82hd1)/(12*mieperho*ld*i08)

	* Pago en especie
	gen        gpctg19= gpcnr3
	gen        gpctg20= (gru12hd2 + gru14hd2)/(12*mieperho*ld*i01)
	gen        gpctg21= (gru22hd2)/(12*mieperho*ld*i02)
	gen        gpctg22= (gru32hd2)/(12*mieperho*ld*i03)
	gen        gpctg23= (gru42hd2)/(12*mieperho*ld*i04)
	gen        gpctg24= (gru52hd2)/(12*mieperho*ld*i05)
	gen        gpctg25= (gru62hd2)/(12*mieperho*ld*i06)
	gen        gpctg26= (gru72hd2)/(12*mieperho*ld*i07)
	gen        gpctg27= (gru82hd2)/(12*mieperho*ld*i08)

	* Donacion Pública
	gen        gpctg28= gpcnr4
	gen        gpctg29= (gru13hd1 + gru14hd3+ sig24 +sig26)/(12*mieperho*ld*i01)
	gen        gpctg30= (gru23hd1)/(12*mieperho*ld*i02)
	gen        gpctg31= (gru33hd1)/(12*mieperho*ld*i03)
	gen        gpctg32= (gru43hd1)/(12*mieperho*ld*i04)
	gen        gpctg33= (gru53hd1)/(12*mieperho*ld*i05)
	gen        gpctg34= (gru63hd1)/(12*mieperho*ld*i06)
	gen        gpctg35= (gru73hd1)/(12*mieperho*ld*i07)
	gen        gpctg36= (gru83hd1)/(12*mieperho*ld*i08)

	* Donación privada
	gen		gpctg37= gpcnr5
	gen     gpctg38= (gru13hd2 + gru14hd4 + ig06hd)/(12*mieperho*ld*i01)
	gen     gpctg39= (gru23hd2)/(12*mieperho*ld*i02)
	gen     gpctg40= (gru33hd2)/(12*mieperho*ld*i03)
	gen     gpctg41= (gru43hd2 + sg42d1 + sg42d3)/(12*mieperho*ld*i04)
	gen     gpctg42= (gru53hd2)/(12*mieperho*ld*i05)
	gen     gpctg43= (gru63hd2 + ig08hd + sg42d2)/(12*mieperho*ld*i06)
	gen     gpctg44= (gru73hd2 + sg42d)/(12*mieperho*ld*i07)
	gen     gpctg45= (gru83hd2)/(12*mieperho*ld*i08)

	* Otro grupo
	gen		gpctg46= gpcnr6
	gen     gpctg47= (gru13hd3 + gru14hd5)/(12*mieperho*ld*i01)
	gen     gpctg48= (gru23hd3)/(12*mieperho*ld*i02)
	gen     gpctg49= (gru33hd3)/(12*mieperho*ld*i03)
	gen     gpctg50= (gru43hd3)/(12*mieperho*ld*i04)
	gen     gpctg51= (gru53hd3)/(12*mieperho*ld*i05)
	gen     gpctg52= (gru63hd3)/(12*mieperho*ld*i06)
	gen     gpctg53= (gru73hd3)/(12*mieperho*ld*i07)
	gen     gpctg54= (gru83hd3)/(12*mieperho*ld*i08)


	* Imputado ajustado alquiler vivienda (gru34hd)
	gen     gpctg55= gpcnr7
	gen     gpctg56= (gru24hd)/(12*mieperho*ld*i02)

	* Alquiler vivienda (gru34hd)
	gen		gpctg57= (gru34hd)/(12*mieperho*ld*i03)
	gen     gpctg58= (gru44hd)/(12*mieperho*ld*i04)
	gen     gpctg59= (gru54hd)/(12*mieperho*ld*i05)
	gen     gpctg60= (gru64hd)/(12*mieperho*ld*i06)
	gen     gpctg61= (gru74hd)/(12*mieperho*ld*i07)
	gen     gpctg62= (gru84hd)/(12*mieperho*ld*i08)
	gen     gpctg0 = gpctg1 + gpctg10 + gpctg19 + gpctg28 + gpctg37 + gpctg46 + gpctg55



	************* Ingresos ****************************************************************.

	gen ipcr_2 = (ingbruhd +ingindhd)/(12*mieperho*ld*i00)
	gen ipcr_3 = (insedthd + ingseihd)/(12*mieperho*ld*i00)
	gen ipcr_4 = (pagesphd + paesechd + ingauthd + isecauhd)/(12*mieperho*ld*i00)
	gen ipcr_5 = (ingexthd)/(12*mieperho*ld*i00)
	gen ipcr_1 = (ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5)

	gen ipcr_7 = (ingtrahd)/(12*mieperho*ld*i00)
	gen ipcr_8 = (ingtexhd)/(12*mieperho*ld*i00)
	gen ipcr_6 = (ipcr_7 + ipcr_8)

	gen ipcr_9  = (ingtprhd)/(12*mieperho*ld*i00)
	gen ipcr_10 = (ingtpuhd)/(12*mieperho*ld*i00)
	gen ipcr_11 = (ingtpu01)/(12*mieperho*ld*i00)
	gen ipcr_12 = (ingtpu03)/(12*mieperho*ld*i00)
	gen ipcr_13 = (ingtpu05)/(12*mieperho*ld*i00)
	gen ipcr_14 = (ingtpu04)/(12*mieperho*ld*i00)
	gen ipcr_15 = (ingtpu02)/(12*mieperho*ld*i00)
	gen ipcr_16 = (ingrenhd)/(12*mieperho*ld*i00)
	gen ipcr_17 = (ingoexhd + gru13hd3 + gru23hd3 + gru33hd3 + gru43hd3 + gru53hd3 + gru63hd3 + gru73hd3 + /*
	*/  gru83hd3 + gru24hd +gru44hd + gru54hd + gru74hd + gru84hd + gru14hd5)/(12*mieperho*ld*i00)

	*ajuste por el alquiler imputado
	gen ipcr_18 =(ia01hd +gru34hd - ga04hd + gru64hd)/(12*mieperho*ld*i00)

	gen ipcr_19 = (gru13hd1 + sig24 + gru23hd1 + gru33hd1 + gru43hd1 + gru53hd1 + gru63hd1 + gru73hd1 + gru83hd1 /* 
	*/+ gru14hd3 + sig26)/(12*mieperho*ld*i00)

	gen ipcr_20 = (gru13hd2 + ig06hd + gru23hd2 + gru33hd2 + gru43hd2 + gru53hd2 + gru63hd2 + ig08hd + gru73hd2 + /*
	*/ gru83hd2 + gru14hd4 + sg42d + sg42d1 + sg42d2 + sg42d3)/(12*mieperho*ld*i00)

	gen  ipcr_0= ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5+ ipcr_7 + ipcr_8 + ipcr_16 + ipcr_17 + ipcr_18 + ipcr_19 + ipcr_20

	label var ipcr_0 "Ingreso percapita mensual a precios de Lima monetario"
	
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
	
	*** Salidas ***

	svyset [pweight = factornd07], psu(conglome)strata(estrato)

	*** Gasto real promedio percapita mensual***

	svy:mean gpgru0, over(aniorec)
	svy:mean gpgru0 if aniorec==2018, over(area)
	svy:mean gpgru0 if aniorec==2018, over(domin02)
	svy:mean gpgru0 if aniorec==2018, over(dpto)


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

	table decil_g aniorec [pweight = factornd07], c(mean gpgru0 ) format(%5.0fc)	/*Revisar si sale igual al Informe anual de Pobreza del INEI*/
	}
	
	save "$temp\sumaria.dta", replace
}
**********************************************************************************************
* 2. RATIO DE DEPENDENCIA
{
use "$temp\modulo200.dta", clear
gen pob_dependiente = inrange(p208a,15,64)
gen pob_trabajador= pob_dependiente
replace pob_dependiente = cond(pob_dependiente==1,0,1)
gen pob_dep_joven= cond(p208a<15,1,0)
gen pob_dep_mayor= cond(p208a>64,1,0)

destring ubigeo, replace
gen dpto=int(ubigeo/10000)
replace dpto=26 if dpto==15 & dominio!=8

label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
*/ 25 "Ucayali" 26 "Lima Provincias"

label values dpto dpto

gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

*Tabla general
preserve
collapse (sum) pob_dependiente pob_trabajador pob_dep_joven pob_dep_mayor if filtro==1 [iw=facpob07], by(año)
gen ratio_dep=pob_dependiente/pob_trabajador*100
gen ratio_dep_joven=pob_dep_joven/pob_trabajador*100
gen ratio_dep_mayor=pob_dep_mayor/pob_trabajador*100
export excel using "$out1/datos", sheet("ratio_dependencia") sheetreplace firstrow(variables)
restore

*Tabla por departamento
preserve
collapse (sum) pob_dependiente pob_trabajador pob_dep_joven pob_dep_mayor if filtro==1 [iw=facpob07], by(dpto año)
gen ratio_dep=pob_dependiente/pob_trabajador*100
gen ratio_dep_joven=pob_dep_joven/pob_trabajador*100
gen ratio_dep_mayor=pob_dep_mayor/pob_trabajador*100
keep ratio_dep dpto año
reshape wide ratio_dep, i(dpto) j(año)
export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A17)
restore

*Población menor a 17 años
preserve
collapse (sum) filtro if filtro==1 [iw=facpob07], by(grupo_edad año)
reshape wide filtro, i(grupo_edad) j(año)
rename filtro* a*
export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A47)
restore

*Población menor a 17 años por departamento
preserve
gen nna=(grupo_edad<4)
collapse (sum) filtro nna if filtro==1 [iw=facpob07], by(dpto año)
reshape wide filtro nna, i(dpto) j(año)
order dpto nna* filtro*
export excel using "$out1/datos", sheet("ratio_dependencia") sheetmodify firstrow(variables) cell(A57)
restore
}
************************************************************************************************
*3. POBLACIÓN ECONÓMICAMENTE OCUPADA
{
use "$temp\modulo500.dta", clear

merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(quintil* pobre*)
drop if _m==2

* Se genera la variable de población ocupada
gen ocupada = cond(ocu500==1,1,0)
gen pea= cond(ocu500<3 & ocu500!=0,1,cond(ocu500==.,.,0))

destring ubigeo, replace
gen dpto=int(ubigeo/10000)
replace dpto=26 if dpto==15 & dominio!=8
label drop dpto
label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
*/ 25 "Ucayali" 26 "Lima Provincias"
label values dpto dpto

gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

recode p507 (1=1) (3 4 = 2) (2=3) (5=4) (6=5) (7=6), gen(categoria)
label define tipo 1 "empleador" 2 "asalariado" 3 "independiente" 4 "Trabajador familiar no remunerado" 5 "Trabajador del hogar" 6 "Otro"
label values categoria tipo

recode p208a (14/24 =1) (25/44 =3) (45/64 =4) (nonmissing=5), gen(grupo_edad)
label define grupo_edad 1 "14-24 años" 3 "25-44 años" 4 "45-64 años" 5 "65 años a más"
label val grupo_edad grupo_edad

gen area = estrato <6
label drop area
label define area 0 rural 1 urbana
label val area area

recode p512a (1 2 =2) (3 4 5=3),gen(tama)
replace tama=1 if p512b<=10
label define tama 1 "Menos de 10 trabajadores" 2 "Entre 11 y 50 trabajadores" 3 "Más de 50 trabajadores"
label val tama tama

recode i513t (0/30=1) (31/40=2) (41/50=3) (51/70=4) (nonmissing=5), gen(horasem)
label define horasem 1 "Menos de 31 horas" 2 "Entre 31 y 40 horas" 3 "Entre 41 y 50 horas" 4 "Entre 51 y 70 horas" 5 "De 71 a más horas"
label val horasem horasem

*Tabla general
preserve
collapse (sum) ocupada pea (count) ocu500 if filtro==1 [iw=fac500a], by(año)
gen tasa_desempleo=100-ocupada/pea*100
gen tasa_actividad=pea/ocu500*100
export excel using "$out1/datos", sheet("PEA Ocupada") sheetreplace firstrow(variables) 
restore

*Tabla por departamento
preserve
collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(dpto año)
gen tasa_desempleo=100-ocupada/pea*100
keep tasa_desempleo dpto año
reshape wide tasa_desempleo, i(dpto) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A17)
restore

*Tabla por sexo
preserve
collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(p207 año)
gen tasa_desempleo=100-ocupada/pea*100
drop pea
reshape wide tasa_desempleo ocupada , i(p207) j(año)
order p207 ocupada* tasa_desempleo*
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A46)
restore

*Tabla por categoria de empleo
preserve
collapse (sum) ocupada if filtro==1 [iw=fac500a] , by(categoria año)
reshape wide ocupada, i(categoria) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A54)
restore

*Empleo informal
preserve
collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf año)
reshape wide ocupada, i(ocupinf) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A65)
restore

*Empleo informal por grupos de edad
preserve
collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf grupo_edad año)
reshape wide ocupada, i(ocupinf grupo_edad) j(año)
rename (ocupada*) (a*) 
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A69)
restore

*Empleo informal por sexo
preserve
collapse (sum) ocupada if filtro==1 & ocu500==1 [iw=fac500a], by(ocupinf p207 año)
reshape wide ocupada, i(ocupinf p207) j(año)
rename (ocupada*) (a*) 
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A83)
restore


*Tabla por area de residencia
preserve
collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(area año)
gen tasa_desempleo=100-ocupada/pea*100
drop pea
reshape wide tasa_desempleo ocupada , i(area) j(año)
order area ocupada* tasa_desempleo*
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A90)
restore

*Tabla por grupos de edad
preserve
collapse (sum) ocupada pea if filtro==1 [iw=fac500a], by(grupo_edad año)
gen tasa_desempleo=100-ocupada/pea*100
drop pea
reshape wide tasa_desempleo ocupada, i(grupo_edad) j(año)
order grupo_edad ocupada* tasa_desempleo*
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A98)
restore

*PEAO por tamaño de empresa
preserve
collapse (sum) ocupada if filtro==1 [iw=fac500a], by(tama año)
reshape wide  ocupada, i(tama) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A108)
restore

*PEAO por horas semanales
preserve
collapse (sum) ocupada if filtro==1 [iw=fac500a], by(horasem año)
reshape wide  ocupada, i(horasem) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A115)
restore

*PEAO por acceso a seguro de salud
preserve
merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo400.dta", keepusing(p419*)
drop if _merge==2

replace p4199= cond(p4191==2 & p4192==2 & p4193==2 & p4194==2 & p4195==2 & p4196==2 & p4197==2 & p4198==2, 1,cond(p4191==. & p4192==. & p4193==. & p4194==. & p4195==. & p4196==. & p4197==. & p4198==.,.,0)) if (p4199==. & (año!=2007 | año!=2008 | año!=2009 | año!=2010 | año!=2011))

gen essalud=cond(p4191==1,100,cond(p4191==.,.,0))	
gen privado=cond(p4192==1,100,cond(p4192==.,.,0))	
gen eps=cond(p4193==1,100,cond(p4193==.,.,0))	
gen ffaaffpp=cond(p4194==1,100,cond(p4194==.,.,0))	
gen sis=cond(p4195==1,100,cond(p4195==.,.,0))	
gen univ=cond(p4196==1,100,cond(p4196==.,.,0))	
gen escolar=cond(p4197==1,100,cond(p4197==.,.,0))	
gen otro=cond(p4198==1,100,cond(p4198==.,.,0))	
gen ninguno=cond(p4199==1,100,cond(p4199==.,.,0))	

collapse (mean) essalud privado eps ffaaffpp sis univ escolar otro ninguno if filtro==1 & ocupada==1 [iw=fac500a], by(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A124)
restore

*Informalidad por quintiles de ingreso
preserve
replace ocupinf=0 if ocupinf==2
replace ocupinf=100 if ocupinf==1
collapse (mean) ocupinf if filtro==1 [iw=fac500a], by(quintil_i año)
reshape wide  ocupinf, i(quintil_i) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A139)
restore

*Informalidad por nivel de educación
preserve
replace ocupinf=0 if ocupinf==2
replace ocupinf=100 if ocupinf==1
recode p301a (1/3=1) (4/5=2) (6 7 9 =3) (8=4) (10=5) (11=6) (12=7) (99=.), gen(edu_max)
label define edu_max 1 "Sin nivel o inicial" 2 "Primaria" 3 "Secundaria" 4 "Sup. No Universitaria" 5 "Sup. Universitaria" 6 "Post-grado" 7 "Básica especial"
label val edu_max edu_max
collapse (mean) ocupinf if filtro==1 [iw=fac500a], by(edu_max año)
reshape wide  ocupinf, i(edu_max) j(año)
export excel using "$out1/datos", sheet("PEA Ocupada") sheetmodify firstrow(variables) cell(A147)
restore


*INDICADORES DE GÉNERO
*Mujeres en cargos populares

	use "$temp\modulo500.dta", clear
	
	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	*Generamos la variable mujer
	gen mujer=cond(p207==2,100,cond(p207==.,.,0))

	*Generamos la variable cargo directivo
	recode p505 (111/148=1) (nonmissing=0), gen(cargo_directivo)
	recode p505r4 (1100/1499=1) (nonmissing=0), gen(cargo_directivo1)
	
	preserve
	collapse (mean) mujer if filtro==1 & cargo_directivo==1 [iw=fac500a], by(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetreplace firstrow(variables) 
	restore

	preserve
	collapse (mean) mujer if filtro==1 & cargo_directivo1==1 [iw=fac500a], by(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(D1)
	restore

*Proporción del ingreso real de las mujeres respecto al de los hombres

	**A continuación, limpiamos las variables de las fuentes de ingresos
	recode i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t (.=0)
	**Con las variables limpias, obtenemos el ingreso anual total proveniente del trabajo. Luego lo hacemos mensual e incluimos las etiquetas a las nuevas variables:
	egen ingtrabw = rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
	gen ingtram=ingtrabw/(12)
	label var ingtrabw "Ingreso por trabajo anual"
	label var ingtram "Ingreso por trabajo mensual"
	
	**Finalmente, calculamos el ingreso promedio mensual proveniente del trabajo por sexo
   	preserve
	collapse (mean) ingtram if filtro==1 & ocu500==1 & ingtram>0 [iw=fac500a], by(p207 año)
	reshape wide ingtram, i(p207) j(año)
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(A16)
	restore

	**Ingreso promedio mensual proveniente del trabajo por sexo por niveles de educación
   	recode p301a (1/3=1) (4/5=2) (6 7 9 =3) (8=4) (10=5) (11=6) (12=7) (99=.), gen(edu_max)
	label define edu_max 1 "Sin nivel o inicial" 2 "Primaria" 3 "Secundaria" 4 "Sup. No Universitaria" 5 "Sup. Universitaria" 6 "Post-grado" 7 "Básica especial"
	label val edu_max edu_max
	preserve
	collapse (mean) ingtram if filtro==1 & ocu500==1 & ingtram>0 [iw=fac500a], by(edu_max p207 año)
	reshape wide ingtram, i(edu_max p207) j(año)
	drop if edu_max==.
	export excel using "$out1/datos", sheet("Indicadores de género") sheetmodify firstrow(variables) cell(A20)
	restore
}
****************************************************************************************************************************************************************************
*4. PROPORCIÓN DE JÓVENES (ENTRE 15 Y 24 AÑOS) QUE NO CURSAN ESTUDIOS NI TRABAJAN
{
	use "$temp\modulo300.dta", clear
	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo500.dta", keepusing(ocu500 fac*)
	sort conglome vivienda hogar codperso
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(pobreza decil_g quintil_g decil_i quintil_i) nolabel 
	drop if _m==2
	drop _m

	tab p306 p307, nol
	tab p306 p310 if p208a>14 & p208a<25, nol
	
	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	replace fac500a=fac500a7 if año==2011
	*Generamos los departamentos
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)

	replace dpto=26 if dpto==15 & dominio!=8

	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"

	label values dpto dpto
	
	*Área de residencia
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label val area area
	
	*Generamos la variable de no estudia, que incluye a los no matriculados y a los matriculados que no asisten
	gen no_estudia=(p306==2 | p307==2) 
	gen no_capacita=(p310==2)
	
	*Generamos la variable que no trabaja
	gen no_trabaja=(ocu500!=1 & ocu500!=.)
	
	*Generamos la variable nini
	gen nini=(no_estudia==1 & no_trabaja==1 & no_capacita==1)
	
	*Por año
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año)  
	gen id="Nacional"
	replace nini=nini*100
	reshape wide nini, i(id) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetreplace firstrow(variables)
	restore

	*Por departamento
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año dpto)  
	replace nini=nini*100
	reshape wide nini, i(dpto) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A5)
	restore

	*Por sexo
	preserve
	label define sexo 1 "Hombre" 2 "Mujer"
	label values p207 sexo
	gen nini_2=nini
	collapse (mean) nini (sum) nini_2 if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año p207)  
	replace nini=nini*100
	reshape wide nini nini_2, i(p207) j(año)
	order p207 nini_* nini*	
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A34)
	restore

	*Por área de residencia
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año area)  
	replace nini=nini*100
	reshape wide nini, i(area) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A39)
	restore

	*Por quintil de ingresos
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año quintil_i)  
	replace nini=nini*100
	reshape wide nini, i(quintil_i) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A45)
	restore

	*Por decil de ingresos
	preserve
	collapse (mean) nini if p208a>14 & p208a<25 & filtro==1 [iw=fac500a], by(año decil_i)  
	replace nini=nini*100
	reshape wide nini, i(decil_i) j(año)
	rename (nini*) (a*)
	export excel using "$out1/datos", sheet("ninis") sheetmodify firstrow(variables) cell(A55)
	restore
}	
****************************************************************************************************************************************************************************
*5. ACCESO A LAS TECNOLOGÍAS DE LA INFORMACIÓN Y USO DEL INTERNET EN MAYORES DE 12 AÑOS
{
	use "$temp\modulo100.dta", clear
	merge 1:m año conglome vivienda hogar using "$temp\modulo200.dta", keepusing(p208a p204 p205 p206 codperso)
	sort conglome vivienda hogar codperso
	keep if _merge==3
	
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label values area area

	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto
	
	rename (p1141 p1142 p1143 p1144 p1145) (fijo celu tv internet ninguno)
	
	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	*Acceso a TICs en el hogar
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (a?o)
	gen nac="Nacional"
	reshape wide fijo celu tv internet ninguno, i(nac) j(a?o) string
	order nac fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetreplace firstrow(variables) 
	restore

	*Acceso a TICs en el hogar por area de residencia 
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (area a?o)
	reshape wide fijo celu tv internet ninguno, i(area) j(a?o) string
	order area fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetmodify firstrow(variables) cell(A12)
	restore
  
	*Acceso a TICs en el hogar por grupo de edad
	preserve
	collapse (mean) fijo celu tv internet ninguno if (filtro==1) [iw=factor07], by (grupo_edad a?o)
	reshape wide fijo celu tv internet ninguno, i(grupo_edad) j(a?o) string
	order grupo_edad fijo* celu* tv* internet* ninguno*
	export excel using "$out1/datos", sheet("Acceso a TICs") sheetmodify firstrow(variables) cell(A25)
	restore

}	
****************************************************************************************************************************************************************************
*6. ACCESO A SERVICIOS BASICOS 
{
	use "$temp\modulo100.dta", clear

	*área de residencia
	gen area = estrato <6
	label define area 0 rural 1 urbana
	label val area area

	*Generando variables de acceso
	gen agua=cond(p110==1 | p110==2,100,cond(p110==.,.,0))
	gen desague=cond(p111a==1 | p111a==2,100,cond(p111a==.,.,0))
	gen electricidad=cond(p1121==1,100,cond(p1121==.,.,0))
	
	gen servicios=cond(agua==100 & desague==100 & electricidad==100,100,cond(agua==. & desague==. & electricidad==.,.,0))
	
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto
	
	*Por área de residencia
	preserve
	collapse (mean) agua desague electricidad servicios [iw=factor07], by(area año)
	reshape wide agua desague electricidad servicios , i(area) j(año) 
	order area agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetreplace firstrow(variables)
	restore

	*Por departamento 
	preserve
	collapse (mean) agua desague electricidad servicios [iw=factor07], by(dpto año)
	reshape wide agua desague electricidad servicios , i(dpto) j(año) 
	order dpto agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A15)
	restore
	
	merge 1:m año conglome vivienda hogar using "$temp\modulo200.dta", keepusing(p207 p208a facpob07)	/*Esto se debe correr 		*/
	drop if _merge==1																					/*antes de los siguientes 	*/
	gen nna=(p208a<18)																					/*puntos					*/

	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	*Niños, niñas y adolescentes con acceso a servicios básicos por área de residencia
	preserve
	collapse (mean) agua desague electricidad servicios if nna==1 [iw=facpob07], by(area año)
	reshape wide agua desague electricidad servicios , i(area) j(año) 
	order area agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A76)
	restore
	
	*Niños, niñas y adolescentes con acceso a servicios básicos por área de residencia
	preserve
	collapse (mean) agua desague electricidad servicios if nna==1 [iw=facpob07], by(grupo_edad año)
	reshape wide agua desague electricidad servicios , i(grupo_edad) j(año) 
	order grupo_edad agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A82)
	restore

	*Hogares con niños con acceso a servicios básicos por area de residencia
	collapse (sum) nna (mean) agua desague electricidad servicios factor07 dpto area, by(año conglome vivienda hogar)
	replace nna=(nna>0)
	preserve
	collapse (mean) agua desague electricidad servicios if nna==1 [iw=factor07], by(area año)
	reshape wide agua desague electricidad servicios , i(area) j(año) 
	order area agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A6)
	restore
	
	*Hogares con niños con acceso a servicios básicos por departamento
	preserve
	collapse (mean) agua desague electricidad servicios if nna==1 [iw=factor07], by(dpto año)
	reshape wide agua desague electricidad servicios , i(dpto) j(año) 
	order dpto agua* desague* electricidad* servicios*
	export excel using "$out1/datos", sheet("Acceso a servicios") sheetmodify firstrow(variables) cell(A45)
	restore
}	
****************************************************************************************************************************************************************************
*7. POBREZA Y POBREZA EXTREMA + POBREZA NBI
{
	use "$temp\modulo200.dta", clear
	merge m:1 año conglome vivienda hogar using "$temp\modulo100.dta", keepusing(nbi* fac*)
	drop if _m==2
	drop _m
	
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(pobreza area fac*)
	drop if _m==2
	drop _m

	merge 1:1 año conglome vivienda hogar codperso using "$temp\modulo300.dta", keepusing(p300a fac*)
	drop if _m==2
	drop _m

	*Generamos la variable filtro de resientes del hogar
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (nonmissing=4), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18 a más"
	label val grupo_edad grupo_edad

	*Pobreza
	gen pobre_extremo=cond(pobreza==1,100,cond(pobreza==.,.,0))
	gen pobre=cond(pobreza==1 | pobreza==2,100,cond(pobreza==.,.,0))
	
	replace estrato = 1 if dominio ==8 
	gen area2 = estrato <7
	replace area2=2 if area==0
	label define area2 2 rural 1 urbana
	label val area2 area2
	
	recode p300a (1=1) (2=2) (3=3) (4 =4) (nonmissing =.), gen(lenguamat)
	label define lenguamat 1 "Quechua" 2 "Aymara" 3 "Lenguas Amazónicas" 4 "Castellano"
	label val lenguamat lenguamat

	*Tabla general
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(año)  
	gen nac="Nacional"
	reshape wide pobre pobre_extremo, i(nac) j(año)
	order nac pobre2* pobre_* 
	export excel using "$out1/datos", sheet("pobreza") sheetreplace firstrow(variables) 
	restore

	*Por área de residencia
	preserve
	keep if grupo_edad<=3
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(area año)  
	reshape wide pobre pobre_extremo, i(area) j(año)
	order area pobre2* pobre_* 
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A5)
	restore

	*Por departamento
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(dpto año)  
	reshape wide pobre pobre_extremo, i(dpto) j(año)
	order dpto pobre2* pobre_* 
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A13)
	restore
	
	*Por grupo de edad
	preserve
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(grupo_edad año)  
	reshape wide pobre pobre_extremo, i(grupo_edad) j(año)
	order grupo_edad pobre2* pobre_* 
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A66)
	restore

	*Por lengua materna
	preserve
	keep if grupo_edad<=3
	recode p300a (5 6 = 7) (9 = 8)
	collapse (mean) pobre pobre_extremo if filtro==1 [iw=facpob07], by(p300a año)  
	label define p300a 9 "lengua de señas peruanas" ,modify
	drop if p300a==.
	reshape wide pobre pobre_extremo, i(p300a) j(año)
	order p300a pobre2* pobre_* 
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A80)
	restore

	*Población con al menos una necesidad básica insatisfecha
	gen nbi_= cond(nbi1==1 | nbi2==1 | nbi3==1 | nbi4==1 | nbi5==1,1, cond(nbi1==. | nbi2==. | nbi3==. | nbi4==. | nbi5==.,.,0))
	preserve
	collapse (mean) nbi_ nbi1 nbi2 nbi3 nbi4 nbi5 if filtro==1 [iw=facpob07], by(año)  
	gen nac="Nacional"
	reshape wide nbi_ nbi1 nbi2 nbi3 nbi4 nbi5, i(nac) j(año)
	order nac nbi_* nbi1* nbi2* nbi3* nbi4* nbi5*
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A90)
	restore

   	*Población con al menos una nbi por área de residencia
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by( area año)  
	reshape wide nbi_, i(area) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A100)
	restore
 
   	*Población con al menos una nbi por departamento
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by( dpto año)  
	reshape wide nbi_, i(dpto) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A108)
	restore

   	*Población con al menos una nbi por departamento
	preserve
	collapse (mean) nbi_ if filtro==1 [iw=facpob07], by(grupo_edad año)  
	reshape wide nbi_, i(grupo_edad) j(año)
	export excel using "$out1/datos", sheet("pobreza") sheetmodify firstrow(variables) cell(A137)
	restore
}
****************************************************************************************************************************************************************************
* 9. Población menor a 17 años con hacinamiento
{
	use "$temp\modulo200.dta", clear
	merge m:1 año conglome vivienda hogar using "$temp\modulo100.dta", keepusing(p104*)
	drop if _m==2
	drop _m
	merge m:1 año conglome vivienda hogar using "$temp\sumaria.dta", keepusing(mieperho)
	drop _m
	
	gen hacinamiento=mieperho/p104
	recode hacinamiento (0/1=1) (1.001/2=2) (nonmissing=3)
	label define hacinamiento 1 "Hasta una persona" 2 "Hasta dos personas" 3 "Tres o más personas"
	label values hacinamiento hacinamiento
	
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	recode p208a (0/5=1) (6/11=2) (12/17=3) (18/24 =4) (25/44 =5) (45/64 =6) (nonmissing=7), gen(grupo_edad)
	label define grupo_edad 1 "0-5 años" 2 "6-11 años" 3 "12-17 años" 4 "18-24 años" 5 "25-44 años" 6 "45-64 años" 7 "65 años a más"
	label val grupo_edad grupo_edad

	preserve
	collapse (sum) filtro if filtro==1 & grupo_edad<4 [iw=facpob07], by(hacinamiento año)
	reshape wide filtro, i(hacinamiento) j(año)
	rename (filtro*) (a*)
	export excel using "$out1/datos", sheet("Hacinamiento") sheetreplace firstrow(variables) 
	restore

}
****************************************************************************************************************************************************************************
* 10. Gasto de bolsillo
{
	use "$temp\modulo400.dta", clear
	
    destring ubigeo, replace
	gen dpto=int(ubigeo/10000)
	replace dpto=26 if dpto==15 & dominio!=8
	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"
	label values dpto dpto
	
	*Cambiar 2 por 0 para la opción no afiliado
	forv x=1/8 {
	replace p419`x'=0 if p419`x'==2
	}

	*Tipo de seguro
	egen total_seguros=rowtotal(p4191 p4192 p4193 p4194 p4195 p4196 p4197 p4198)
	replace total_seguros=. if p4191==.

	gen tipo_seguro=.
	replace tipo_seguro=1 if (p4191==1) & total_seguros==1
	replace tipo_seguro=2 if (p4193==1 | (p4191==1 & p4193==1)) & (p4192==0 & ///
	 p4194==0 & p4196==0 & p4197==0 & p4198==0)
	replace tipo_seguro=3 if p4195==1 & total_seguros==1
	replace tipo_seguro=4 if p4194==1 & total_seguros==1
	replace tipo_seguro=5 if (p4192==1 | p4196==1 | p4197==1 | p4198==1) ///
	& total_seguros==1
	replace tipo_seguro=6 if (tipo_seguro!=2 & total_seguros>1 & total_seguros!=.)
	replace tipo_seguro=7 if total_seguros==0

	label define tipo_seguro 1 "Solo Essalud" 2 "EsSalud y/o EPS" 3 "Solo SIS" ///
	 4 "Solo FFAA y PNP" 5 "Solo privado" 6 "Más de 1 seguro" 7"Sin Seguro" 
	label values tipo_seguro tipo_seguro

	gen seguro=.
	replace seguro=0 if tipo_seguro==7
	replace seguro=1 if total_seguros>0 & total_seguros!=.

	label define seguro 0 "Sin seguro" 1 "Con seguro" 
	label values seguro seguro

	*Presenta síntoma, malestar, enfermedad o accidente

	gen enfermo=.
	replace enfermo=1 if p4021==1 | p4022==1 | p4023==1 | p4024==1
	replace enfermo=0 if p4025==1
	label define enfermo 1 "Enfermo" 0 "No enfermo"
	label values enfermo enfermo

	*Lugar de atención
	gen lugar_atencion=.
	replace lugar_atencion=0 if p40314==1
	replace lugar_atencion=1 if p4031==1 | p4032==1 | p4033==1
	replace lugar_atencion=2 if p4035==1
	replace lugar_atencion=3 if p4034==1
	replace lugar_atencion=4 if p4036==1
	replace lugar_atencion=5 if p4037==1
	replace lugar_atencion=6 if p4038==1 | p4039==1
	replace lugar_atencion=7 if p40310==1
	replace lugar_atencion=8  if p40311==1 | p40313==1
	label variable lugar_atencion "Lugar de atencion"
	label define lugar_atencion 0 "No atencion" 1 "Minsa 1nivel" 2"Minsa 2nivel" ///
	 3"EsSalud 1nivel" 4"EsSalud 2nivel" 5"FFAA y PNP" 6"Privado" 7"Farmacia" 8"Otro" 
	label values lugar_atencion lugar_atencion

	/*Pq no se atendio (estaba variable también pregunta a los que se atienden en 
	farmacia */

	gen dinero=p4091
	egen problemas_oferta = rowtotal (p4092 p4093 p40910), missing
	gen no_necesario = p4095
	gen sin_seguro = p4097
	gen autoreceto= p4098
	egen otros_no_atendio = rowtotal (p4094 p4096 p4099 p40911), missing
	
	*Gasto de Bolsillo
	forv x=1/9 {

	gen oop_`x' = i4160`x' if p4151_0`x'==1 | p4152_0`x'==1 | p4153_0`x'==1 ///
	| p4154_0`x'==1
	}

	gen oopmedicina_percapita= oop_2
	replace oopmedicina_percapita=0 if oop_2==.

	label variable oop_1 "OOP consulta"
	label variable oop_2 "OOP medicinas"

	forv x=10/16 {

	gen oop_`x' = i416`x' if p4151_`x'==1 | p4152_`x'==1 | p4153_`x'==1 | ///
	 p4154_`x'==1
	}

	egen ooptotal_percapita= rowtotal(oop_*)
	egen ooptotal_xgastador= rowtotal (oop_*), missing
	label variable ooptotal_percapita "OOP_total"
	label variable ooptotal_xgastador "OOP_x_persona_que_gasta"
	label variable oopmedicina_percapita "OOP_medicina_per_capita"
	 
	*Tendencia del OOP per capita Peru
	table año if filtro==1 [iw=factor], c(mean ooptotal_percapita mean oopmedicina_percapita) 

	*Tendencia OOP total Peru
	table año [pw=factor], c(sum oopttotal_percapita sum oopmedicina_percapita)

	*Por departamento
	table año departamento [pw=factor], c((mean oopttotal_percapita mean oopmedicina_percapita)
	
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	preserve
	collapse (mean) ooptotal_percapita oopmedicina_percapita if filtro==1 [iw=factor07], by(año)
	export excel using "$out1/datos", sheet("Gasto de bolsillo") sheetreplace firstrow(variables) 
	restore
}
****************************************************************************************************************************************************************************
* 11. Coeficiente de gini
{
	use "$temp\sumaria.dta", clear

	forval			i=2007/2019 {
	capture 		noisily ginidesc ipcr_0 [aw=factornd07] if año==`i'
	nobreak
	}

	*Coeficiente de gini por ingresos y gastos 2007-2019
	ginidesc ipcr_0 [aw=factornd07], by(año) m(ing1) gk(ing2)
	ginidesc gpgru0 [aw=factornd07], by(año) m(gas1) gk(gas2)

	putexcel set "$out1/datos.xls", sheet("Coef. gini") modify
	putexcel A1=matrix(gas2), names
	putexcel A20=matrix(ing2), names
	}
****************************************************************************************************************************************************************************
