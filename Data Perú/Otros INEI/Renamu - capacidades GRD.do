/*******************************************************************************
Proyecto: UNICEF - Niñas, niños y adolescentes
Objetivo: Análisis de capacidades de las municipalidades en la GRD
Autores:  CN

Objetivo: 	Análisis de las capacidades de los municipios en sus funciones de GRD
			diferenciando por los eventos o emergencias que enfrentan.

Estructura:
	0. Direcciones
    1. Indicadores RENAMU
	2. Tablas de salida
			
*******************************************************************************/
*	0. Direcciones

	global basex "G:\.shortcut-targets-by-id\1VhdDfr_V-4EYboWH5jjzQiztN2L_fPSJ\Documents\0. Bases de datos\5. RENAMU"

*******************************************************************************/
*    1. Indicadores RENAMU
	
	use "$basex\c16_2019.dta", clear
	
	*Generamos las variables de emergencias

	rename (p94_1 p94_16) (sismos incendios)
	
	replace incendios=1 if incendios==16
	
	gen huaycos_deslizam=cond(p94_3==3 | p94_5==5 , 1 , cond(p94_3==. | p94_5==. , . , 0))
	
	gen bajas_temp=cond(p94_7==7 | p94_8==8,1,cond(p94_7==. | p94_8==.,.,0))

	gen lluvia_inund=cond(p94_10==10 | p94_12==12,1,cond(p94_10==. | p94_12==. ,. ,0))
	
	*Generamos las variables de capacidades
	
		*Instrumentos de gestión - Municipalidades con al menos un instrumento de GRD
		
		foreach x of numlist 1/10{
		replace p82_`x'=0 if p82_`x'==2
		}
		
		egen instrumentos_grd=rowtotal(p82_1-p82_10)
		replace instrumentos_grd=1 if instrumentos_grd>0
		
		
		*Defensa civil - Municipalidades con área, oficina, plataforma o brigada de defensa civil
		
		foreach x of numlist 83 84 89{
		replace p`x'=0 if p`x'==2
		}
		
		egen area_def_civil=rowtotal(p83 p84 p89)
		replace area_def_civil=1 if area_def_civil>0
				
		*Centro de Operaciones de Emergencia Local - Municipalidades con COEL
		
		gen coel=cond(p85_1==.,.,cond(p85_1==1 | p85_1==2 ,1,0))
		
		*Almacén de ayuda humanitaria - Municipalidades con almacén de ayuda humanitaria
		
		gen almacen_local=cond(p88==.,.,cond(p88==1 ,1,0))
		
		*Personal dedicado a GRD - Municipalidades con personal dedicado a GRD
		
		gen personal_grd=cond(p91_1==.,.,cond(p91_1==1 | p91_1==2 ,1,0))

		*PIP en PP 068 - Municipalidades con PIP en PP068
		
		gen pip_pp068=cond(p92==.,.,cond(p92==1 ,1,0))

		*Informes o estudios de evaluación del riesgo - Municipalidades con al menos un informe o estudio de evaluación de riesgo
		
		foreach x of numlist 1/5{
		replace p93_`x'=0 if p93_`x'==2
		}
		
		egen estudios_grd=rowtotal(p93_1-p93_5)
		replace estudios_grd=1 if estudios_grd>0

*******************************************************************************/
*	2. Tablas de salida
	
	*General
	table tipomuni , c(sum sismos sum incendios sum huaycos_deslizam sum bajas_temp sum lluvia_inund) row
	
	*Sismos
	table tipomuni if sismos==1, c(mean instrumentos_grd mean area_def_civil mean coel mean almacen_local mean personal_grd) 
	table tipomuni if sismos==1, c(mean pip_pp068 mean estudios_grd)

	*Incendios
	table tipomuni if incendios==1, c(mean instrumentos_grd mean area_def_civil mean coel mean almacen_local mean personal_grd) 
	table tipomuni if incendios==1, c(mean pip_pp068 mean estudios_grd)	
	
	*Huaycos y deslizamientos
	table tipomuni if huaycos_deslizam==1, c(mean instrumentos_grd mean area_def_civil mean coel mean almacen_local mean personal_grd) 
	table tipomuni if huaycos_deslizam==1, c(mean pip_pp068 mean estudios_grd)

	*Bajas temperaturas
	table tipomuni if bajas_temp==1, c(mean instrumentos_grd mean area_def_civil mean coel mean almacen_local mean personal_grd) 
	table tipomuni if bajas_temp==1, c(mean pip_pp068 mean estudios_grd)

	*Lluvias intensas e inundaciones
	table tipomuni if lluvia_inund==1, c(mean instrumentos_grd mean area_def_civil mean coel mean almacen_local mean personal_grd) 
	table tipomuni if lluvia_inund==1, c(mean pip_pp068 mean estudios_grd)	