# -*- coding: utf-8 -*-
"""
Created on Thu Sep  2 12:24:27 2021

@author: canun
"""

import pandas as pd
import requests
import os


url = "https://www.tiobe.com/tiobe-index/"

html = requests.get(url).content
df_list = pd.read_html(html)

df = df_list[-1]
print(df)
df.to_csv("output.csv")



#Ruta de los archivos Excel
ruta_siaf = os.getcwd()+"/SIAF/"

os.listdir(ruta_siaf)

files = [f for f in os.listdir(ruta_siaf)]
#Si hay más archivos que los que queremos usar, podemos hacer filtros con el siguiente código.
#En lugar de TEXTO, debería incluirse el texto inicial con el que empiezan los archivos
#files = [f for f in os.listdir(ruta_siaf) if f.startswith("TEXTO")]

files

for f in files:print(f)

frame = pd.read_excel(ruta_siaf + files[0])
frame_head()


