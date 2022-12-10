******** SALUD

clear
set more off
cd "D:\Backup_SPAZ\CPC 2019 (carpeta ordenada)\2. Factores (mesas CPC)\8. Salud\Data\Enaho"
use enaho01a-2018-400, clear

merge n:1 conglome vivienda hogar using sumaria-2018

*Filtro
gen filtro=0
replace filtro=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 


* Razones para no atenderse
tab p4091 sin_seguro [iw=factor07]


** Seguro

gen cuenta = p4191 + p4192 + p4193 + p4194 + p4195 + p4196 + p4197 + p4198
gen seguro_unico = (cuenta == 15)
gen sin_seguro = (cuenta == 16)
gen mas_un_seguro =(cuenta<15)

tab sin_seguro [iw=factor07] if filtro == 1
tab mas_un_seguro [iw=factor07] if filtro == 1

tab p4191 seguro_unico [iw=factor07] if filtro == 1
tab p4192 seguro_unico [iw=factor07] if filtro == 1
tab p4193 seguro_unico [iw=factor07] if filtro == 1
tab p4194 seguro_unico [iw=factor07] if filtro == 1
tab p4195 seguro_unico [iw=factor07] if filtro == 1
tab p4196 seguro_unico [iw=factor07] if filtro == 1
tab p4197 seguro_unico [iw=factor07] if filtro == 1
tab p4198 seguro_unico [iw=factor07] if filtro == 1

tab p4199 [iw=factor07] if filtro == 1


merge m:1 conglome vivienda hogar using sumaria-2018

* Discapacidad por edad por pobreza (p401h)
rename p208a edad
gen grupo_edad = 1 if edad <=5
replace grupo_edad = 2 if edad >5 & edad <=15
replace grupo_edad = 3 if edad >15 & edad <=64
replace grupo_edad = 4 if edad >64


gen sit_pobre = (pobreza == 1 | pobreza == 2)

* Edad
table grupo_edad p401h1 sit_pobre [iw=factor07]
table grupo_edad p401h2 sit_pobre [iw=factor07]
table grupo_edad p401h3 sit_pobre [iw=factor07]
table grupo_edad p401h4 sit_pobre [iw=factor07]
table grupo_edad p401h5 sit_pobre [iw=factor07]
table grupo_edad p401h6 sit_pobre [iw=factor07]



*** X% tiene acceso a seguro de salud. En particular, X mi