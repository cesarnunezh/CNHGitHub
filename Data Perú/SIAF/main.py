import pandas as pd
import requests
import json  # Importa el módulo json
import time

# Define la URL de la API
url = "https://api.datosabiertos.mef.gob.pe/DatosAbiertos/v1/datastore_search"

progList = ['24', '30', '31', '36', '49', '51', '58', '66', '68', '73', '79', '82',
            '87', '90', '93', '96', '97', '101', '103', '106', '109', '113', '115',
            '116', '117', '122', '124', '125', '127', '129','138', '142', '146',
            '147', '148', '150', '1001', '1002']

dfFinal = pd.DataFrame()

for prog in progList:
    try:
        # Parámetros de la consulta
        params = {
            "resource_id": "c28a4a61-8813-414c-ab72-44fd888292d4",
            "filters": json.dumps({
                "PROGRAMA_PPTO": prog,
                "TIPO_ACT_PROY" : "ACTIVIDAD"
            })
        }

        # Realiza la solicitud GET a la API con los parámetros de consulta
        response = requests.get(url, params=params)

        # Verifica si la solicitud fue exitosa (código de respuesta 200)
        if response.status_code == 200:
            # Imprime la respuesta de la API en formato JSON
            data = response.json()
            records = data['records']
            df = pd.DataFrame.from_records(records)
            df = df.loc[:, ['PROGRAMA_PPTO', 'PROGRAMA_PPTO_NOMBRE', 'PRODUCTO_PROYECTO_NOMBRE','PRODUCTO_PROYECTO','ACTIVIDAD_ACCION_OBRA_NOMBRE','ACTIVIDAD_ACCION_OBRA', 'META_NOMBRE', 'FINALIDAD', 'TIPO_ACT_PROY']]
            df = df.drop_duplicates()
            df = df[(df['PRODUCTO_PROYECTO_NOMBRE']!='ACCIONES COMUNES')]
            dfFinal = pd.concat([dfFinal,df])
            print("Sabes")

        else:
            print("Error al realizar la consulta. Código de estado:", response.status_code)

    except:
        print(f'No funciona el {prog}')
        continue


df = dfFinal[dfFinal['PROGRAMA_PPTO']=='1001']
