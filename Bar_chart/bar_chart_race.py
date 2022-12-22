# Objetivo: Hacer un gráfico de barras dinámico (Bar Chart Race)

import pandas as pd
import numpy as np

#Importando la data
prem_league = pd.read_csv('D:/1. Documentos/0. Bases de datos/premierLeague_tables_1992-2017.csv')

#Observando cómo está la data
prem_league.head()

#Eliminando las variables que no me sirven
prem_league = prem_league[['season', 'team', 'points']]
prem_league.head()

#Transformando la data de panel a un wide data
df = prem_league.pivot_table(values = 'points',index = ['season'], columns = 'team')
df.head()

#Eliminamos los NaN
df.fillna(0, inplace=True)
df.sort_values(list(df.columns),inplace=True)
df = df.sort_index()
df.head()

#Modificando la data a valores agregados de puntos
df.iloc[:, 0:-1] = df.iloc[:, 0:-1].cumsum()
df.head()

#Como tenemos muchos equipos, eliminamos a aquellos que nunca quedarán en el top 6 en algún momento del tiempo
top_prem_clubs = set()

for index, row in df.iterrows():
    top_prem_clubs |= set(row[row > 0].sort_values(ascending=False).head(6).index)

df = df[top_prem_clubs]
df.head()

#Instalando el package bar-chart-race

import bar_chart_race as bcr

bcr.bar_chart_race(df = df,
                   n_bars = 6,
                   sort='desc',
                   title='Premier League Clubs Points Since 1992',
                   period_length  = 750,
                   filename = 'pl_clubs.mp4')

bcr.bar_chart_race(df, img_label_folder = 'PL clubs', n_bars=6, period_length = 750)