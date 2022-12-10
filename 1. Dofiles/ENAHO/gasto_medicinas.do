******** SALUD

clear
set more off
cd "D:\Backup_SPAZ\CPC 2019 (carpeta ordenada)\2. Factores (mesas CPC)\8. Salud\Data\Enaho"
use panel_salud.dta

* Tiene seguro

gen seguro=0
for num 1/8: replace seguro=1 if p419X==1 

* Tipo de seguro

g tipo_seguro = 0
for num 1/8: replace tipo_seguro = X if p419X==1

replace tipo_seguro=. if p4191==.

replace tipo_seguro = 2 if tipo_seguro == 3 
replace tipo_seguro = 3 if tipo_seguro == 5
replace tipo_seguro = 4 if tipo_seguro == 6 | tipo_seguro == 7  | tipo_seguro == 8


la def tipo_seguro 1 "EsSalud" 2 "Privado" 3 "SIS" 4 "Otro"


la val tipo_seguro tipo_seguro
la var tipo_seguro "Tipo de seguro"


** Medicinas i41602

egen medicinas_hog = sum (i41802), by (year conglome vivienda hogar)

collapse (count) n_obs=i41802 N_obs= medicinas_hog (mean) medicinas_hog (sum) i41802 [iw=factor07], by(year tipo_seguro)
gen promedio = i41802/N_obs

collapse (count) n_obs=i41602 N_obs= medicinas_hog (mean) medicinas_hog (sum) i41602 [iw=factor07], by(year tipo_seguro)

