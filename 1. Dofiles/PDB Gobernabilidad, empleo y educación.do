********************************************************************************
*******************************INDICADORES PDB**********************************
/*******************************************************************************
Objetivo: 		Estimar indicadores sobre educación, gobernabilidad y empleo
Autor: 			CNH
Organización:
	1. Direcciones
	2. Gobernabilidad
	3. Bonos del Estado COVID
	4. Educación
	5. Empleo
*******************************************************************************/
*	1. Direcciones
	
	global bd "D:\1. Documentos\0. Bases de datos\2. ENAHO\1. Data"
	global temp "D:\1. Documentos\0. Bases de datos\2. ENAHO\2. Temp"
	global output "D:\1. Documentos\0. Bases de datos\2. ENAHO\3. Output"
	
********************************************************************************
*	2. Gobernabilidad
{	
	use "$bd/enaho01b-2021-1.dta", clear
	gen año="2021"
	append using "$bd/enaho01b-2020-1.dta"
	replace año="2020" if año==""
	append using "$bd/enaho01b-2019-1.dta"
	replace año="2019" if año==""
	
	destring año, replace
	
	*Generando la variable de semestre
	destring mes, replace
	gen semestre="S1" if mes <=6 
	replace semestre="S2" if mes>6
	replace semestre=año+semestre
	
	*Generamos la variable filtro de residencia
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 

	*Generamos la variable rural
	gen rural=1 if estrato==7 | estrato==8 //rural
	replace rural=0 if rural==. //urbano

	label define label_rural 1 "rural" 0 "urbano"
	label values rural label_rural

	*Generamos la variable region
	recode dominio (1 2 3 8 = 1) (4/6=2) (7=3) , gen(region)
	label define region 1 "costa" 2 "sierra" 3 "selva"
	label values region region
	
	*Generamos la variable departamento
	destring ubigeo, replace
	gen dpto=int(ubigeo/10000)

	replace dpto=26 if dpto==15 & dominio!=8

	label define dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 	/*
	*/ 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 	/* 
	*/ "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" /*
	*/ 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" /* 
	*/ 25 "Ucayali" 26 "Lima Provincias"

	label values dpto dpto
	
	svyset [pweight = famiegob07], psu(conglome)strata(estrato)

	*Generando las variables de confianza
	
	recode p1_04 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_muni_prov)
	recode p1_05 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_muni_dist)
	recode p1_06 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_pnp)
	recode p1_07 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_ffaa)
	recode p1_08 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_gore)
	recode p1_09 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_poder_judicial)
	recode p1_12 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_congreso)
	recode p1_13 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_partidos)
	recode p1_14 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_prensa_escrita)
	recode p1_15 (1/2=0) (3/4=1) (nonmissing=.) , gen(conf_radio_tv)
	
	svy: mean conf_muni_prov conf_muni_dist conf_gore conf_pnp conf_ffaa conf_prensa_escrita conf_radio_tv conf_poder_judicial conf_congreso conf_partidos if filtro==1, over(año)
	svy: mean conf_muni_prov conf_muni_dist conf_gore conf_pnp conf_ffaa conf_prensa_escrita conf_radio_tv conf_poder_judicial conf_congreso conf_partidos if filtro==1, over(año rural)
	
	*Generando las variables de principal problema del país
	
	local contador=1
	foreach x of varlist p2_1_01 p2_1_02 p2_1_03 p2_1_04 p2_1_05 p2_1_06 p2_1_07 p2_1_08 p2_1_09 p2_1_10 p2_1_11 p2_1_12 p2_1_13 p2_1_14 p2_1_15 p2_1_16 p2_1_17{
	
	replace `x'=1 if `x'==`contador'
	local ++contador
	
	}
	
	*Solo hacemos el análisis respecto de las que presentan una confiabilidad suficiente (CV<15%) para la mayoría de los departamentos
	svy: mean p2_1_01 p2_1_02 p2_1_03 p2_1_04 p2_1_05 p2_1_06 p2_1_07 p2_1_08 p2_1_09 p2_1_10 p2_1_11 p2_1_12 p2_1_13 p2_1_14 p2_1_15 if filtro==1, over(año)
	svy: mean p2_1_01 p2_1_02 p2_1_03 p2_1_04 p2_1_05 p2_1_06 p2_1_07 p2_1_08 p2_1_09 p2_1_10 p2_1_11 p2_1_12 p2_1_13 p2_1_14 p2_1_15  if filtro==1, over(año rural)
	svy: mean p2_1_01 p2_1_03 p2_1_06 p2_1_08 p2_1_10 p2_1_11 p2_1_15  if filtro==1, over(año dpto)

	*Generando las variables 2 de principal problema del país
	
	svy: mean p2_2_01 if filtro==1, over(año)
	svy: mean p2_2_02 if filtro==1, over(año)
	svy: mean p2_2_03 if filtro==1, over(año)
	svy: mean p2_2_04 if filtro==1, over(año)
	svy: mean p2_2_05 if filtro==1, over(año)
	svy: mean p2_2_06 if filtro==1, over(año)
	svy: mean p2_2_07 if filtro==1, over(año)
	svy: mean p2_2_08 if filtro==1, over(año)
	svy: mean p2_2_09 if filtro==1, over(año)
	svy: mean p2_2_10 if filtro==1, over(año)
	svy: mean p2_2_11 if filtro==1, over(año)
	svy: mean p2_2_12 if filtro==1, over(año)
	svy: mean p2_2_13 if filtro==1, over(año)
	svy: mean p2_2_14 if filtro==1, over(año)
	svy: mean p2_2_15 if filtro==1, over(año)
	
	svy: mean p2_2_01 if filtro==1, over(año rural)
	svy: mean p2_2_02 if filtro==1, over(año rural)
	svy: mean p2_2_03 if filtro==1, over(año rural)
	svy: mean p2_2_04 if filtro==1, over(año rural)
	svy: mean p2_2_05 if filtro==1, over(año rural)
	svy: mean p2_2_06 if filtro==1, over(año rural)
	svy: mean p2_2_07 if filtro==1, over(año rural)
	svy: mean p2_2_08 if filtro==1, over(año rural)
	svy: mean p2_2_09 if filtro==1, over(año rural)
	svy: mean p2_2_10 if filtro==1, over(año rural)
	svy: mean p2_2_11 if filtro==1, over(año rural)
	svy: mean p2_2_12 if filtro==1, over(año rural)
	svy: mean p2_2_13 if filtro==1, over(año rural)
	svy: mean p2_2_14 if filtro==1, over(año rural)
	svy: mean p2_2_15 if filtro==1, over(año rural)

	svy: mean p2_2_01 if filtro==1, over(año dpto)
	svy: mean p2_2_02 if filtro==1, over(año dpto)
	svy: mean p2_2_03 if filtro==1, over(año dpto)
	svy: mean p2_2_04 if filtro==1, over(año dpto)
	svy: mean p2_2_05 if filtro==1, over(año dpto)
	svy: mean p2_2_06 if filtro==1, over(año dpto)
