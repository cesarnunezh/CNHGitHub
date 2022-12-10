clear all
cd "C:\Users\fonte\Documents\UNICEF\ETI"
use "eti_2015_ninos_5_a_17anios"



*Porcentaje de adolescentes dentro de la edad permitida que realizan trabajos peligrosos por sector de actividad y edad

preserve
drop if qc_edad < 14 /*nos quedamos con los adolescentes que se encuentran en la edad permitida para trabajar*/
mean ind5 
table region, contents (mean ind5) /*region*/
table qhdepartamento, contents (mean ind5) /*departamento*/
table area, contents (mean ind5) /*dominio de residencia*/
*mean ind5, over(qd406_cod)
/*qd406_cod esta variable es el codigo de actividad economica*/
restore

*Porcentaje de niñas, niños y adolescentes que trabajan por debajo de la edad mínima (6-11 años) 

gen edad = 1 if qc_edad > 5 & qc_edad < 14

preserve
drop if edad ==.
gen trabaja = 1 if qc401 == 1
replace trabaja = 0 if trabaja ==.

replace trabaja = 0 if trabaja ==.
mean trabaja

table area, contents (mean trabaja) /*dominio de residencia*/
table region, contents (mean trabaja) /*region*/
table qhdepartamento, contents (mean trabaja) /*departamento*/
mean trabaja, over(qc_sexo) /*sexo*/
restore

*Actividades realizadas por los niños y niñas de 6 a 11 años por área de residencia y sexo

*Area de residencia
table area, contents (mean qc110_1)
table area, contents (mean qc110_2)
table area, contents (mean qc110_3)
table area, contents (mean qc110_4)
table area, contents (mean qc110_5)
table area, contents (mean qc110_6)
table area, contents (mean qc110_7)
table area, contents (mean qc110_8)
table area, contents (mean qc110_9)
table area, contents (mean qc110_10)
table area, contents (mean qc110_11)

*Sexo
table qc_sexo, contents (mean qc110_1)
table qc_sexo, contents (mean qc110_2)
table qc_sexo, contents (mean qc110_3)
table qc_sexo, contents (mean qc110_4)
table qc_sexo, contents (mean qc110_5)
table qc_sexo, contents (mean qc110_6)
table qc_sexo, contents (mean qc110_7)
table qc_sexo, contents (mean qc110_8)
table qc_sexo, contents (mean qc110_9)
table qc_sexo, contents (mean qc110_10)
table qc_sexo, contents (mean qc110_11)

*Intensidad de la jornada laboral de los niños y niñas de 6 a 11 años por área de residencia y sexo
preserve
drop if edad ==.
gen intenso = 1 if qd411_5 == 1
replace intenso = 0 if intenso ==.

table area, contents (mean intenso) /*dominio de residencia*/
table qhdepartamento, contents (mean intenso) /*departamento*/
mean intenso, over(qc_sexo) /*sexo*/
restore






