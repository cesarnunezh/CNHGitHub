# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
"""
@author: Mauricio y Dana
"""
#El proposito de este programa es lograr una descarga sistematizada de los datos del SIAF segun sean necesarios
#1. Se instala anaconda para poder correr el programa
#conda install -c conda-forge selenium

#se instala chrome driver para poder hacer trabajar con el HTML

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
import time
import os
import sys
import re

chromedriver = 'C:/Users/canun/Documents/Python Scripts/chromedriver.exe'
b = webdriver.Chrome(chromedriver)

#OJO: Verificar tener la última versión de google chrome, y que chromedriver esté instalado en la misma 
#carpeta de Python Scripts a la que le estamos haciendo referencia

################################################ DESCARGAS ################################################

#Comienza el loop para descargar la información de distintas ejecutoras
#En Python no es necesario cerrar el loop, solo trabajar en niveles
#Las acciones que reaaliza el Loop deben tener un tab a la derecha


##### Este es el loop si se quiere extraer para varios años. Se pone el año de inicio y fin de interés. 
###### Si se va a utilizar no olvidar poner un tab en todas las líneas de códigos siguientes ###        
for k in range(2010, 2021):
    print(str(k))
    b.get("https://apps5.mineco.gob.pe/transparencia/mensual/default.aspx?y=" + str(k) + "&ap=ActProy")


    #b.get("http://apps5.mineco.gob.pe/transparencia/Navegador/default.aspx")
    frame = b.find_element_by_xpath('//*[@id="frame0"]')
    b.switch_to.frame(frame)
        
    #Toda esta parte es para nacional
    
    rubro = b.find_element_by_name("ctl00$CPH1$BtnRubro")
    rubro.click()
    time.sleep(1.5)
        
    canon_sobrecanon = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[7]/td[2]")
    canon_sobrecanon.click()
    time.sleep(1.5)
        
    nivel_gobierno = b.find_element_by_name("ctl00$CPH1$BtnTipoGobierno")
    nivel_gobierno.click() 
    time.sleep(1.5)   
        
    nivel_gob = b.find_elements_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr")
        
    count = 1
    for PL1 in nivel_gob:
        PL1.click()
        print (count)
        count = count + 1
    #La parte de texto es solo para saber cuales unidades se estan siendo descargadas
    for l in range(1, count):
        PL = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[" + str(l) + "]")
        PL2 = ''.join([i for i in PL.text if not i.isdigit()]) # join permite unir, en este caso con ´´.  Luego une todas las letras que no sean dígitos
        PL2 = re.sub('[-:,.]', '', PL2) ##"re.sub permite sustituir. En este caso los signos por espacios en blanco
        print(PL2.strip()) # strips saca los espacios en blanco
        PL.click()         
        
        departamento = b.find_element_by_name("ctl00$CPH1$BtnDepartamentoMeta")
        departamento.click() 
        time.sleep(1.5)   
        
        descargar = b.find_element_by_xpath("/html/body/form/div[4]/div[2]/table/tbody/tr/td[1]/a[2]")
        descargar.click()
        time.sleep(2)
    
        volver_nivel_gob = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[2]/table/tbody/tr[3]/td[1]")
        volver_nivel_gob.click()
        


#########################################
# Nivel regional
#########################################

# volver_nivel_gob = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[2]/table/tbody/tr[6]/td[1]")
# volver_nivel_gob.click()

# gobierno_regional = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[3]/td[1]")
# gobierno_regional.click()

# sector = b.find_element_by_name("ctl00$CPH1$BtnSector")
# sector.click()
# time.sleep(1.5)
    
# salud2 = b.find_element_by_xpath(".//td[contains(.,'99: GOBIERNOS REGIONALES')]")
# salud2.click()
   
# pliego = b.find_element_by_name("ctl00$CPH1$BtnPliego")
# pliego.click()
# time.sleep(1.5)
    
# pliegos = b.find_elements_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr")
    
# count = 1
# for PL1 in pliegos:
#     PL1.click()
#     print (count)
#     count = count + 1
# #La parte de texto es solo para saber cuales unidades se estan siendo descargadas
# for l in range(1, count):
#     UE = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[" + str(l) + "]")
#     UE2 = ''.join([i for i in UE.text if not i.isdigit()])
#     UE2 = re.sub('[-:,.]', '', UE2)
#     print(UE2.strip())
#     UE.click()         
    
#     ejecutora = b.find_element_by_name("ctl00$CPH1$BtnEjecutora")
#     ejecutora.click() 
#     time.sleep(1.5)                                   
            
#     descargar = b.find_element_by_xpath("/html/body/form/div[4]/div[2]/table/tbody/tr/td[1]/a[2]")
#     descargar.click()
#     time.sleep(2)
                        
#     volver_pliegos = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[2]/table/tbody/tr[8]/td[1]")
#     volver_pliegos.click()




