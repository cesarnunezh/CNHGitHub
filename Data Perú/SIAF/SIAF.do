********************************************************************************
******************************INGRESOS Y RECAUDACIÓN****************************
********************************************************************************

global bd "D:\1. Documentos\0. Bases de datos\1. SIAF - MEF\1. Data"
global out "G:\Mi unidad\1. Proyectos\8. Propuestas Bicentenerio\Etapa 2 - PDB\Extractivas"

foreach x of numlist 2014/2021 {
import delimited "$bd/`x'-Ingreso.csv", clear

drop if mes==.

gen canon=1 if tipo_recurso_nombre=="SUB CUENTA - CANON MINERO" | tipo_recurso_nombre=="CANON MINERO" | tipo_recurso_nombre=="REGALIAS MINERAS" | tipo_recurso_nombre=="SUB CUENTA- CANON Y SOBRECANON-IMPUESTO  A LA RENTA"
gen imp_municipales=1 if tipo_recurso_nombre=="SUB CUENTA - IMPUESTOS MUNICIPALES"

encode tipo_gobierno_nombre ,gen(nivel_gobierno)

keep if nivel_gobierno==2 | nivel_gobierno==3


collapse (sum) monto_recaudado if canon==1, by(departamento_ejecutora departamento_ejecutora_nombre)
rename (monto_recaudado) (_`x')

tempfile file_`x'
save `file_`x''

}

use "`file_2014'", clear

foreach x of numlist 2015/2021 {
merge 1:1 departamento_ejecutora departamento_ejecutora_nombre using "`file_`x''"
drop _m
}
save "$bd/ingresos_canon.dta", replace

export excel using "$out\canon.xls",  firstrow(variables) sheet("ingresos", replace)

********************************************************************************
********************************GASTO Y PRESUPUESTO*****************************
********************************************************************************
global bd "D:\1. Documentos\0. Bases de datos\1. SIAF - MEF\1. Data"

foreach x of numlist 2018/2020 {

import delimited "$bd/`x'-Gasto.csv", clear

drop if mes==.
gen canon=1 if tipo_recurso_nombre=="SUB CUENTA - CANON MINERO" | tipo_recurso_nombre=="CANON MINERO" | tipo_recurso_nombre=="REGALIAS MINERAS" | tipo_recurso_nombre=="SUB CUENTA- CANON Y SOBRECANON-IMPUESTO  A LA RENTA"
gen imp_municipales=1 if tipo_recurso_nombre=="SUB CUENTA - IMPUESTOS MUNICIPALES"

encode tipo_gobierno_nombre ,gen(nivel_gobierno)

keep if nivel_gobierno==2 | nivel_gobierno==3
keep if canon==1
collapse (sum) monto_pim monto_devengado , by(departamento_ejecutora departamento_ejecutora_nombre)
rename (monto_devengado) (monto_devengado_`x')

save "$out\canon_`x'.dta", replace
}

use "`file_2019'", clear

foreach x of numlist 2015/2021 {
merge 1:1 departamento_ejecutora departamento_ejecutora_nombre using "`file_`x''"
drop _m
}

save "$bd/gasto_canon.dta", replace

export excel using "$out\canon.xls",  firstrow(variables) sheet("gastos", replace)
