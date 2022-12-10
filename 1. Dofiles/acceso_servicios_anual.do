/*==============================================================================
 Nombre del código:			Acceso a servicios hogares
 Autor:		 				Gonzalo Manrique
 Objetivo:					Limpiar la ENA 2016 y estimar variables
 Bases a usar:				Encuesta Nacional de Hogares (ENAHO) - 2021
 
 Estructura:
	
	1. Direcciones
	2. Limpieza de base
	3. Tabulaciones
==============================================================================*/

*	1. Direcciones
{
	clear all
	global bd0 "D:\1. Documentos\0. Bases de datos\2. ENAHO\1. Data"
}
*	2. Limpieza de base
{
	use "$bd0\enaho01-2021-100.dta"

	* Generamos la variable departamento
	destring ubigeo, replace
	gen depto=ubigeo/10000
	gen dpto=int(depto)
	label var dpto "Departamento donde reside"
	label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" ///
	7"Callao" 8"Cusco" 9"Huancavelica" 10"Huánuco" 11"Ica" 12 "Junín" 13"La Libertad" ///
	14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre de Dios" 18"Moquegua" 19"Pasco" 20"Piura" ///
	21"Puno" 22"San Martín" 23"Tacna" 24"Tumbes" 25"Ucayali"
	label values dpto dpto

	* Generamos la variable area
	recode estrato (1/5=1 "Urbana") (6/8=2 "Rural"), gen(area)
	la var area "Area de residencia"
	tab area
}

*	3. Tabulaciones
{
	*Seteamos el diseño muestral
	svyset [pweight = factor07], psu(conglome)strata(estrato)


	* Acceso a Agua

	gen acc_agua = 100 if p110==1 | p110==2 | p110==3
	replace acc_agua = 0 if acc_agua==.
	replace acc_agua = . if p110==.

	svy: mean acc_agua, over(dpto)

	svy: mean acc_agua, over(area)

	svy: mean acc_agua

	***** Acesso a agua al menos 12 horas (incluye 24 horas)

	gen acc_agua_12 = 100 if acc_agua == 100 & p110c1 > 11
	replace acc_agua_12 = 0 if acc_agua_12==.
	replace acc_agua_12 = . if p110==.

	svy: mean acc_agua_12, over(dpto)

	svy: mean acc_agua_12, over(area)

	svy: mean acc_agua_12

	***** Acesso a agua 24 horas

	gen acc_agua_24 = 100 if acc_agua == 100 & p110c1 == 24
	replace acc_agua_24 = 0 if acc_agua_24==.
	replace acc_agua_24 = . if p110==.

	svy: mean acc_agua_24, over(dpto)
	svy: mean acc_agua_24, over(area)
	svy: mean acc_agua_24

	* Acceso a Saneamiento

	gen acc_saneam = 100 if p111a == 1 | p111a == 2 | p111a == 4
	replace  acc_saneam = 0 if acc_saneam == .
	replace acc_saneam = . if p111a == .

	svy: mean acc_saneam, over(dpto)
	svy: mean acc_saneam, over(area)
	svy: mean acc_saneam

	* Acceso a Electrificación

	gen acc_elec = 100 if p1121 == 1
	replace  acc_elec = 0 if acc_elec == .
	replace acc_elec = . if p1121 == .

	svy: mean acc_elec, over(dpto)
	svy: mean acc_elec, over(area)
	svy: mean acc_elec

	* Acceso a Telefonía 

	gen acc_tel = 100 if p1142 == 1
	replace  acc_tel = 0 if acc_tel == .
	replace acc_tel = . if p1142 == .

	svy: mean acc_tel, over(dpto)
	svy: mean acc_tel, over(area)
	svy: mean acc_tel

	* Acceso a Internet 

	gen acc_inter = 100 if p1144 == 1
	replace  acc_inter = 0 if acc_inter == .
	replace acc_inter = . if p1144 == .

	svy: mean acc_inter, over(dpto)
	svy: mean  acc_inter, over(area)
	svy: mean acc_inter

	* Acceso a Agua, Saneamiento, Electrificación, Telefonía, Internet 

	gen acc_total = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100
	replace  acc_total = 0 if acc_total == .
	replace acc_total = . if p1144 == .

	svy: mean acc_total, over(dpto)
	svy: mean  acc_total, over(area)
	svy: mean acc_total

	***** Acceso a todos los servicios si tiene acceso a agua al menos 12 horas (incluye 24 horas)

	gen acc_total_12 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 > 11 & p110c1 != .
	replace  acc_total_12 = 0 if acc_total_12 == .
	replace acc_total_12 = . if p110==.

	svy: mean acc_total_12 , over(dpto)

	svy: mean acc_total_12, over(anio)

	***** Acceso a todos los servicios si tiene acceso a agua 24 horas

	gen acc_total_24 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 == 24
	replace  acc_total_24 = 0 if acc_total_24 == .
	replace acc_total_24 = . if if p110==.

	svy: mean acc_total_24 , over(dpto)

	svy: mean acc_total_24

	***** Acceso a todos los servicios si tiene acceso a agua menos de 12 horas

	gen acc_total_0 = 100 if acc_agua == 100 & acc_elec == 100 & acc_inter == 100 & acc_saneam == 100 & acc_tel == 100 & p110c1 < 12  & p110c1 != .
	replace  acc_total_0 = 0 if acc_total_0 == .
	replace acc_total_0 = . if p110==.

	*local area_p = "2015 2016 2017 2018 2019 2020"

	svy: mean acc_total_0 , over(dpto)

	svy: mean acc_total_0
}

