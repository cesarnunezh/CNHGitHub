use enaho01a-2015-500.dta, clear

**El INEI establece que la información de estas bases de datos requiere restringir los cálculos a los residentes
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
**Residentes: miembro del hogar y que no se encuentre ausente del mismo en los últimos 30 días o que no sea miembro del hogar pero se encuentre presente en los últimos 30 días
label variable residente "Persona es residente del hogar"
**A continuación, limpiamos las variables de las fuentes de ingresos
recode i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t (.=0)
**Con las variables limpias, obtenemos el ingreso anual total proveniente del trabajo. Luego lo hacemos mensual e incluimos las etiquetas a las nuevas variables:
egen ingtrabw = rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
gen ingtram=ingtrabw/(12)
label var ingtrabw "Ingreso por trabajo anual"
label var ingtram "Ingreso por trabajo mensual"

destring ubigeo, replace
***Obtenemos los dos primeros dígitos
***Con el comando int Stata solo considera a los números enteros
gen region = int(ubigeo/10000)
***Incluimos los labels a region
label variable region "Región"
label define region 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values region region
tab region

**Finalmente, calculamos el ingreso promedio mensual proveniente del trabajo según región
***En el cálculo se incluye las siguientes retricciones: (i) residente, (ii) persona ocupada y
***(iii) ingresos positivos y menores de S/. 25 mil para evitar el sesgo de valores extremos
table region p207 if residente==1 & ocu500==1 & (ingtram>0 & ingtram<=25000) [iw=fac500a], c(mean ingtram) row
