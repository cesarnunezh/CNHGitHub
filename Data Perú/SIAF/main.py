import pandas as pd
import requests
import json  # Importa el módulo json

# Define la URL de la API
url = "https://api.datosabiertos.mef.gob.pe/DatosAbiertos/v1/datastore_search?"

# Define los parámetros de consulta para limitar los resultados a 10 registros
params = {
    "resource_id": "69abf535-ff9a-4975-ad13-72da442a0c44",
    "filters": json.dumps({"RUBRO": "18",
                           "TIPO_RECURSO": "P",  # H es canon minero, P es regalías mineras
                           "SEC_EJEC": "300622"})
    # "limit": 10
}

# Realiza la solicitud GET a la API con los parámetros de consulta
response = requests.get(url, params=params)

# Verifica si la solicitud fue exitosa (código de respuesta 200)
if response.status_code == 200:
    # Imprime la respuesta de la API en formato JSON
    data = response.json()
    records = data['records']
    df = pd.DataFrame.from_records(records)
    ruta_archivo = "C:\\Users\\USER\\Downloads\\resultado.xlsx"
    df.to_excel(ruta_archivo, index=False)
    print(f"DataFrame exportado a {ruta_archivo} exitosamente.")
    # print(df)
else:
    print("La solicitud no fue exitosa. Código de respuesta:", response.status_code)
