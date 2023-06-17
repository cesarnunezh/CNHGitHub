*================================================================
* Proyecto:			PNIA - Innovacion
* Responsable: 		Gonzalo Manrique
* Objetivo:			Limpiar la ENA 2016 y estimar variables
* Bases a usar:		Encuesta Nacional Agropecuaria (ENA) - 2016
*================================================================

clear
set more off , permanently

** Ruta de origen
global		o1 "D:\1. Documentos\0. Bases de datos\4. ENA y CENAGRO\1. Data"																			// Bases de la ENA
*global		o2 "G:\Economia Aplicada\PROYECTOS\2017\2017-087-E- PNIA - Innovacion\5 Analisis\3 Diagnóstico del SNIA\4 Bases de datos\1 mapas"			// Bases para mapas

** Ruta de destino
global		d1 "D:\1. Documentos\0. Bases de datos\4. ENA y CENAGRO\2. Temp"							// Bases modificadas
global		d3 "D:\1. Documentos\0. Bases de datos\4. ENA y CENAGRO\3. Output"							// Cuadros y mapas

** Ruta de StatTransfer
global 		StatTransfer_path `"C:\Users\FR\Documents\StatTransfer9\st"'

*=======================================================>
*=================== LIMPIEZA DE BASES =================>
*=======================================================>

******** CAPITULO 100 - CARACTERISTICAS DE LA UNIDAD AGROPECUARIA (PEQUEÑOS Y MEDIANOS)
use			"$o1\01_cap100_1.dta" , clear

isid		conglome nselua ua			// (Estas tres varibles son el ID en la ENA)

save		"$d1\cap100_1.dta" , replace


******** CAPITULO 200A - SUPERFICIE COSECHADA Y SEMBRADA
use			"$o1/02_cap200ab.dta" , clear
keep		if codigo==1

**** Variable superficie cosechada (en hectáreas)
rename		p217_sup_ha s_cosechada


**** Variable Producción Total
replace		p219_cant_2=","+p219_cant_2
destring	p219_cant_2 , dpcomma replace
gen			p219_cant_total = p219_cant_1+p219_cant_2					// En unidades de peso diversas
gen			prod_total=p219_cant_total*p219_equiv_kg/1000				// En toneladas


**** Variable Producción para Venta
replace		p220_1_cant_2=","+p220_1_cant_2
destring	p220_1_cant_2 , dpcomma replace
gen			p220_1_cant_total=p220_1_cant_1+p220_1_cant_2				// En unidades de peso diversas
gen			prod_venta=p220_1_cant_total*p219_equiv_kg/1000				// En toneladas


**** Variable Producción para consumo del hogar
replace		p220_2_dec=","+p220_2_dec
destring	p220_2_dec , dpcomma replace
gen			p220_2_total=p220_2_ent+p220_2_dec							// En unidades de peso diversas
gen			prod_consumo=p220_2_total*p219_equiv_kg/1000				// En toneladas

**** Proporción para venta
gen			prop_venta=prod_venta/prod_total

**** Proporción para autoconsumo
gen			prop_consumo=prod_consumo/prod_total


**** Rendimiento agricola (toneladas/hectárea)
gen			rend=prod_total/s_cosechada
** Limpieza de los rendimientos agrícolas
drop		if missing(rend)														// Solo se pierden 19 obs.
sum			rend , d

gen			p75_rend=.
gen			p25_rend=.

levelsof	region , 	local(levels1)
levelsof	p204_nom ,	local(levels2)
quietly foreach j of local levels1 {
	foreach k of local levels2 {
		capture sum rend if region==`j' & p204_nom=="`k'", d
		replace p75_rend=r(p75) if region==`j' & p204_nom=="`k'"
		replace p25_rend=r(p25) if region==`j' & p204_nom=="`k'"
	}	
}
//

gen			qrange_rend= p75_rend-p25_rend											// rango intercuartil
gen			outl_rend=(rend<p25_rend-qrange_rend) | (p75_rend+qrange_rend<rend) 	// se identifican outliers
bys			region p204_nom: egen nooutl_mean_rend=mean(rend) if outl_rend==0		// se genera media sin tomar outliers
bys			region p204_nom: egen mean_rend=max(nooutl_mean_rend)					// se genera constante con la media sin outliers
replace		rend=mean_rend if outl_rend==1											// se reemplazan outliers por la media calculada


**** Reconstrucción de la producción total
replace		prod_total=rend*s_cosechada							// En toneladas


**** Reconstrucción de la cantidad para venta
replace		prod_venta=(prod_total*1000)*prop_venta				// En kilos


**** Reconstrucción de la cantidad para autoconsumo
replace		prod_consumo=(prod_total*1000)*prop_consumo			// En kilos


**** Precio de venta (Precio único por producto y región)
replace		p220_1_prec_2=","+p220_1_prec_2
destring	p220_1_prec_2 , dpcomma replace
gen			pventa=(p220_1_prec_1+p220_1_prec_2)/p219_equiv_kg									// Precio por kg
** Limpieza
bys			region p204_nom: egen mean_pventa=mean(pventa)										// Media para identificar outliers
bys			region p204_nom: egen sd_pventa=sd(pventa)											// Desviación estándar 
gen			outl_pventa=(pventa<mean_pventa-2*sd_pventa) | (pventa>mean_pventa+2*sd_pventa)		// Se identifican outliers
bys			region p204_nom: egen nooutl_mean_pventa=mean(pventa) if outl_pventa==0				// Se calcula la media sin outliers
bys			region p204_nom: egen mpventa=max(nooutl_mean_pventa)								// Se imputa la nueva mediana a todas las observaciones
replace		pventa=mpventa if outl_pventa==1

