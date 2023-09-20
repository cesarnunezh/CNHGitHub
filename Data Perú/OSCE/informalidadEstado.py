"""
@author: César Núñez
"""

# Importamos las librerías que utilizaremos
import pandas as pd
import os
import numpy as np
import requests
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.chrome.options import Options
import time
from selenium.webdriver.common.by import By
import shutil
import matplotlib.pyplot as plt


'''
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
time.sleep(120)

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
        os.remove(file)
        contador_1+=1
    else:
        df_alterna = pd.read_excel(file, skiprows=1)
        servicios = df_alterna['TIPOORDEN'] == 'Orden de Servicio'
        df_alterna = df_alterna[servicios]
        df = pd.concat([df, df_alterna])
        os.remove(file)
        contador_1+=1

# Guardamos la base de datos
df.to_csv('df_servicios_2018_2023.csv')
'''

# Abrimos la base de datos y nos quedamos con las variables que necesitamos
# Seteamos el directorio de trabajo
os.chdir("D:/1. Documentos/0. Bases de datos/10. OSCE")
dir_results = "D:/1. Documentos/0. Bases de datos/10. OSCE/2. Resultados"

df = pd.read_csv('df_servicios_2018_2023.csv')
df = df.loc[ : , ['ENTIDAD', 'RUC_ENTIDAD', 'FECHA_REGISTRO', 'FECHA_DE_EMISION', 'MONTO_TOTAL_ORDEN_ORIGINAL', 'DEPARTAMENTO__ENTIDAD', 'RUC_CONTRATISTA', 'NOMBRE_RAZON_CONTRATISTA']]

# identificamos los ruc 10 (personas naturales)
df['RUC_10'] = df['RUC_CONTRATISTA'].astype(str).apply(lambda x: x[0:2])
ruc_10 = df['RUC_10'] == "10"
df = df[ruc_10]

df['anio_emi'] = df['FECHA_DE_EMISION'].astype(str).apply(lambda x: x[0:4])
df['mes_emi'] = df['FECHA_DE_EMISION'].astype(str).apply(lambda x: x[5:7])

# Número de órdenes de servicio anuales por entidad
tabla_1 = df.groupby( ['RUC_ENTIDAD' , 'anio_emi' ] )[['RUC_CONTRATISTA']].count().rename(columns = {'RUC_CONTRATISTA' : "n_ordenes" }).reset_index()

# Número de órdenes de servicio anuales por proveedor en cada entidad
tabla_2 = df.groupby( ['RUC_ENTIDAD' , 'anio_emi' ] )[['RUC_CONTRATISTA']].value_counts().reset_index()
tabla_2.columns = ['RUC_ENTIDAD' , 'anio_emi','RUC_CONTRATISTA','n_orden_prom']

# Monto anual contratado por órdenes de servicio por entidad
tabla_3 = df.groupby( ['RUC_ENTIDAD' , 'anio_emi' ] )[['MONTO_TOTAL_ORDEN_ORIGINAL']].sum().rename(columns = {'MONTO_TOTAL_ORDEN_ORIGINAL' : "monto_total_entidad" }).reset_index()

# Monto anual contratado por órdenes de servicio por entidad y proveedor
tabla_4 = df.groupby( ['RUC_ENTIDAD' , 'anio_emi', 'RUC_CONTRATISTA' ])[['MONTO_TOTAL_ORDEN_ORIGINAL']].sum().rename(columns = {'MONTO_TOTAL_ORDEN_ORIGINAL' : "monto_total_contratista" }).reset_index()

# Monto mensual promedio contratado por órdenes de servicio por entidad y proveedor
tabla_5 = tabla_4
tabla_5["monto_promedio_contratista_mensual"] = tabla_5["monto_total_contratista"] / 12

tabla_5 = tabla_5[tabla_5['monto_promedio_contratista_mensual'] <= 41400]

# Gráfico N° 1: Distribución del monto promedio mensual en órdenes de servicio por contratista 2018-2022
    # Calculate the number of bins using the Freedman-Diaconis rule
    num_bins = int(round(len(tabla_5['monto_promedio_contratista_mensual']) ** 0.5))

    # Create the plot with journal paper format settings
    plt.figure(figsize=(8, 6))  # Adjust figure size to your preference
    plt.hist(tabla_5['monto_promedio_contratista_mensual'], bins=num_bins, color='skyblue', edgecolor='black')

    # Customize the plot
    plt.xlabel('Monto promedio mensual (en soles)', fontsize=12)  # Adjust font size
    plt.ylabel('Frequency', fontsize=12)  # Adjust font size
    plt.title('Distribución del monto promedio mensual en órdenes de servicio por contratista 2018-2022', fontsize=14)  # Adjust font size and title
    plt.grid(axis='y', linestyle='--', alpha=0.7)  # Add gridlines

    # Calculate summary statistics
    mean_value = tabla_5['monto_promedio_contratista_mensual'].mean()
    median_value = tabla_5['monto_promedio_contratista_mensual'].median()
    std_value = tabla_5['monto_promedio_contratista_mensual'].std()

    # Display summary statistics on the plot
    plt.text(0.7, 0.9, f"Mean: {mean_value:.2f}", transform=plt.gca().transAxes, fontsize=12)
    plt.text(0.7, 0.85, f"Median: {median_value:.2f}", transform=plt.gca().transAxes, fontsize=12)
    plt.text(0.7, 0.8, f"Std: {std_value:.2f}", transform=plt.gca().transAxes, fontsize=12)

    # Save the plot (optional)
    file_path = os.path.join(dir_results,'graph1.png')
    plt.savefig(file_path, dpi=300, bbox_inches='tight')  # Adjust filename and DPI

    # Display the plot
    plt.show()

# Gráfico N° 2: Distribución del número de órdenes de servicio promedio anual por contratista 2018-2022
    tabla_2 = tabla_2[tabla_2['n_orden_prom'] <= 12]
    # Calculate the number of bins using the square root rule
    num_bins = int(round(len(tabla_2['n_orden_prom']) ** 0.5))

    # Create the plot with journal paper format settings
    plt.figure(figsize=(8, 6))  # Adjust figure size to your preference
    plt.hist(tabla_2['n_orden_prom'], bins=num_bins, color='skyblue', edgecolor='black')

    # Customize the plot
    plt.xlabel('Número de órdenes promedio anual por contratista', fontsize=12)  # Adjust font size
    plt.ylabel('Frequency', fontsize=12)  # Adjust font size
    plt.title('Distribución del número de órdenes promedio anual por contratista 2018-2022', fontsize=14)  # Adjust font size and title
    plt.grid(axis='y', linestyle='--', alpha=0.7)  # Add gridlines

    # Calculate summary statistics
    mean_value = tabla_2['n_orden_prom'].mean()
    median_value = tabla_2['n_orden_prom'].median()
    std_value = tabla_2['n_orden_prom'].std()

    # Display summary statistics on the plot
    plt.text(0.7, 0.9, f"Mean: {mean_value:.2f}", transform=plt.gca().transAxes, fontsize=12)
    plt.text(0.7, 0.85, f"Median: {median_value:.2f}", transform=plt.gca().transAxes, fontsize=12)
    plt.text(0.7, 0.8, f"Std: {std_value:.2f}", transform=plt.gca().transAxes, fontsize=12)

    # Save the plot (optional)
    file_path = os.path.join(dir_results,'graph2.png')
    plt.savefig(file_path, dpi=300, bbox_inches='tight')  # Adjust filename and DPI

    # Display the plot
    plt.show()
