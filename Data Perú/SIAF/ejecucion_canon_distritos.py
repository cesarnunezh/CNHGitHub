# -*- coding: utf-8 -*-
"""
Created on Wed Sep 29 12:55:01 2021

@author: canun
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
for k in range(2021, 2022):
    print(str(k))
    b.get("https://apps5.mineco.gob.pe/transparencia/Navegador/default.aspx?y=" + str(k) + "&ap=ActProy")


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
        
    recurso = b.find_element_by_name("ctl00$CPH1$BtnTipoRecurso")
    recurso.click()
    time.sleep(1.5)
    
    #Canon minero es 2018 --> | 2019-->8 | 2020-->  | 2021-->8
    #Regalias mineras es 2018-->15 | 2019 -->17 | 2020-->16 | 2021-->17
    canon_minero = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[17]")
    canon_minero.click()
    time.sleep(1.5)
    
#    funcion = b.find_element_by_name("ctl00$CPH1$BtnFuncion")
#   funcion.click()
#    time.sleep(1.5)
    
    #Para el periodo 2018-2021, salud es 16, educación es 18, transporte es 11, saneamiento es 14, planeamiento es 1
    # agropecuaria es 7 (2020 es 6), cultura y deporte es 17 y deuda publica es 21
#    funcion2 = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[17]")
#    funcion2.click()
#    time.sleep(1.5)       
    
    mes = b.find_element_by_name("ctl00$CPH1$BtnMes")
    mes.click()
    time.sleep(1.5)    
            
    meses = b.find_elements_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr")
        
    count = 1
    for PL1 in meses:
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
        
        nivel_gobierno = b.find_element_by_name("ctl00$CPH1$BtnTipoGobierno")
        nivel_gobierno.click() 
        time.sleep(1.5)                                   
    
        gobierno_local = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[2]")
        gobierno_local.click()
        time.sleep(1.5)
    
        golo = b.find_element_by_name("ctl00$CPH1$BtnSubTipoGobierno")
        golo.click() 
        time.sleep(1.5)                                   
    
        muni = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[1]")
        muni.click()
        time.sleep(1.5)
    
        departamento = b.find_element_by_name("ctl00$CPH1$BtnDepartamento")
        departamento.click() 
        time.sleep(1.5)   
        
        dptos = b.find_elements_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr")

        count2 = 1
        for PL1 in dptos:
            PL1.click()
            print (count2)
            count2 = count2 + 1

        for l in range(1, count2):
            PL = b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[" + str(l) + "]")
            PL2 = ''.join([i for i in PL.text if not i.isdigit()]) # join permite unir, en este caso con ´´.  Luego une todas las letras que no sean dígitos
            PL2 = re.sub('[-:,.]', '', PL2) ##"re.sub permite sustituir. En este caso los signos por espacios en blanco
            print(PL2.strip()) # strips saca los espacios en blanco
            PL.click()         
        
            munis = b.find_element_by_name("ctl00$CPH1$BtnMunicipalidad")
            munis.click() 
            time.sleep(1.5)   

            descargar = b.find_element_by_xpath("/html/body/form/div[4]/div[2]/table/tbody/tr/td[1]/a[2]")
            descargar.click()
            time.sleep(2)
    
            volver_dptos= b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[2]/table/tbody/tr[7]/td[1]")
            volver_dptos.click()
            
        volver_meses= b.find_element_by_xpath("/html/body/form/div[4]/div[3]/div[2]/table/tbody/tr[4]/td[1]")
        volver_meses.click()