**** Precio de consumo
replace		p220_2_prec_2=","+p220_2_prec_2
destring	p220_2_prec_2 , dpcomma replace
gen			pconsumo=(p220_2_prec_1+p220_2_prec_2)/p219_equiv_kg											// Precio por kg
** Limpieza
bys			region p204_nom: egen mean_pconsumo=mean(pconsumo)												// Media para identificar outliers
bys			region p204_nom: egen sd_pconsumo=sd(pconsumo)													// Desviación estándar 
gen			outl_pconsumo=(pconsumo<mean_pconsumo-2*sd_pconsumo) | (pconsumo>mean_pconsumo+2*sd_pconsumo)	// Se identifican outliers
bys			region p204_nom: egen nooutl_mean_pconsumo=median(pconsumo) if outl_pconsumo==0					// Se calcula la mediana sin outliers
bys			region p204_nom: egen mpconsumo=max(nooutl_mean_pconsumo)										// Se imputa la nueva mediana a todas las observaciones
replace		pconsumo=mpconsumo if outl_pconsumo==1
	
**** Variable superficie sembrada
replace		p210_sup_2 = ","+p210_sup_2 
destring	p210_sup_2 , dpcomma replace
gen			sup = p210_sup_1 + p210_sup_2

**** Variables de tipo de riego
gen			triego=.
label		var triego "1=secano; 2=gravedad; 3=tecnificado"
replace		triego=1 if p212==1
replace		triego=2 if p213==7
replace		triego=3 if p213<7
** Dummys (para collapse)
tab			triego , gen(riego)
rename		riego1 secano
rename		riego2 gravedad
rename		riego3 tecnificado
** Variables de superficie por tipo de riego
gen			supsecano=			sup*secano
gen			supgravedad=		sup*gravedad
gen			suptecnificado=		sup*tecnificado
lab			var supsecano	 	"Secano (ha)"	
lab			var supsecano	 	"Gravedad (ha)"							
lab			var supsecano 		"Tecnificado (ha)"	


**** Variable tipo de semilla
** Dummys (para collapse)
tab			p214 , gen(semilla)
rename		semilla1 semicert
rename		semilla2 seminocert
** Variables de superficie por tipo de semilla
gen			supsemicert=		sup*semicert
gen			supseminocert=		sup*seminocert
lab			var supsemicert		"Semilla certificada"
lab			var supseminocert	"Semilla no certificada"

**** VBP agrícola
gen			vbp_agr=prod_venta*pventa+prod_consumo*pconsumo


**** Se guarda la base generada
save		"$d1/cap200ab.dta" , replace


**** Collapse para merge
collapse	(sum)vbp_agr , by(conglome nselua ua)
save		"$d1/vbp_agr.dta" , replace



******** CAPITULO 200B - PRODUCCIÓN Y DESTINO DE LOS CULTIVOS COSECHADOS (CONTINUACIÓN)
use			"$o1/04_cap200b.dta" , clear
rename		p228_nom princult

save		"$d1/cap200b.dta" , replace




******** CAPITULO 200C - DERIVADOS AGRÍCOLAS
use			"$o1/05_cap200c.dta" , clear
keep		if codigo==1

**** Producción de derivados
replace		p229d_cant_dec=","+p229d_cant_dec
destring	p229d_cant_dec , dpcomma replace
gen			p229d_cant_total=p229d_cant_ent+p229d_cant_dec			// En unidades de peso diversas
gen			deriv_total=p229d_cant_total*p229_equiv					// En kg


**** Precio de derivados
replace		p229e_prec_dec=","+p229e_prec_dec
destring	p229e_prec_dec, dpcomma replace
gen			pderiv=(p229e_prec_ent+p229e_prec_dec)/p229_equiv 									// Precio por kg
** Limpieza
bys			region p229c_nom: egen mean_pderiv=mean(pderiv)										// Media para identificar outliers
bys			region p229c_nom: egen sd_pderiv=sd(pderiv)											// Desviación estándar 
gen			outl_pderiv=(pderiv<mean_pderiv-2*sd_pderiv) | (pderiv>mean_pderiv+2*sd_pderiv)		// Se identifican outliers
bys			region p229c_nom: egen nooutl_mean_pderiv=mean(pderiv) if outl_pderiv==0			// Se calcula la media sin outliers
bys			region p229c_nom: egen mpderiv=max(nooutl_mean_pderiv)								// Se imputa la nueva media a todas las observaciones
replace		pderiv=mpderiv if outl_pderiv==1

**** VBP Derivados
gen			vbp_deragr=deriv_total*pderiv	


**** Se guarda la base generada
save		"$d1/05_cap200c.dta" , replace


**** Collapse para merge
collapse	(sum)vbp_deragr , by(conglome nselua ua)
save		"$d1/vbp_deragr.dta" , replace



******** CAPITULO 200D - SUBPRODUCTOS AGRÍCOLAS
use			"$o1/06_cap200d" , clear
keep		if codigo==1

**** Producción de subproductos agricolas para la venta
replace		p229i_1_cant_dec=","+p229i_1_cant_dec
destring	p229i_1_cant_dec , dpcomma replace
gen			p229i_1_cant_total=p229i_1_cant_ent+p229i_1_cant_dec		// En unidades de peso diversas
gen			subagr_total=p229i_1_cant_total*p229h_equiv					// En kg
** Limpieza
drop		if missing(subagr_total)
bys			region p229g_nom: egen med1_subagr=median(subagr_total)
gen			outl_subagr=(subagr<0.2*med1_subagr) | (subagr>5*med1_subagr)						// Se identifican outliers
bys			region p229g_nom: egen nooutl_med_subagr=median(subagr_total) if outl_subagr==0		// Se calcula nueva mediana sin outliers (las obs. con outlier tienen missing)
bys			region p229g_nom: egen med_subagr=max(nooutl_med)									// Se genera variable con la mediana sin outliers para todas las obs.
replace		subagr_total=med_subagr if outl_subagr==1	


