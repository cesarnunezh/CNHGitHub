import pandas as pd
import requests
import json  # Importa el módulo json
import time

# Define la URL de la API
url = "https://api.datosabiertos.mef.gob.pe/DatosAbiertos/v1/datastore_search"

prodList = ['3000608', '3000876', '3000877', '3000878', '3000891',
            '3000892', '3033251', '3033254', '3033255', '3033315', '3033414']

dfFinal = pd.DataFrame()

# LOS RESOURCES ID SON DEL DEVENGADO MENSUAL
aniosId = {'2018': 'f9735158-198b-4262-9441-83bb06a03fe7',
           '2019': '4bbc3f9d-1d37-4983-a1a0-7ad2c6b02744',
           '2020': '76f772c2-23f5-4706-b9e6-9d192c2b1d1e',
           '2021': '1d912e83-17d5-46da-82e2-bbbefd3074d6',
           '2022': '1adaec22-308f-4396-8f71-9ecc481c930b',
           '2023': 'c28a4a61-8813-414c-ab72-44fd888292d4'}

for anio in aniosId.keys():
    for prog in prodList:
        try:
            # Parámetros de la consulta
            params = {
                "resource_id": aniosId[anio],
                "filters": json.dumps({
                    "PRODUCTO_PROYECTO": prog,
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
                df = df.drop_duplicates()
                df = df[(df['PRODUCTO_PROYECTO_NOMBRE']!='ACCIONES COMUNES')]
                df['ANIO'] = anio
                dfFinal = pd.concat([dfFinal,df])
                print("Sabes")

            else:
                print("Error al realizar la consulta. Código de estado:", response.status_code)

        except:
            print(f'No funciona el {prog}')
            continue

    try:
        # Parámetros de la consulta
        params = {
            "resource_id": aniosId[anio],
            "filters": json.dumps({
                'PROGRAMA_PPTO': '1001',
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
            df = df.drop_duplicates()
            df = df[(df['PRODUCTO_PROYECTO_NOMBRE']!='ACCIONES COMUNES')]
            df['ANIO'] = anio
            dfFinal = pd.concat([dfFinal,df])
            print("Sabes")

        else:
            print("Error al realizar la consulta. Código de estado:", response.status_code)

    except:
        print(f'No funciona el PPoR 1001')
        continue



dfFinal = dfFinal.drop_duplicates()
#df = dfFinal[dfFinal['PROGRAMA_PPTO']=='1001']

varList =['MONTO_DEVENGADO_OCTUBRE', 'MONTO_DEVENGADO_SEPTIEMBRE', 'MONTO_DEVENGADO_NOVIEMBRE',
          'MONTO_DEVENGADO_MARZO', 'MONTO_DEVENGADO_JUNIO', 'MONTO_DEVENGADO_JULIO',
          'MONTO_DEVENGADO_FEBRERO','MONTO_DEVENGADO_ENERO', 'MONTO_DEVENGADO_DICIEMBRE',
          'MONTO_DEVENGADO_AGOSTO', 'MONTO_DEVENGADO_ABRIL','MONTO_DEVENGADO_MAYO']

for var in varList:
    dfFinal[var] = dfFinal[var].astype(float)


df = dfFinal.groupby(by = ['ANIO', 'PROGRAMA_PPTO','PRODUCTO_PROYECTO','PRODUCTO_PROYECTO_NOMBRE'])[['MONTO_DEVENGADO_OCTUBRE', 'MONTO_DEVENGADO_SEPTIEMBRE', 'MONTO_DEVENGADO_NOVIEMBRE', 'MONTO_DEVENGADO_MARZO', 'MONTO_DEVENGADO_JUNIO', 'MONTO_DEVENGADO_JULIO', 'MONTO_DEVENGADO_FEBRERO','MONTO_DEVENGADO_ENERO', 'MONTO_DEVENGADO_DICIEMBRE', 'MONTO_DEVENGADO_AGOSTO', 'MONTO_DEVENGADO_ABRIL','MONTO_DEVENGADO_MAYO']].sum()

df['MONTO_DEVENGADO'] = df['MONTO_DEVENGADO_OCTUBRE'] + df['MONTO_DEVENGADO_SEPTIEMBRE'] + df['MONTO_DEVENGADO_NOVIEMBRE'] + df['MONTO_DEVENGADO_MARZO'] + df['MONTO_DEVENGADO_JUNIO'] + df['MONTO_DEVENGADO_JULIO'] + df['MONTO_DEVENGADO_FEBRERO'] + df['MONTO_DEVENGADO_ENERO'] + df['MONTO_DEVENGADO_DICIEMBRE'] + df['MONTO_DEVENGADO_AGOSTO'] + df['MONTO_DEVENGADO_ABRIL'] + df['MONTO_DEVENGADO_MAYO']

df = df.reset_index()
df = df.loc[:,('ANIO', 'PROGRAMA_PPTO', 'PRODUCTO_PROYECTO','PRODUCTO_PROYECTO_NOMBRE','MONTO_DEVENGADO')]