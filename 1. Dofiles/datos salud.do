clear all

cd "D:\Backup_SPAZ\CPC 2019 (carpeta ordenada)\2. Factores (mesas CPC)\8. Salud\Data"

* Bases ENAHO 2014- 2018
* ------------------------------------------------------------------------------
/*
forvalues x=2014/2018 {

use `x'/enaho01-`x'-100.dta, clear
merge 1:1 conglome vivienda hogar using `x'/sumaria-`x'.dta, keep(match) nogen

merge 1:m conglome vivienda hogar using `x'/enaho01a-`x'-400.dta, keep(match) nogen

g year=`x'

save enaho_`x'.dta, replace
}

forvalues x=2014/2017 {
	append using enaho_`x', force
}

save enaho-2014-2018.dta, replace

*/
use enaho-2014-2018.dta, replace

* Desagregaciones
* ------------------------------------------------------------------------------

* Urbano/rural

gen 	urbano=1 if estrato>=1 & estrato<=5
replace urbano=0 if estrato==6 | estrato==7 | estrato==8
replace urbano=. if estrato==.

la def urbano 1 "Urbano" 0 "Rural"
la val urbano urbano
la var urbano "Área (Urbano=1, Rural=0)"

* Tiene seguro

gen seguro=0
for num 1/8: replace seguro=1 if p419X==1 

* Tipo de seguro

g tipo_seguro = 0
for num 1/8: replace tipo_seguro = X if p419X==1

replace tipo_seguro=. if p4191==.

#delimit ;
la def tipo_seguro 1 "EsSalud" 2 "Privado" 3 "Entidad prestadora de salud" 
				   4 "FF.AA." 5 "SIS" 6 "Seguro universitario" 
				   7 "Seguro escolar privado" 8 "Otro" ;
#delimit cr

la val tipo_seguro tipo_seguro
la var tipo_seguro "Tipo de seguro"

* Grupo de edad

gen 	grupo_edad=0
replace grupo_edad=1 if p208a>14 & p208a<25
replace grupo_edad=2 if p208a>24 & p208a<45
replace grupo_edad=3 if p208a>44 

la def grupo_edad 0 "<15 años" 1 "15-24 años" 2 "25-43 años" 3 ">44 años"
la val grupo_edad grupo_edad
la var grupo_edad "Grupo de edad"

* Sexo

recode p207 1=1 2=0
rename p207 sexo
la var sexo "Sexo (Hombre=1, Mujer=0)"
la def sexo 1 "Hombre" 0 "Mujer"
la val sexo sexo 

* Recibió servicio de salud
* ------------------------------------------------------------------------------

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

g		n_`x' = (p414_`x'==1)
replace n_`x'=. if p414_`x'==.

}

la var n_01 "Recibió consulta en las últimas 4 semanas (=1)"
la var n_02 "Recibió medicinas en las últimas 4 semanas (=1)"
la var n_03 "Recibió análisis en las últimas 4 semanas (=1)"
la var n_04 "Recibió rayos x, tomografía, etc. en las últimas 4 semanas (=1)"
la var n_05 "Recibió otros exámenes en las últimas 4 semanas (=1)"
la var n_06 "Recibió servicio dental en los últimos 3 meses (=1)"
la var n_07 "Recibió servicio oftalmológico en los últimos 3 meses (=1)"
la var n_08 "Compra de lentes en los últimos 3 meses (=1)"
la var n_09 "Recibió vacunas en los últimos 3 meses (=1)"
la var n_10 "Recibió control de salud de los niños en los últimos 3 meses (=1)"
la var n_11 "Recibió anticonceptivos en los últimos 3 meses (=1)"
la var n_12 "Otros gastos (ortopedia, termómetro, etc.) en los últimos 3 meses (=1)"
la var n_13 "Recibió hospitalización en los últimos 12 meses (=1)"
la var n_14 "Recibió intervenciones quirúrgicas en los últimos 12 meses (=1)"
la var n_15 "Recibió controles por embarazo en los últimos 12 meses (=1)"
la var n_16 "Recibió atencón de parto en los últimos 12 meses (=1)"

* Tablas
* ------------------------------------------------------------------------------

* Cuánta gente recibió cada servicio

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