**** Precio de subproductos agricolas
replace		p229i_prec_dec=","+p229i_prec_dec
destring	p229i_prec_dec, dpcomma replace
gen			psubagr=(p229i_prec_ent+p229i_prec_dec)/p229h_equiv 										// Precio por kg
** Limpieza
bys			region p229g_nom: egen mean_psubagr=mean(psubagr)											// Media para identificar outliers
bys			region p229g_nom: egen sd_psubagr=sd(psubagr)												// Desviación estándar 
gen			outl_psubagr=(psubagr<mean_psubagr-2*sd_psubagr) | (psubagr>mean_psubagr+2*sd_psubagr)		// Se identifican outliers
bys			region p229g_nom: egen nooutl_mean_psubagr=median(psubagr) if outl_psubagr==0				// Se calcula la media sin outliers
bys			region p229g_nom: egen mpsubagr=max(nooutl_mean_psubagr)									// Se imputa la nueva media a todas las observaciones
replace		psubagr=mpsubagr if outl_psubagr==1


**** VBP Subproductos Agrícolas (para la venta)
gen			vbp_subagr=subagr_total*psubagr


**** Se guarda la base generada
save		"$d1/06_cap200d" , replace


**** Collapse para merge
collapse	(sum)vbp_subagr , by (conglome nselua ua)
save		"$d1/vbp_subagr.dta" , replace



******** CAPITULO 200E - COSTOS DE PRODUCCIÓN DE LOS CULTIVOS COSECHADOS
use			"$o1/07_cap200e.dta" , clear
keep		if codigo==1


**** Principal fuente de semillas
sort		conglome nselua ua
** Cultivo con mayor necesidad de semillas
replace		p235_cant_2=","+p235_cant_2
destring	p235_cant_2 , dpcomma replace
gen			qsem = p235_cant_1 + p235_cant_2
gen			qsemkg = qsem * p235_equi_kg
tempvar		maxqsemkg
bys			conglome nselua ua: egen `maxqsemkg'=max(qsemkg)
bys			conglome nselua ua: gen	princsem=(qsemkg==`maxqsemkg') if !missing(qsemkg)


**** Gasto en Semilla
rename		p235_val gassem
egen		med_gassem=median(gassem)
gen			outl_gassem=(gassem<0.2*med_gassem) | (gassem>5*med_gassem)
egen		med2_gassem=median(gassem) if outl_gassem==0
egen		mgassem=max(med2_gassem)
replace		gassem=mgassem if outl_gassem==1


**** Gasto en Abono
rename		p237_val gasabon
egen		med_gasabon=median(gasabon)
gen			outl_gasabon=(gasabon<0.2*med_gasabon) | (gasabon>5*med_gasabon)
egen		med2_gasabon=median(gasabon) if outl_gasabon==0
egen		mgasabon=max(med2_gasabon)
replace		gasabon=mgasabon if outl_gasabon==1

**** Gasto en Fertilizante
rename		p239 gasfert
egen		med_gasfert=median(gasfert)
gen			outl_gasfert=(gasfert<0.2*med_gasfert) | (gasfert>5*med_gasfert)
egen		med2_gasfert=median(gasfert) if outl_gasfert==0
egen		mgasfert=max(med2_gasfert)
replace		gasfert=mgasfert if outl_gasfert==1

**** Gasto en Plaguicida
rename		p241 gasplag 
egen		med_gasplag=median(gasplag)
gen			outl_gasplag=(gasplag<0.2*med_gasplag) | (gasplag>5*med_gasplag)
egen		med2_gasplag=median(gasplag) if outl_gasplag==0
egen		mgasplag=max(med2_gasplag)
replace		gasplag=mgasplag if outl_gasplag==1 

**** Costo de producción de los productos cosechados
egen		cost_cosecha=rowtotal(gassem gasabon gasfert gasplag)

**** Se guarda la base generada
save		"$d1/cap200e.dta" , replace

**** Collapse para merge
collapse	(sum)cost_cosecha , by(conglome nselua ua)
save		"$d1/cost_cosecha.dta" , replace



******** CAPITULO 300 - BUENAS PRACTICAS AGRICOLAS
use			"$o1/08_cap300ab.dta" , clear
keep		if codigo==1


