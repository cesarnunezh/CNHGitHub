
//////////////////////
/////////////////
//////////                 CONSUMO EXCESIVO ENDES

*Creaci󮠤e la base
set more off

use "C:\Users\USUARIO\Documents\Backus\ENDES\2013 csalud01.dta", clear

forvalues anho = 2014/2018{
append using "C:\Users\USUARIO\Documents\Backus\ENDES/`anho' csalud01.dta", force
}
drop if qsinty==.
save "C:\Users\USUARIO\Documents\Backus\ENDES\endes_appended.dta", replace

***********
* 1. Rutas
***********

	global bd1 "C:\Users\USUARIO\Documents\Bases de datos\Endes\2018"
	global out1 "C:\Users\USUARIO\Dropbox\Videnza\03. Proyectos\08. Backus\04. Resultados\01. An⭩sis"
	
	use "$bd1/rec0111_modulo66", clear
	keep hhid v005 awfactu awfactt awfactr awfacte awfacte awfactw v191 v190 v025 v130 v131 v121 v122 v129 v136 v161
	duplicates drop hhid, force
	merge 1:1 hhid using "$bd1/csalud01_modulo414",

	*Numerador
	gen cerveza = (qs212ab*3.1) + qs212av
	gen vino = (qs212bb*7.5) + qs212bv
	gen chicha = (qs212cb*3) + qs212cv
	gen masato = (qs212db*3) + qs212dv
	gen yonque = (qs212eb*12) + qs212ev
	gen anisado = (qs212fb*15) + qs212fv
	gen destilados = (qs212gb*15) + qs212gv
	gen otra = (qs212xb*7.5) + qs212xv

	egen vasos=rowtotal(cerveza vino chicha masato yonque anisado destilados otra)
	
	* Consumo excesivo
	gen consumo_excesivo1=(qssexo==1 & vasos >=5 | qssexo==2 & vasos >=4)

	* Peso
	rename 	peso15_amas peso
	replace peso=peso/1000
	rename 	qhcluster conglome

	* Consumo excesivo por quintil
	table v190 [iw=peso], c(mean consumo_excesivo1)
	table v190 [iw=peso], c(n consumo_excesivo1) format(%18.0g)
	table v190 [iw=peso], c(sum vasos)
	table v190 [iw=peso], c(sum cerveza) format(%18.0g)
	
	* Exportar 
	gen tot_poblacion = 1 
	gen tot_alcohol = 1 if vasos >0 
	gen tot_cerveza = 1 if cerveza !=.
	gen consumo_excesivo_cer = (consumo_excesivo1==1 & cerveza!=.)
	collapse (sum) tot_poblacion tot_alcohol tot_cerveza vasos cerveza (mean) consumo_excesivo1 consumo_excesivo_cer [iw=peso], by(v190)
	
	export excel using "$out1/endes2018.xls", sheet("Tomador") sheetmodify firstrow(variables)			
	
	
	svyset conglome [pw=peso]

	//////   PARA EL EXCEL

	matrix endes=J(7, 6, .)

	foreach anho of numlist 1/6{
	preserve
	keep if qsinty==`anho'+2012
	*F1: Llenar el a񯍊	matrix endes [1,`anho']=`anho'+2012

	*F2: Llenar el % de consumidores excesivos
	svy: mean consumo_excesivo1
	matrix consumo_excesivo_`anho'=r(table)
	matrix endes [2,`anho']=consumo_excesivo_`anho'[1,1]

	*F3: Llenar el # de vasos de alcohol tomados. Ojo: 2012 tiene menos meses
	svy: total vasos
	matrix vasos_`anho'=r(table)
	matrix endes [3,`anho']=vasos_`anho'[1,1]

	*F4: Llenar el # de vasos de cerveza tomados. Ojo: 2012 tiene menos meses
	svy: total cerveza
	matrix cerveza_`anho'=r(table)
	matrix endes [4,`anho']=cerveza_`anho'[1,1]

	*F5: Llenar el # de vasos de vino tomados. Ojo: 2012 tiene menos meses
	svy: total vino
	matrix vino_`anho'=r(table)
	matrix endes [5,`anho']=vino_`anho'[1,1]

	*F6: Llenar el # de vasos de destilados tomados. Ojo: 2012 tiene menos meses
	svy: total destilados
	matrix destilados_`anho'=r(table)
	matrix endes [6,`anho']=destilados_`anho'[1,1]

	*F7: Llenar el # de vasos de otros tomados. Ojo: 2012 tiene menos meses
	egen otros=rowtotal(chicha masato yonque anisado otra)
	svy: total otros
	matrix otros_`anho'=r(table)
	matrix endes [7,`anho']=otros_`anho'[1,1]

	restore
	}

	putexcel B1=matrix(endes) using "$outcomes\Alcohol_SuSalud.xls", sheet("Endes_Excesivo") modify

	gen tomador=(vasos>0 & vasos!=.) 
	bys qsinty: tab tomador [iweight=peso]
	gen tomador_cerveza=(cerveza>0 & cerveza!=.)
	bys qsinty: tab tomador_cerveza [iweight=peso]
	gen tomador_vino=(vino>0 & vino!=.)
	bys qsinty: tab tomador_vino [iweight=peso]
	gen tomador_destilados=(destilados>0 & destilados!=.)
	bys qsinty: tab tomador_destilados [iweight=peso]
	gen tomador_otros=(otros>0 & otros!=.)
	bys qsinty: tab tomador_otros [iweight=peso]

	*Descomposici󮠤el consumo excesivo
	egen nocerveza=rowtotal(vino chicha masato yonque anisado destilados otra)
	gen solocerveza=(cerveza>0 & nocerveza==0)
	gen cervezayotros=(cerveza>0 & nocerveza>0)
	gen todomenoscerveza=(cerveza==0 & nocerveza>0)

	tab consumo_excesivo1 solocerveza [iweight=peso] if qsinty==2013
	tab consumo_excesivo1 cervezayotros [iweight=peso] if qsinty==2013
	tab consumo_excesivo1 todomenoscerveza [iweight=peso] if qsinty==2013

	tab consumo_excesivo1 solocerveza [iweight=peso] if qsinty==2017
	tab consumo_excesivo1 cervezayotros [iweight=peso] if qsinty==2017
	tab consumo_excesivo1 todomenoscerveza [iweight=peso] if qsinty==2017
