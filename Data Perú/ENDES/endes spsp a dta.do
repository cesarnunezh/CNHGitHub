global basex "G:\.shortcut-targets-by-id\1VhdDfr_V-4EYboWH5jjzQiztN2L_fPSJ\Documents\0. Bases de datos\3. ENDES\zips"


import spss using "$basex\RECH23.sav", case(lower) clear
save "$basex\rech23_2018.dta"

import spss using "$basex\RECH6.sav", case(lower) clear
save "$basex\rech6_2018.dta"

import spss using "$basex\RECH5.sav", case(lower) clear
save "$basex\rech5_2018.dta"

import spss using "$basex\RECH4.sav", case(lower) clear
save "$basex\rech4_2018.dta"

import spss using "$basex\RECH1.sav", case(lower) clear
save "$basex\rech1_2018.dta"

import spss using "$basex\RECH0.sav", case(lower) clear
save "$basex\rech0_2018.dta"

import spss using "$basex\REC0111.sav", case(lower) clear
save "$basex\rec0111_2018.dta"

import spss using "$basex\REC95.sav", case(lower) clear
save "$basex\rec95_2018.dta"

import spss using "$basex\REC94.sav", case(lower) clear
save "$basex\rec94_2018.dta"

import spss using "$basex\REC93DV disciplina.sav", case(lower) clear
save "$basex\rec93dvdisciplina_2018.dta"

import spss using "$basex\REC91.sav", case(lower) clear
save "$basex\rec91_2018.dta"

import spss using "$basex\REC84DV.sav", case(lower) clear
save "$basex\rec84dv_2018.dta"

import spss using "$basex\REC83.sav", case(lower) clear
save "$basex\rec83_2018.dta"

import spss using "$basex\REC82.sav", case(lower) clear
save "$basex\rec82_2018.dta"

import spss using "$basex\REC44.sav", case(lower) clear
save "$basex\rec44_2018.dta"

import spss using "$basex\REC43.sav", case(lower) clear
save "$basex\rec43_2018.dta"

import spss using "$basex\REC42.sav", case(lower) clear
save "$basex\rec42_2018.dta"

import spss using "$basex\REC41.sav", case(lower) clear
save "$basex\rec41_2018.dta"

import spss using "$basex\REC21.sav", case(lower) clear
save "$basex\rec21_2018.dta"

import spss using "$basex\RE758081.sav", case(lower) clear
save "$basex\re758081_2018.dta"

import spss using "$basex\RE516171.sav", case(lower) clear
save "$basex\re516171_2018.dta"

import spss using "$basex\RE223132.sav", case(lower) clear
save "$basex\re223132_2018.dta"