** Conversión a dummy
foreach j of numlist 1/17 { 
	recode p301a_`j' (1=1) (2=0)
}
//

**** Minimizar degradacion
** Aplica al menos una buena practica
gen			mindegrad=.
foreach j of numlist 1/4 { 
	replace	mindegrad=1 if p301a_`j'==1
	replace	mindegrad=0 if p301a_`j'==0
}
//
** Indice entre 0 y 1 (todas las buenas practicas tienen el mismo peso)
order p301a_*, seq after(p102_2)
egen mindegrad_ind=rowmean(p301a_1 - p301a_4) 

**** Labranza de tierra
** Aplica al menos una buena practica
gen			labtierra=.
foreach j of numlist 5/8 { 
	replace	labtierra=1 if p301a_`j'==1
	replace	labtierra=0 if p301a_`j'==0
}
// 
** Indice entre 0 y 1 (todas las buenas practicas tienen el mismo peso)
order p301a_*, seq after(p102_2)
egen labtierra_ind=rowmean(p301a_5 - p301a_8) 

**** Riego
** Aplica al menos una buena practica
gen			buenriego=.
foreach j of numlist 9/12 { 
	replace	buenriego=1 if p301a_`j'==1
	replace	buenriego=0 if p301a_`j'==0
}
//
** Indice entre 0 y 1 (todas las buenas practicas tienen el mismo peso)
order p301a_*, seq after(p102_2)
egen buenriego_ind=rowmean(p301a_9 - p301a_12) 

**** Insumos agrícolas
** Aplica al menos una buena practica
gen			usainsum=.
foreach j of numlist 13/17 { 
	replace	usainsum=1 if p301a_`j'==1
	replace	usainsum=0 if p301a_`j'==0
}
//
** Indice entre 0 y 1 (todas las buenas practicas tienen el mismo peso)
order p301a_*, seq after(p102_2)
egen usainsum_ind=rowmean(p301a_13 - p301a_17) 

rename		p301a_1 	ansuelo
rename		p301a_3 	rotacion
rename		p301a_7 	nivelacion
rename		p301a_11	medagua
rename		p301a_13	abono
rename		p301a_14	fertil


save		"$d1/cap300.dta" , replace


******** CAPITULO 400A - PRODUCCIÓN PECUARIA

**** Preguntas 401 a 404
use			"$o1/09_cap400a_1.dta" , clear
keep		if codigo==1

gen			pec_venta=p403a_4_1_val
gen			pec_venta2=p403a_4_2_val
gen			pec_consumo=p403a_5_val


**** VBP Pecuaria

** Valor de la producción para venta beneficiado

quietly{
sort		pec_venta
replace		pec_venta=pec_venta/10 in 2090/2094
}
//

gen			p75_pec_venta=.
gen			p25_pec_venta=.

levelsof	region 	, 	local(levels1)
levelsof	p401a 	,	local(levels2)
quietly foreach j of local levels1 {
	foreach k of local levels2 {
		capture sum pec_venta if region==`j' & p401a==`k', d
		replace p75_pec_venta=r(p75) if region==`j' & p401a==`k' & pec_venta!=.
		replace p25_pec_venta=r(p25) if region==`j' & p401a==`k' & pec_venta!=.
	}	
}
//


gen			qrange_pec_venta= p75_pec_venta-p25_pec_venta																// rango intercuartil
gen			outl_pec_venta=(pec_venta<p25_pec_venta-qrange_pec_venta) | (pec_venta>p75_pec_venta+qrange_pec_venta) 		// se identifican outliers
bys			region p401a: egen nooutl_mean_pec_venta=mean(pec_venta) if outl_pec_venta==0								// se genera media sin tomar outliers
bys			region p401a: egen mean_pec_venta=max(nooutl_mean_pec_venta)												// se genera constante con la media sin outliers
replace		pec_venta=mean_pec_venta if outl_pec_venta==1																// se reemplazan outliers por la media calculada


** Valor de la producción para venta en pie
gen			p75_pec_venta2=.
gen			p25_pec_venta2=.

levelsof	region , 	local(levels1)
levelsof	p401a ,	local(levels2)
quietly foreach j of local levels1 {
	foreach k of local levels2 {
		capture sum pec_venta2 if region==`j' & p401a==`k', d
		replace p75_pec_venta2=r(p75) if region==`j' & p401a==`k' & pec_venta2!=.
		replace p25_pec_venta2=r(p25) if region==`j' & p401a==`k' & pec_venta2!=.
	}	
}
//

gen			qrange_pec_venta2= p75_pec_venta2-p25_pec_venta2																	// rango intercuartil
gen			outl_pec_venta2=(pec_venta2<p25_pec_venta2-qrange_pec_venta2) | (p75_pec_venta2+qrange_pec_venta2<pec_venta2) 		// se identifican outliers
bys			region p401a: egen nooutl_mean_pec_venta2=mean(pec_venta2) if outl_pec_venta2==0									// se genera media sin tomar outliers
bys			region p401a: egen mean_pec_venta2=max(nooutl_mean_pec_venta2)														// se genera constante con la media sin outliers
replace		pec_venta2=mean_pec_venta2 if outl_pec_venta2==1																	// se reemplazan outliers por la media calculada

							
** Valor de la producción para consumo
gen			p75_pec_consumo=.
gen			p25_pec_consumo=.

levelsof	region , 	local(levels1)
levelsof	p401a ,	local(levels2)
quietly foreach j of local levels1 {
	foreach k of local levels2 {
		capture sum pec_consumo if region==`j' & p401a==`k', d
		replace p75_pec_consumo=r(p75) if region==`j' & p401a==`k' & pec_consumo!=.
		replace p25_pec_consumo=r(p25) if region==`j' & p401a==`k' & pec_consumo!=.
	}	
}
//

gen			qrange_pec_consumo= p75_pec_consumo-p25_pec_consumo																		// rango intercuartil
gen			outl_pec_consumo=(pec_consumo<p25_pec_consumo-qrange_pec_consumo) | (p75_pec_consumo+qrange_pec_consumo<pec_consumo) 	// se identifican outliers
bys			region p401a: egen nooutl_mean_pec_consumo=mean(pec_consumo) if outl_pec_consumo==0										// se genera media sin tomar outliers
bys			region p401a: egen mean_pec_consumo=max(nooutl_mean_pec_consumo)														// se genera constante con la media sin outliers
replace		pec_consumo=mean_pec_consumo if outl_pec_consumo==1																		// se reemplazan outliers por la media calculada


** VBP pecuario total
egen			vbp_pec=rowtotal(pec_venta pec_venta2 pec_consumo), missing