tab n_`x' year [fw=round(factor07)], matcell(gasto_`x')
mat gasto_1_`x'=gasto_`x'[2..2,1..5] 		// cuánta gente incurrió en gasto, por año
mat gasto_0_`x'=gasto_`x'[1..1,1..5]		// cuánta gente no incurrió en gasto, por año

tab n_`x' [fw=round(factor07)], matcell(gasto_t_`x')
mat gasto_1t_`x'=gasto_t_`x'[2,1]			// total cuánta gente sí incurrió
mat gasto_0t_`x'=gasto_t_`x'[1,1]			// no incurrió
}

#delimit ;
mat gasto_1 = [ gasto_1_01, gasto_1t_01 \ gasto_1_02, gasto_1t_02 \ gasto_1_03, gasto_1t_03 \
				gasto_1_04, gasto_1t_04 \ gasto_1_05, gasto_1t_05 \ gasto_1_06, gasto_1t_06 \
				gasto_1_07, gasto_1t_07 \ gasto_1_08, gasto_1t_08 \ gasto_1_09, gasto_1t_09 \
				gasto_1_10, gasto_1t_10 \ gasto_1_11, gasto_1t_11 \ gasto_1_12, gasto_1t_12 \
				gasto_1_13, gasto_1t_13 \ gasto_1_14, gasto_1t_14 \ gasto_1_15, gasto_1t_14 \
				gasto_1_16, gasto_1t_16 ]
; 
#delimit cr

#delimit ;
mat gasto_0 = [ gasto_0_01, gasto_0t_01 \ gasto_0_02, gasto_0t_02 \ gasto_0_03, gasto_0t_03 \
				gasto_0_04, gasto_0t_04 \ gasto_0_05, gasto_0t_05 \ gasto_0_06, gasto_0t_06 \
				gasto_0_07, gasto_0t_07 \ gasto_0_08, gasto_0t_08 \ gasto_0_09, gasto_0t_09 \
				gasto_0_10, gasto_0t_10 \ gasto_0_11, gasto_0t_11 \ gasto_0_12, gasto_0t_12 \
				gasto_0_13, gasto_0t_13 \ gasto_0_14, gasto_0t_14 \ gasto_0_15, gasto_0t_14 \
				gasto_0_16, gasto_0t_16 ]
; 
#delimit cr

mat lis gasto_1, format(%15.0f)
mat lis gasto_0, format(%15.0f)

* Cuanta gente Realizó un pago (por algún miembro del hogar)?

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

tab p4151_`x' year [fw=round(factor07)], matcell(pago_`x')
mat pago_1_`x'=pago_`x'[2..2,1..5] 		// cuánta gente pagó, por año

tab p4151_`x' [fw=round(factor07)], matcell(pago_t_`x')
mat pago_1t_`x'=pago_t_`x'[2,1]			// total cuánta pagó

}

#delimit ;
mat pago_1 = [ pago_1_01, pago_1t_01 \ pago_1_02, pago_1t_02 \ pago_1_03, pago_1t_03 \
				pago_1_04, pago_1t_04 \ pago_1_05, pago_1t_05 \ pago_1_06, pago_1t_06 \
				pago_1_07, pago_1t_07 \ pago_1_08, pago_1t_08 \ pago_1_09, pago_1t_09 \
				pago_1_10, pago_1t_10 \ pago_1_11, pago_1t_11 \ pago_1_12, pago_1t_12 \
				pago_1_13, pago_1t_13 \ pago_1_14, pago_1t_14 \ pago_1_15, pago_1t_14 \
				pago_1_16, pago_1t_16 ]
; 
#delimit cr

mat lis pago_1, format(%15.0f)

* cubierto por essalud/ffaa/policiales

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

tab p4157_`x' year [fw=round(factor07)], matcell(essalud_`x')
mat essalud_1_`x'=essalud_`x'[2..2,1..5] 		

tab p4157_`x' [fw=round(factor07)], matcell(essalud_t_`x')
mat essalud_1t_`x'=essalud_t_`x'[2,1]			

}

#delimit ;
mat essalud_1 = [ essalud_1_01, essalud_1t_01 \ essalud_1_02, essalud_1t_02 \ essalud_1_03, essalud_1t_03 \
				essalud_1_04, essalud_1t_04 \ essalud_1_05, essalud_1t_05 \ essalud_1_06, essalud_1t_06 \
				essalud_1_07, essalud_1t_07 \ essalud_1_08, essalud_1t_08 \ essalud_1_09, essalud_1t_09 \
				essalud_1_10, essalud_1t_10 \ essalud_1_11, essalud_1t_11 \ essalud_1_12, essalud_1t_12 \
				essalud_1_13, essalud_1t_13 \ essalud_1_14, essalud_1t_14 \ essalud_1_15, essalud_1t_14 \
				essalud_1_16, essalud_1t_16 ]
