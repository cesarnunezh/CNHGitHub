cd "G:\Mi unidad\CPC 2019 (carpeta ordenada)\4. Bibliografía y data\ENAPRES"

rename (p172 p173 p175a) (recojo frec_recojo hogar_separa)

table regionnatu recojo [iw=factor], format(%12.0fc)
table frec_recojo [iw=factor], format(%12.0fc) row
table hogar_separa [iw=factor], format(%12.0fc) row

tab p175e_1 [iw=factor]
tab p175e_2 [iw=factor]
tab p175e_3 [iw=factor]
tab p175e_4 [iw=factor]
tab p175e_5 [iw=factor]
tab p175e_6 [iw=factor]
tab p175e_7 [iw=factor]

tab p175e_1 [iw=factor] if p175e_2!=1 & p175e_3!=1 & p175e_4!=1 & p175e_5!=1 & p175e_6!=1 & p175e_7!=1  