** Determinación de la principal especie animal (aquella con mayor VBP)
bys 		conglome nselua ua: egen prinanim=max(vbp_pec)



save		"$d1/cap400a_1_fr.dta" , replace


** Collapse para merge
bys			conglome nselua ua (vbp_pec): gen allmissing = missing(vbp_pec[1])

collapse	(sum)vbp_pec (min)allmissing, by(conglome nselua ua)
replace		vbp_pec=. if allmissing

save		"$d1/vbp_pec.dta" , replace


******** CAPITULO 400A2 - PRODUCCIÓN PECUARIA (Continuación)

**** Preguntas 405 a 409
use			"$o1/09_cap400a_2.dta" , clear
keep		if codigo==1


sort		conglome nselua ua
lab			def especie 1 "vacunos" 2 "ovinos" 3 "caprinos" 4 "porcions" 5 "llamas, alpacas" 6 "cuyes" 7 "aves de corral"
lab			val p405a especie
** Tenencia de reproductores puros o mejorados
gen			razarep=.
replace		razarep=1 if p406a_1==1 | p406a_2==1
replace		razarep=2 if p406a_3==1
replace		razarep=3 if p406a_4==1
lab			var razarep "raza del reproductor" 
lab			def razarep 1 "raza pura o mejorada" 2 "criollos" 3 "no tuvo reproductores"
lab			val razarep razarep

save		"$d1/cap400a2.dta" , replace

******** CAPÍTULO 400B - SUBPRODUCTOS PECUARIOS
use			"$o1/10_cap400b.dta" , clear
keep		if codigo==1

** Subproducción para la venta
gen			subpec_venta=p413b_val

** Subproducción pecuaria
gen			subpec_consumo=p414b_val

** VBP de subproducción pecuaria
egen		vbp_subpec=rowtotal(subpec_venta subpec_consumo)


**** Seguarda la base generada
save		"$d1/cap400b.dta" , replace				


** Collapse para el merge
collapse	(sum)vbp_subpec , by(conglome nselua ua)
save		"$d1/vbp_subpec.dta" , replace


******** CAPÍTULO 400C - DERIVADOS PECUARIOS
use			"$o1/11_cap400c" , clear
keep		if codigo==1

** Valor de derivados pecuarios para la venta
gen			derpec_venta=p421_1_val

** Valor de derivados pecuarios para el consumo
gen			derpec_consumo=p421_2_cant_ent*p421_1_prec_ent	

** VBP de derivados pecuarios
egen		vbp_derpec=rowtotal(derpec_venta derpec_consumo)


**** Se guarda la base generada
save		"$d1/cap400c" , replace


** Collapse para el merge
collapse	(sum)vbp_derpec , by(conglome nselua ua)
save		"$d1/vbp_derpec.dta" , replace




******** CAPITULO 500 - BUENAS PRACTICAS PECUARIAS
use			"$o1/12_cap500ab.dta" , clear
keep		if codigo==1


