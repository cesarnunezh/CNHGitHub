global bd "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\03. ENDES\1. Data"

global temp "C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\03. ENDES\2. Temp"

global data15_22 "rec42 rec41 rec21 re758081 re516171 re223132"

global data19_22 "rechm dit" 
*No hay 2020 rec44_ rech5_
*No hay 2018 rec93dvdisciplina_
*No hay 2015 rec0111_

cd "$bd"
foreach mod in $data15_22 {
	foreach x of numlist 2015/2022 {
		append using "`mod'_`x'"
	}
	save "$temp/`mod'", replace
}