*	svy: mean p2_2_07 if filtro==1, over(año dpto) //Baja confiabilidad
	svy: mean p2_2_08 if filtro==1, over(año dpto)
*	svy: mean p2_2_09 if filtro==1, over(año dpto) //Baja confiabilidad
	svy: mean p2_2_10 if filtro==1, over(año dpto)
	svy: mean p2_2_11 if filtro==1, over(año dpto)
*	svy: mean p2_2_12 if filtro==1, over(año dpto) //Baja confiabilidad
	svy: mean p2_2_13 if filtro==1, over(año dpto)
*	svy: mean p2_2_14 if filtro==1, over(año dpto) //Baja confiabilidad
	svy: mean p2_2_15 if filtro==1, over(año dpto)
	
	
	*Opinión sobre la gestión del gobierno 
	
	recode p2a1_1  (1/2=1) (3/4=0) (nonmissing=.) , gen(op_gob_central)
	recode p2a1_2  (1/2=1) (3/4=0) (nonmissing=.) , gen(op_gob_regional)
	recode p2a1_3  (1/2=1) (3/4=0) (nonmissing=.) , gen(op_gob_provincial)
	recode p2a1_4  (1/2=1) (3/4=0) (nonmissing=.) , gen(op_gob_distrital)
	
	svy: mean op_gob_central op_gob_regional op_gob_provincial op_gob_distrital if filtro==1, over(año)
	svy: mean op_gob_central op_gob_regional op_gob_provincial op_gob_distrital if filtro==1, over(año rural)
	svy: mean op_gob_central op_gob_regional op_gob_provincial op_gob_distrital if filtro==1, over(año region)
	svy: mean op_gob_central op_gob_regional op_gob_provincial op_gob_distrital if filtro==1, over(año dpto)
	
	
	*Evaluar las difrencias significativas entre años
	
	gen año2021=(año=="2021")
	*2021 vs 2020
	reg op_gob_central año2021  if año!="2019" & filtro==1 [pw=famiegob07]
	reg op_gob_regional año2021  if año!="2019" & filtro==1 [pw=famiegob07]
	reg op_gob_provincial año2021  if año!="2019" & filtro==1 [pw=famiegob07]
	reg op_gob_distrital año2021  if año!="2019" & filtro==1 [pw=famiegob07]
	
	*2021 vs 2019
	reg op_gob_central año2021  if año!="2020" & filtro==1 [pw=famiegob07]
	reg op_gob_regional año2021  if año!="2020" & filtro==1 [pw=famiegob07]
	reg op_gob_provincial año2021  if año!="2020" & filtro==1 [pw=famiegob07]
	reg op_gob_distrital año2021  if año!="2020" & filtro==1 [pw=famiegob07]
	}
	
	
