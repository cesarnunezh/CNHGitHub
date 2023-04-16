"""
@project: Datos del fútbol peruano
@author: César Núñez
"""
################################################################################################
###############################IMPORTANDO LA DATA###############################################
################################################################################################

# Importamos las librerías que utilizaremos
import pandas as pd
import numpy as np
import requests
import os

# Seteamos el directorio de trabajo
os.chdir('D:/1. Documentos/0. Bases de datos/9. Futbol')

# Creando la base de datos de jugadores. Como solo hay información desde el 2015, generamos un loop

for anio in range(2015, 2023):

    if anio == 2015:
        url = 'https://fbref.com/en/comps/44/' + str(anio) + '/stats/' + str(anio) + '-Liga-1-Stats'
        response = requests.get(url).text.replace('<!--', '').replace('-->', '')
        df_jugadores = pd.read_html(response, header=1)[2]
        df_jugadores["year"] = anio
    else:
        url = 'https://fbref.com/en/comps/44/' + str(anio) + '/stats/' + str(anio) + '-Liga-1-Stats'
        response = requests.get(url).text.replace('<!--', '').replace('-->', '')
        df_alterna = pd.read_html(response, header=1)[2]
        df_alterna["year"] = anio
        df_jugadores = pd.concat([df_jugadores , df_alterna])

# Eliminamos las filas que repiten los nombres de las variables
df_jugadores = df_jugadores.loc[df_jugadores["Rk"] != 'Rk']

# Guardamos la base de datos.
df_jugadores.to_csv('jugadores_liga1.csv', index=False)

# Creando la base de datos de partidos.

for anio in range(2014, 2023) :

    if anio == 2014 :
        url= 'https://fbref.com/en/comps/44/' + str(anio) + '/schedule/' + str(anio) + '-Liga-1-Scores-and-Fixtures#sched_all'
        df_partidos = pd.read_html(response, header=0)[0]
    else :
        url= 'https://fbref.com/en/comps/44/' + str(anio) + '/schedule/' + str(anio) + '-Liga-1-Scores-and-Fixtures#sched_all'
        response = requests.get(url).text.replace('<!--', '').replace('-->', '')
        df_alterna2 = pd.read_html(response, header=0)[0]
        df_partidos = pd.concat([df_partidos , df_alterna2])

# Eliminamos las filas que repiten los nombres de las variables y las NaN
df_partidos = df_partidos.dropna(how='all')

# Guardamos la base de datos.
df_partidos.to_csv('partidos_liga1.csv', index=False)

################################################################################################
###############################TRABAJANDO LA DATA###############################################
################################################################################################

# Seteamos el directorio de trabajo
os.chdir('D:/1. Documentos/0. Bases de datos/9. Futbol')

df_partidos = pd.read_csv("partidos_liga1.csv")

df_partidos= df_partidos.rename(columns={'Round': 'Torneo', 'Wk': 'Fecha', 'Venue': 'Estadio', 'Referee': 'Arbitro'})

df_partidos = df_partidos.iloc[: , :-2]

df_partidos['Date'] = pd.to_datetime(df_partidos['Date'])

df_partidos['anio'] = df_partidos['Date'].dt.year

df_partidos['Goles_local'] = pd.Series(dtype=int)
df_partidos['Goles_visita'] = pd.Series(dtype=int)
df_partidos['Resultado'] = pd.Series(dtype=str)

for i,rows in df_partidos.iterrows():
    goles = df_partidos.loc[i,'Score'].split('–')

    df_partidos.loc[i ,'Goles_local'] = goles[0]
    df_partidos.loc[i ,'Goles_visita'] = goles[1]

    if goles[0] > goles[1]:
        df_partidos.loc[i , 'Resultado'] = "L"
    elif goles[0] == goles[1]:
        df_partidos.loc[i , 'Resultado'] = "E"
    else:
        df_partidos.loc[i , 'Resultado'] = "V"