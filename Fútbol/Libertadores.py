
import pandas as pd
import numpy as np
import requests
import os
import time



ligas = ['Libertadores', 'Perú' , 'Sudamericana']
links = ['-Copa-Libertadores-Stats' , '-Liga-1-Stats' , '-Copa-Sudamericana-Stats']
number = ['14', '44', '205']

for anio in range(2021, 2023):
    contador = 0
    for link in links:
        if anio == 2021:
            url = 'https://fbref.com/en/comps/' + number[contador] + '/' + str(anio) + '/stats/' + str(anio) + link
            response = requests.get(url).text.replace('<!--', '').replace('-->', '')
            df_jugadores = pd.read_html(response, header=1)[2]
            df_jugadores["year"] = anio
            df_jugadores["ligas"] = ligas[contador]
            time.sleep(5)
        else:
            url = 'https://fbref.com/en/comps/' + number[contador] + '/' + str(anio) + '/stats/' + str(anio) + link
            response = requests.get(url).text.replace('<!--', '').replace('-->', '')
            df_alterna = pd.read_html(response, header=1)[2]
            df_alterna["year"] = anio
            df_jugadores["ligas"] = ligas[contador]
            df_jugadores = pd.concat([df_jugadores , df_alterna])
            time.sleep(5)

        contador = contador + 1
