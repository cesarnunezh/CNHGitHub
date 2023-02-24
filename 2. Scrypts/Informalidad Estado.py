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
import shutil

# Definimos algunas opciones para abrir la página
driver = webdriver.Chrome(ChromeDriverManager().install())
driver.maximize_window()

# Abrimos la página
driver.get("https://bi.seace.gob.pe/pentaho/api/repos/%3Apublic%3Aportal%3Adatosabiertoscontratacionesdirectas.html/content?userid=public&password=key#")
# generamos un bucle para descargar todas las bases
contador = 0
for trianio in range(1,3):
    for anio in range(1,4):
        for trim in range(1,5):
            for mes in range(1,4):
                try:
                    locals()[f'{trianio}_{anio}_{trim}_{mes}'] = driver.find_element( By.XPATH, f"/html/body/main/section[1]/div[{trianio}]/div/div[{anio}]/div/div[{trim}]/a[{mes}]/button")
                    print(f'{trianio}_{anio}_{trim}_{mes}')

                    locals()[f'{trianio}_{anio}_{trim}_{mes}'].click()
                    time.sleep(5)
                    contador+=1
                except:
                    continue

# Movemos los archivos descargados a la carpeta de trabajo
time.sleep(60)

# Seteamos la carpeta donde originalmente se descargaron los archivos
folder_path = "C:/Users/canun/Downloads"

# Generamos una lista que permita identificar los archivos de la carpeta y las fechas de modificación
files_with_time = [(f, os.path.getmtime(os.path.join(folder_path, f))) for f in os.listdir(folder_path)]

# Ordenamos de tal forma que los primeros archivos de la lista sean los más recientes
sorted_files = sorted(files_with_time, key=lambda x: x[1], reverse=True)

# Generamos una lista de solo los datos descargados
locals()[f'last_{contador}_files'] = [f[0] for f in sorted_files[:contador]]

# Movemos los archivos descargados a la carpeta de trabajo
for file in locals()[f'last_{contador}_files']:

    # Path of the file to be moved
    src_file = "C:/Users/canun/Downloads/" + file

    # Destination path where the file should be moved
    dst_folder = "D:/1. Documentos/0. Bases de datos/10. OSCE"

    # Move the file from the source path to the destination path
    shutil.move(src_file, dst_folder)

# Extraemos las bases de datos de todos los archivos descargados
# Generamos un código para generar la lista de archivos

folder_path = "D:/1. Documentos/0. Bases de datos/10. OSCE"

# Generamos una lista que permita identificar los archivos de la carpeta y las fechas de modificación
files_list = os.listdir(folder_path)


# Seteamos el directorio de trabajo
os.chdir("D:/1. Documentos/0. Bases de datos/10. OSCE")
contador_1=0

#for file in locals()[f'last_{contador}_files']:
for file in files_list:
    if contador_1==0 :
        df = pd.read_excel(file, skiprows=1)
        servicios = df['TIPOORDEN'] == 'Orden de Servicio'
        df = df[servicios]
        contador_1+=1
    else:
        df_alterna = pd.read_excel(file, skiprows=1)
        servicios = df_alterna['TIPOORDEN'] == 'Orden de Servicio'
        df_alterna = df_alterna[servicios]
        df = pd.concat([df, df_alterna])
        contador_1+=1