# Objetivo: Hacer un gráfico de barras dinámico (Bar Chart Race)

import pandas as pd
import numpy as np

#Importando la data
pollavidenza = pd.read_csv('D:/1. Documentos/0. Bases de datos/datos_polla_videnza.csv')

#Observando cómo está la data
pollavidenza.head()

#Eliminamos los NaN
pollavidenza.fillna(0, inplace=True)
pollavidenza.sort_values(list(pollavidenza.columns),inplace=True)
pollavidenza = pollavidenza.sort_index()
pollavidenza.head()

#Modificando la data a valores agregados de puntos
pollavidenza.iloc[:, 0:-1] = pollavidenza.iloc[:, 0:-1].cumsum()
pollavidenza.head()

#Como tenemos muchos equipos, eliminamos a aquellos que nunca quedarán en el top 6 en algún momento del tiempo
top_videnza = set()

for index, row in pollavidenza.iterrows():
    top_videnza |= set(row[row > 0].sort_values(ascending=False).head(6).index)

df = pollavidenza[top_videnza]
df.head()

#Instalando el package bar-chart-race

import bar_chart_race as bcr

bcr.bar_chart_race(df = df, 
                   n_bars = 8, 
                   sort='desc',
                   title='Polla Videnza',
                   period_length  = 750,
                   filename = 'polla_videnza.mp4')

bcr.bar_chart_race(df, img_label_folder = 'PL clubs', n_bars=6, period_length = 750)
