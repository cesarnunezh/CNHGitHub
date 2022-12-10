*Cálculo del gasto en alimentos según situación de pobreza urbana

global inputs "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\4. Bibliografía y data\Bases de datos compartidas\ENAHO\Enaho anual\inputs\2018"
global temp "G:\Mi unidad\CPC\CPC 2020 (carpeta ordenada)\4. Bibliografía y data\Bases de datos compartidas\ENAHO\Enaho anual\temp"


use "$inputs\enaho01-2018-603.dta", clear

collapse (sum) i603b , by(conglome vivienda hogar factor07)
save "$temp\mantenimiento_vivienda.dta", replace

use "$inputs\sumaria-2018.dta", clear
merge 1:1 conglome vivienda hogar using "$temp\mantenimiento_vivienda.dta" 

gen pobre=(pobreza==2)
gen pobre_ext=(pobreza==1)

replace pobre=pobre*100
replace pobre_ext=pobre_ext*100

gen gmens_alim=gru11hd/12 // gasto en alimentos
gen gmens_salud=gru51hd/12 // gasto en cuidado, conservación de la salud y servicios médicos.
gen gas_mens_alim_salud=gmens_alim+gmens_salud // gasto salud + alimentos
gen g_mensual=gashog1d/12 // gasto total monetario
gen g_mant=i603b/12 // gasto imputado, deflactado y anualizado
gen mantenimiento=gru41hd/12
gen transporte=gru61hd/12

mean  gmens_alim gmens_salud g_mant transporte [iw=factor07] if estrato!=7 & estrato!=8 & pobreza==2
mean  mantenimiento g_mant transporte [iw=factor07] if estrato!=7 & estrato!=8 & pobreza==2

table pobreza [aw=factor07] if estrato!=7 & estrato!=8 , c(mean g_mensual semean g_mensual mean gas_mens_alim_salud semean gas_mens_alim_salud) format(%12.2fc)
