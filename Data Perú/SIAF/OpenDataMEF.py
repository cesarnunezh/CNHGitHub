import pandas as pd
import os
import time
import dask.dataframe as dd

os.chdir(r'C:\Users\User\OneDrive - Universidad del Pacífico\1. Documentos\0. Bases de datos\01. Datos Abiertos - MEF\1. Data')

daskdd = dd.read_csv('2021-Gasto.csv')
daskdd.head()

daskdd.npartitions
daskdd.dtypes

daskdd = daskdd[daskdd['TIPO_GOBIERNO']=="M"]
daskdd = daskdd[daskdd['PROVINCIA_EJECUTORA_NOMBRE']=="SATIPO"]
daskdd = daskdd[daskdd['TIPO_ACT_PROY']==2]
daskdd.head()

unique_values = daskdd['PROVINCIA_EJECUTORA_NOMBRE'].unique