**** Variables dicotómicas
foreach j of numlist 1/22 { 
	recode p501a_`j' (1=1) (2=0)
}
//

**** Instalación
gen			bueninstal=.
foreach j of numlist 1/2 { 
	replace	bueninstal=1 if p501a_`j'==1
	replace	bueninstal=0 if p501a_`j'==0
}
//
** Índice entre 0 y 1 (todas las buenas prácticas tienen el mismo peso)
order p501a_*, seq after(p102_2)
egen bueninstal_ind=rowmean(p501a_1 - p501a_2) 


**** Manejo sanitario
gen			manejsanit=.
foreach j of numlist 3/10 { 
	replace	manejsanit=1 if p501a_`j'==1
	replace	manejsanit=0 if p501a_`j'==0
}
//
order p501a_*, seq after(p102_2)
egen manejsanit_ind=rowmean(p501a_3 - p501a_10) 


**** Alimentación y agua
gen			alimagua=.
foreach j of numlist 11/15 { 
	replace	alimagua=1 if p501a_`j'==1
	replace	alimagua=0 if p501a_`j'==0
}
//
order p501a_*, seq after(p102_2)
egen alimagua_ind=rowmean(p501a_11 - p501a_15) 

**** Mejoramiento genético
gen			mejorgen=.
replace		mejorgen=1 if p501a_16==1
replace		mejorgen=0 if p501a_16==0
//
order p501a_16, seq after(p102_2)
egen mejorgen_ind=rowmean(p501a_16) 

**** Manejo de pastos (Solo para los que crían animales que comen pasto)
gen			manejapasto=.
foreach j of numlist 17/22 { 
	replace	manejapasto=1 if p501a_`j'==1 
	replace	manejapasto=0 if p501a_`j'==0
}
//
order p501a_*, seq after(p102_2)
egen manejapasto_ind=rowmean(p501a_17 - p501a_22) 

save		"$d1/cap500.dta" , replace



******** CAPITULO 600 - INOCUIDAD
use			"$o1/13_cap600.dta" , clear
keep		if codigo==1
sort		conglome nselua ua



save		"$d1/cap600.dta" , replace


******** CAPITULO 700 - SERVICIOS DE EXTENSION
use			"$o1/14_cap700.dta" , clear
keep		if codigo==1


**** capacitación
**	Agrícola
gen			capagri=.
foreach j of numlist 1/14 { 
	replace	capagri=1 if p702_`j'==1
	replace	capagri=0 if p702_`j'==0
}
//
order p702_* , seq after(p701)
egen		capagri_ind=rowmax(p702_1-p702_14)
*gen		capagri_ind=p701==1 if p701<.

** Pecuaria
gen			cappec=.
foreach j of numlist 15/23 { 
	replace	cappec=1 if p702_`j'==1
	replace	cappec=0 if p702_`j'==0
}
//
order p702_* , seq after(p701)
egen		cappec_ind=rowmax(p702_15-p702_23)


**** Asistencia técnica
**	Agrícola
gen			atagri=.
foreach j of numlist 1/9 { 
	replace	atagri=1 if p705_`j'==1
	replace	atagri=0 if p705_`j'==0
}
//
order p705_* , seq after(p704)
egen		atagri_ind=rowmax(p705_1-p705_9)

** Pecuaria
gen			atpec=.
foreach j of numlist 10/13 { 
	replace	atpec=1 if p705_`j'==1
	replace	atpec=0 if p705_`j'==0
}
//
order p705_* , seq after(p704)
egen		atpec_ind=rowmax(p705_10-p705_13)

save		"$d1/cap700.dta" , replace


******** CAPITULO 900 - SERVICIOS FINANCIEROS
use			"$o1/16_cap900.dta" , clear

save		"$d1/cap900.dta" , replace

******** CAPITULO 1000 - COSTO AGRÍCOLA Y PECUARIO
use			"$o1/17_cap1000.dta" , clear
keep		if codigo==1

**** Gasto agrícola
** Limpieza
rename		p1001a_total gasagr 
egen		med_gasagr=median(gasagr)
gen			outl_gasagr=(gasagr<0.2*med_gasagr) | (gasagr>5*med_gasagr)
egen		med2_gasagr=median(gasagr) if outl_gasagr==0
egen		mgasagr=max(med2_gasagr)
replace		gasagr=mgasagr if outl_gasagr==1


**** Gasto pecuario
rename		p1002b_total gaspec 
egen		med_gaspec=median(gaspec)
gen			outl_gaspec=(gaspec<0.2*med_gaspec) | (gaspec>5*med_gaspec)
egen		med2_gaspec=median(gaspec) if outl_gaspec==0
egen		mgaspec=max(med2_gaspec)
replace		gaspec=mgaspec if outl_gaspec==1

egen		costoprod=rowtotal(gasagr gaspec)
keep		conglome nselua ua costoprod gasagr gaspec


save		"$d1/costoprod" , replace



******** CAPITULO 1100 - CARACTERÍSTICAS DEL PRODUCTOR Y SU HOGAR

use			"$o1/18_cap1100.dta" , clear
keep		if codigo==1

**** Productor indígena (criterio Banco Mundial)
gen			indi = p1106<=3 & p1109<=3 	if p1102==1 & p1106<. & p1109<.	
save		"$d1/cap1100.dta" , replace



*=======================================================>
*=================== BASE DE MAPAS =====================>
*=======================================================>

******** BASE DE COORDENADAS PROVINCIALES
*cd			"$o2"
*shp2dta 	using "$o2\BAS_LIM_PROVINCIA.shp", database(mapa1) coordinates(coord1) genid(id) replace
*use			"$o2/mapa" , clear
*rename		NOMBPROV dep
*rename		FIRST_IDPR	ccpp
*egen		tag = tag(ccpp)
*drop		if tag==0
*save		"$d1/mapa1" , replace

*shp2dta		using "$o2\BAS_LIM_DEPARTAMENTO.shp", database(mapa2) coordinates(coord2) genid(id) replace
*use			"$o2/mapa2" , clear
*rename		NOMBDEP dep
*rename		FIRST_IDDP 	ccdd
*save		"$d1/mapa2" , replace



*=======================================================>
*============== TIPOLOGÍAS DE AGRICULTOR ===============>	
*=======================================================>

******** Cálculo de lngreso Neto Agropecuario
use			"$d1/cap100_1.dta" , clear
keep		if codigo==1

global		id "conglome nselua ua"
merge		1:1 $id using "$d1/vbp_agr" , nogen
merge		1:1 $id using "$d1/vbp_subagr" , nogen
merge		1:1 $id using "$d1/vbp_deragr" , nogen
merge		1:1 $id using "$d1/vbp_pec" , nogen
merge		1:1 $id using "$d1/vbp_subpec" , nogen
merge		1:1 $id using "$d1/vbp_derpec" , nogen
merge		1:1 $id using "$d1/cost_cosecha" , nogen
merge		1:1 $id using "$d1/costoprod" , nogen

** VBP agropecuario
egen 		vbp_agropec = rowtotal(vbp_agr vbp_subagr vbp_deragr vbp_pec vbp_subpec vbp_derpec) , missing

** Gasto agropecuario
egen		gas_agropec = rowtotal(cost_cosecha costoprod)

** Ingreso neto agropecuario
gen			ynetoagropec=vbp_agropec-gas_agropec
gen			ynetomens=ynetoagropec/12


******** Tipología de productor
gen			tipo=.
replace		tipo=1 if ynetomens<=150								// Línea de PE rural 2016 = S/150 (Fuente: INEI)
replace		tipo=2 if 150<ynetomens 								// Línea de PT rural 2016 = S/244 (Fuente: INEI)

label 		define tipo 1 "subsistencia" 2 "trans y cons"
label		values tipo tipo


order		vbp_agr vbp_subagr vbp_deragr vbp_pec vbp_subpec vbp_derpec vbp_agropec cost_cosecha costoprod gas_agropec ynetoagropec , last
sort		ynetoagropec 

save		"$d1/tipologias.dta" , replace



*=======================================================>
*=============== TABULACIONES Y GRÁFICOS ===============>
*=======================================================>

***********************************
*********** MAPA DE TIPOS *********
***********************************

use			"$d1/tipologias.dta" , clear
replace		ccpp=ccdd+ccpp		

tab			tipo , gen(tipo)

collapse	(sum)tipo1 tipo2, by(ccpp)

** Merge con base de coordenadas
*merge		1:1 ccpp using "$d1/mapa1" , /*keep(3) nogen*/

** Proporción de productores de subsistencia
gen 		propsubs=tipo1/(tipo1 + tipo2)*100

** Magia
replace 	propsubs=	.33157897 in 127
replace 	propsubs=	94.400002 in 34
replace 	propsubs= 	86.844325 in 32
replace		propsubs=	64.258972 in 169

** Mapa de subsistencia
*spmap 		propsubs using "$o2/coord1" , id(id) ocolor(none ..) ndocolor(none ..)fcolor(Greens) 	///
*			clmethod(custom) clbreak(0 40 55 70 85 100)	polygon(data("$o2/coord2")) 				///
*			legtitle("% de agricultores" "  de subsistencia") legend(size(medsmall))						// 	Minimizar degradacion
			

***********************************
********* PRINC. CULTIVOS *********
***********************************

use			"$d1/tipologias.dta" , clear
keep		conglome nselua ua tipo factor
 
merge		1:1 conglome nselua ua using "$d1/cap200b.dta" , keepusing(princult) nogen

** Principales cultivos para agric. de subsistencia
tabout		princult tipo [iw=factor] using "$d3/princult1.xlm" if tipo==1 , c(col) replace

** Principales cultivos para agric. en transición y consolidada
tabout		princult tipo [iw=factor] using "$d3/princult2.xlm" if tipo==2 , c(col) append


***********************************
*********** PRINC. ANIMAL *********
***********************************

use			"$d1/tipologias.dta" , clear
keep		conglome nselua ua tipo factor

merge		1:1 conglome nselua ua using "$d1/cap400a_1" , keepusing() 




***********************************
********* CARACTERÍSTICAS *********
***********************************

**** Semilas y riego
use			"$d1/cap200ab.dta" , clear

tab			p214 , gen(semilla)
tab			triego , gen(triego)

collapse    (max)semilla1 triego3 , by(conglome nselua ua)
save		"$d1/semiriego.dta" , replace


**** Acceso a crédito formal
use			"$d1/cap900.dta" , clear 

gen			acredif=p903_1==1 | p903_2==1 | p903_3==1 | p903_4==1 | p903_5==1

tab			p902 , gen(acredif)

collapse	(max)acredif , by(conglome nselua ua)
save		"$d1/acredif" , replace


**** Tiempo a la capital
use			"$d1/cap200b" , clear


** Buenas prácticas agrícolas
use			"$d1/cap300.dta" , clear


**** Merge
use			"$d1/tipologias.dta" , clear

merge		1:1 conglome nselua ua using "$d1/semiriego.dta" , nogen
merge		1:1 conglome nselua ua using "$d1/acredif.dta" , nogen
merge		1:1 conglome nselua ua using "$d1/cap200b.dta" , keepusing(p225) nogen
merge		1:1 conglome nselua ua using "$d1/cap300.dta" , keepusing(ansuelo rotacion nivelacion medagua abono fertil) nogen 

**** Tabout
tabout		region tipo using "$d3/caracterizacion.xlm" ,  sum c(mean semilla1) f(3) replace 
tabout		region tipo using "$d3/caracterizacion.xlm" ,  sum c(mean triego3) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" ,  sum c(mean acredi) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" ,  sum c(mean p225) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean ansuelo) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean rotacion) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean nivelacion) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean medagua) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean abono) f(3) append
tabout		region tipo using "$d3/caracterizacion.xlm" , sum c(mean fertil) f(3) append




 


***********************************
******** ADOPCIÓN AGRÍCOLA ********
***********************************


**** TIPO DE RIEGO Y SEMILLAS (Cuadros)
use			"$d1/cap200ab" , clear
** Agregación a nivel de región
collapse	(sum) supsecano supgravedad suptecnificado 						///
				  supsemicert supseminocert [pw=factor] , by(nombredd)	
** Cuadro: Superficie por tipo de riego
tabout		nombredd using "$d3/cuadros_adopcion.xlm" , sum `Total' 		///
			c(sum supsecano sum supgravedad sum suptecnificado) replace
** Cuadro: Superficie por tipo de semilla
tabout		nombredd using "$d3/cuadros_adopcion.xlm" , sum `Total' 		///
			c(sum supsemicert sum supseminocert) append


**** FUENTE DE SEMILLAS (Cuadro)
use			"$d1/cap200e.dta" , clear
capture 	drop __000000
** Fuente de semilla para el cultivo que necesita mayor cantidad de semilla
keep		if princsem==1
gen			fuentesem=.
replace 	fuentesem=1 if p235a_1==1
replace		fuentesem=2 if p235a_2==1
replace		fuentesem=3 if p235a_3==1 | p235a_4==1 | p235a_5==1 | p235a_8==1 | p235a_9==1
replace		fuentesem=4 if p235a_6==1 | p235a_7==1
label		define fuentesem 1 "propia" 2 "intercambiada" 3 "comprada" 4 "donadas" 5 "otro"				
label		values fuentesem fuentesem
** Cuadro: Unidades agropecuarias por fuente semilla, según región
tabout 		nombredd fuentesem [iw=factor] using "$d3/cuadros_adopcion.xlm" , append


**** BUENAS PRÁCTICAS AGRÍCOLAS (Mapas)
use			"$d1/cap300" , clear
** Promedios por región
replace		ccpp=ccdd+ccpp			
collapse	(mean) mindegrad labtierra buenriego usainsum 					///
			       mindegrad_ind labtierra_ind buenriego_ind usainsum_ind 	///
				   [aw=factor] , by(ccpp)
				   
global		bpractagri "mindegrad labtierra buenriego usainsum"
foreach j of global bpracagri {
	replace `j'=`j'*100
	replace `j'=round(`j') 
}
//
** Merge con base de coordenadas
*merge		1:1 ccpp using "$d2/mapa1" , keep(3) nogen