********************************************************************************
*	3. Bonos del Estado
	
	use "$bd/enaho01-2021-700.dta", clear
	
	Bono yanapay p710_29 
	Bono 600 p710_30
	
	use "$bd/enaho01a-2021-500.dta", clear
	
	merge m:1 conglome vivienda hogar using "$bd/sumaria-2021.dta" , keepusing(pobreza pobrezav)
	
	gen año=2021
	
	*Generamos la variable filtro de residencia
	gen filtro=0
	replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
	
/*	Yo me quedo en casa p55616a 				p55616a_e
	Bono independiente p55617a 
	Bono rural p55618a 							p55618a_e
	Bono familiar universal p55619a 			p55619a_e
	Bono electricidad p55620a 
	Bono niño universal p55621a 
	Bono Yanapay p55624a 						p55624a_e
	Bono 600 p55625a							p55625a_e
*/	
	
	codebook p55616a_e p55617a p55618a_e p55619a_e p55620a p55621a p55624a_e p55625a_e
	
	foreach x of varlist p55616a_e p55617a p55618a_e p55619a_e p55620a p55621a p55624a_e p55625a_e{
	
	replace `x'=0 if `x'==2
	
	}
	
	gen algun_bono_covid=1 if (p55616a_e==1 | p55617a==1 | p55618a_e==1 | p55619a_e==1 | p55620a==1 | p55621a==1 | p55624a_e==1 | p55625a_e==1)
	replace algun_bono_covid=0 if algun_bono_covid!=1
	replace algun_bono_covid=. if (p55616a_e==1 & p55617a==. & p55618a_e==. & p55619a_e==. & p55620a==. & p55621a==. & p55624a_e==. & p55625a_e==.)
	
	
	table pobrezav  if filtro==1 [iw=fac500a] , c(mean p55616a_e mean p55617a mean p55618a_e mean p55619a_e mean p55620a)
	table pobrezav  if filtro==1 [iw=fac500a] , c(mean p55621a mean p55624a_e mean p55625a_e mean algun_bono_covid)

********************************************************************************
*	4. Educación

********************************************************************************
*	5. Empleo
	