; 
#delimit cr

mat lis essalud_1, format(%15.0f)

* gasto promedio por servicio

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

mean p416`x' [pw=round(factor07)], over(year)
mat mean_gasto_`x'=e(b)		

mean p416`x'[pw=round(factor07)]
mat mean_gastot_`x'=e(b)		

}

#delimit ;
mat mean_gasto= [ mean_gasto_01, mean_gastot_01 \ mean_gasto_02, mean_gastot_02 \ mean_gasto_03, mean_gastot_03 \
				mean_gasto_04, mean_gastot_04 \ mean_gasto_05, mean_gastot_05 \ mean_gasto_06, mean_gastot_06 \
				mean_gasto_07, mean_gastot_07 \ mean_gasto_08, mean_gastot_08 \ mean_gasto_09, mean_gastot_09 \
				mean_gasto_10, mean_gastot_10 \ mean_gasto_11, mean_gastot_11 \ mean_gasto_12, mean_gastot_12 \
				mean_gasto_13, mean_gastot_13 \ mean_gasto_14, mean_gastot_14 \ mean_gasto_15, mean_gastot_14 \
				mean_gasto_16, mean_gastot_16 ]
; 
#delimit cr

mat lis mean_gasto, format(%15.2f)

* a) gasto promedio diferenciando urbano-rural

foreach x in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" {

mean p416`x' [pw=round(factor07)], over(urbano)
mat m_gasto_`x'=e(b)		

}

#delimit ;
mat m_gasto= [ m_gasto_01 \ m_gasto_02 \ m_gasto_03 \
				m_gasto_04 \ m_gasto_05 \ m_gasto_06 \
				m_gasto_07 \ m_gasto_08 \ m_gasto_09 \
				m_gasto_10 \ m_gasto_11 \ m_gasto_12 \
				m_gasto_13 \ m_gasto_14 \ m_gasto_15 \
				m_gasto_16 ]
; 
#delimit cr

mat lis m_gasto, format(%15.2f)


* gasto en consultas y medicinas

*gashog2d

mean i41601 [pw=factor07], over(year)

mean i41601 [pw=factor07], over(tipo_seguro)

mean i41601 [pw=factor07]
tabstat i41601 [aw=factor07], stat(mean sd)


mean i41601 i41602 [pw=factor07], over(seguro)


mean p41601 p41602 [pw=factor07], over(sexo)
mean p41601 p41602 [pw=factor07], over(grupo_edad)
mean p41601 p41602 [pw=factor07], over(tipo_seguro)
mean p41601 p41602 [pw=factor07], over(pobreza)

* Gasto en salud Sumaria 

keep if p203==1 // Jefe de hogar

egen gsalud= rowtotal(gru5*)
gen gsalud_neto= gru51hd

g gsalud_total1 = gsalud/gashog2d  //gasto bruto en salud autoconsumo + donaciones + bienes libres, etc) / gasto bruto del hogar
g gsalud_total2 = gsalud_neto/gashog1d  // gasto neto en salud / gasto monetario del hogar


* Tipo de seguro
mean gsalud [pw=factor07], over(tipo_seguro)
mean gsalud_neto [pw=factor07], over(tipo_seguro)
mean gsalud_total1 [pw=factor07], over(tipo_seguro)
mean gsalud_total2 [pw=factor07], over(tipo_seguro)

*Pobreza
mean gsalud [pw=factor07], over(pobreza)
mean gsalud_neto [pw=factor07], over(pobreza)
mean gsalud_total1 [pw=factor07], over(pobreza)
mean gsalud_total2 [pw=factor07], over(pobreza)

* Nivel de ingresos del hogar

xtile nivel_ing= inghog2d, nquantiles(5) //quintiles del ingreso neto total

mean gsalud [pw=factor07], over(nivel_ing)
mean gsalud_neto [pw=factor07], over(nivel_ing)
mean gsalud_total1 [pw=factor07], over(nivel_ing)
mean gsalud_total2 [pw=factor07], over(nivel_ing)