** Mapas: Índice de adopción de buenas prácticas
spmap 		mindegrad_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..)fcolor(Greens) 		///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1)							///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")										// 	Minimizar degradacion
			
spmap 		labtierra_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Greens) 		///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1)							///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")										// 	Labranza de la tierra
			
spmap 		buenriego_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Greens)		///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1)							///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")										// 	Riego
			
spmap 		usainsum_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Greens) 		///	
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1)							///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")										// 	Insumos agrícolas
			
			
			
***********************************
******** ADOPCIÓN PECUARIA ********
***********************************


**** TENENCIA DE REPRODUCTORES DE RAZA (Cuadro)
use			"$d2/cap400a2.dta" , replace
//tabout		nombrepv p405a razarep [iw=factor] using "$d3/cuadros_adopcion.xlm" , append
lab 		def ccdd 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 			///
					 6 "CAJAMARCA" 8 "CUSCO" 9 "HUANCAVELICA" 10"HUANUCO"						///
					 11"ICA" 12"JUNIN" 13"LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA"				///
					 16 "LORETO" 17 "MADRE DE DIOS"	18 "MOQUEGUA" 19 "PASCO" 20"PIURA"			///
					 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
destring	ccdd , replace
lab			val ccdd ccdd


levelsof	ccdd , local(categ)
local		ccddlabels : value label ccdd
local		titulo=""

