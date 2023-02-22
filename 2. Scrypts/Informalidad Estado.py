"""
@author: César Núñez
"""

# Importamos las librerías que utilizaremos
import pandas as pd
import numpy as np
import requests
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
import os
from selenium.webdriver.chrome.options import Options
import time
from selenium.webdriver.common.by import By

# Seteamos el directorio de trabajo
os.chdir('D:/1. Documentos/0. Bases de datos/10. OSCE')

# Instalamos el ChromeDriver Manager

driver = webdriver.Chrome( ChromeDriverManager().install() )
driver.maximize_window()

# Definimos algunas opciones para abrir la página
options = webdriver.ChromeOptions()
download_dir = 'D:/1. Documentos/0. Bases de datos/10. OSCE'
prefs = {"download.default_directory": download_dir}
options.add_experimental_option("prefs", prefs)
driver = webdriver.Chrome(ChromeDriverManager().install(),options=options)
driver.maximize_window()



# Abrimos la página
driver.get("https://bi.seace.gob.pe/pentaho/api/repos/%3Apublic%3Aportal%3Adatosabiertoscontratacionesdirectas.html/content?userid=public&password=key#")

# generamos un bucle para descargar todas las bases
for trianio in range(1,3):
    for anio in range(1,4):
        for trim in range(1,5):
            for mes in range(1,3):
                try:
                    locals()[f'{trianio}_{anio}_{trim}_{mes}'] = driver.find_element( By.XPATH, f"/html/body/main/section[1]/div[{trianio}]/div/div[{anio}]/div/div[{trim}]/a[{mes}]/button")
                    print(f'{trianio}_{anio}_{trim}_{mes}')

                    locals()[f'{trianio}_{anio}_{trim}_{mes}'].click()

                except:
                    continue