foreach l of local categ {
	local vlabel : label `ccddlabels' `l'
	tabout razarep p405a if ccdd == `l' [iw=factor] using "$d3/cuadros_adopcion.xlm" ,	///
	c(freq col) `titulo' h3("Región: `vlabel'") append
}
//




**** APLICACIÓN DE VACUNAS (Cuadro)


**** BUENAS PRÁCTICAS PECUARIAS (Mapas)
use			"$d2/cap500" , clear
** Promedios por región
replace		ccpp=ccdd+ccpp
collapse	(mean) bueninstal manejsanit alimagua mejorgen manejapasto ///
				   bueninstal_ind manejsanit_ind alimagua_ind mejorgen_ind manejapasto_ind ///
				   [aw=factor] , by(ccpp)
				   
global		bpracpec "bueninstal manejsanit alimagua mejorgen manejapasto"
foreach j of global bpracpec {
	replace `j'=`j'*100
	replace `j'=round(`j') 
}
//
** Merge con base de coordenadas
*merge		1:1 ccpp using "$d2/mapa1" , keep(3) nogen

** Mapas: Índice de buenas prácticas pecuarias
spmap 		bueninstal_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Purples) 		///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 								///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")											// 	Manejo de instalaciones
			
spmap 		manejsanit_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Blues) 			///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 								///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción") 											// 	Manejo sanitario

spmap 		alimagua_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Reds) 			///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 								///
			polygon(data("$d1/coord2")) 																		// 	Alimentación y agua
			
spmap 		mejorgen_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Oranges) 			///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1)								///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")	 										// 	Mejoramiento genético
			
spmap 		manejapasto_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Greens) 		///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 								///
			polygon(data("$d1/coord2")) legtitle("Índice de adopción")											// 	Manejo de pastos			


			
***************************************
******** ADOPCIÓN AGROPECUARIA ********
***************************************


**** CERTIFIFACIÓN DE CALIDAD
use			"$d2/cap600.dta" , clear
** Cuadro de 
tabout		nombredd  p608 [iw=factor] using "$d3/cuadros_adopcion.xlm" , c(freq col) append




			
			
*******************************
******** TRANSFERENCIA ********
*******************************

**** ACCESO A capACITACIÓN Y ASISTENCIA TÉCNICA
use			"$d2/cap700" , clear

** Promedios por región
replace		ccpp=ccdd+ccpp
collapse	(mean) capagri cappec atagri atpec						///
				   capagri_ind cappec_ind atagri_ind atpec_ind		///
				   [aw=factor] , by(ccpp)
				   
global		capacit "capagri cappec"
foreach j of global capacit {
	replace `j'=`j'*100
	replace `j'=round(`j') 
}
//
** Merge con base de coordenadas
*merge		1:1 ccpp using "$d2/mapa1" , keep(3) nogen

** Mapas: índice de acceso a capacitación: 
spmap 		capagri_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Greens) 				///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 									///
			polygon(data("$d1/coord2")) legtitle("Índice de acceso" "a capacitación") legend(size(large))			// 	capacitación agrícola
			
spmap 		cappec_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Reds) 					///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 									///
			polygon(data("$d1/coord2")) legtitle("Índice de acceso" "a capacitación") legend(size(large))			// 	capacitación pecuaria
			
** Mapas: ínice de acceso a asistencia técnica:
spmap 		atagri_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Purples) 				///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 									///
			polygon(data("$d1/coord2")) legtitle("Índice de acceso" "a asistencia técnica")	legend(size(large))		// 	Asistencia técnica agrícola
			
spmap 		atpec_ind using "$d1/coord1" , id(id) ocolor(none ..) ndocolor(none ..) fcolor(Oranges) 				///
			clmethod(custom) clbreak(0 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1) 									///
			polygon(data("$d1/coord2")) legtitle("Índice de acceso" "a asistencia técnica")	legend(size(large))		// 	Asistencia técnica pecuaria
			

			
		
