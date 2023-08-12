import tabula
import os
import pandas as pd
import camelot
import re
import PyPDF2

# 1. Generamos las funciones que utilizaremos para cada pdf
def extraer_texto_despues(pdf_path, texto_buscar):
    with open(pdf_path, 'rb') as pdf_file:
        pdf_reader = PyPDF2.PdfReader(pdf_file)

        for pagina_num in range(len(pdf_reader.pages)):
            pagina = pdf_reader.pages[pagina_num]
            texto_pagina = pagina.extract_text()

            posicion_texto = texto_pagina.find(texto_buscar)
            if posicion_texto != -1:
                texto_despues = texto_pagina[posicion_texto + len(texto_buscar):]
                return texto_despues
    return None

# 2. Ruta al archivo PDF que deseas procesar y manejo de los pdf que utilizaremos
os.chdir("C:/Users/User/Documents/GitHub/CNHGitHub/Data Perú/Conflictos sociales/")
folder_path = "C:/Users/User/Documents/GitHub/CNHGitHub/Data Perú/Conflictos sociales/pdf_reports_conflictos_sociales/"

files = [f for f in os.listdir(folder_path) if os.path.isfile(os.path.join(folder_path, f))]

sorted_files = sorted(files, key=lambda x: os.path.getmtime(os.path.join(folder_path, x)))

n_reportes = []
contador = 0
for item in sorted_files:
    name = item[:3]
    try:
        name = int(name)
    except:
        name = item[:2]
    n_reportes.append(name)
    contador = contador + 1

contador = 0
for report in sorted_files:
    try:
        if n_reportes[contador] > 125 :
            pdf_path = folder_path + report
            texto_a_buscar = "PERÚ: CONFLICTOS SOCIOAMBIENTALES ACTIVOS, SEGÚN ACTIVIDAD, "
            texto_despues = extraer_texto_despues(pdf_path, texto_a_buscar)

            # Encontrar los encabezados y los valores usando expresiones regulares
            encabezados = re.findall(r'^(TOTAL|Minería|Hidrocarburos|Residuos y saneamiento|Otros|Agroindustrial|Energía|Forestales)\s+', texto_despues, re.MULTILINE)
            valores = re.findall(r'(\d+)\s+(\d+\.\d+)%', texto_despues)

            # Crear una lista de diccionarios para construir el DataFrame
            data = [{'Actividad': encabezados[i], 'Conteo': int(valores[i][0]), '%': float(valores[i][1])} for i in range(len(encabezados))]

            # Crear el DataFrame
            locals()[f'df_{n_reportes[contador]}'] = pd.DataFrame(data)
            print(n_reportes[contador])
        else:
            print("otra")
        contador = contador +1
    except:
        print(f'No funciona {n_reportes[contador]}')
        contador = contador +1
        continue

pdf_path = "C:/Users/User/Documents/GitHub/CNHGitHub/Data Perú/Conflictos sociales/pdf_reports_conflictos_sociales/216_202_2.pdf"

# TEXTO A BUSCAR entre Agosto 2014 a la fecha | 126 a 233 | "PERÚ: CONFLICTOS SOCIOAMBIENTALES ACTIVOS, SEGÚN ACTIVIDAD, "
# Texto a buscar entre Marzo 2013 y Julio 2014 | 109 a 125 | conflictos socioambientales activos de acuerdo
# Texto a buscar entre Noviembre 2012  y Febrero 2013 | 105 a 108 | Conflictos socioambientales según sector
# Antes no hay info de minería
texto_despues = extraer_texto_despues(pdf_path, texto_a_buscar)
texto_a_buscar = "PERÚ: CONFLICTOS SOCIOAMBIENTALES ACTIVOS, SEGÚN ACTIVIDAD, "

# Encontrar los encabezados y los valores usando expresiones regulares
encabezados = re.findall(r'^(TOTAL|Minería|Hidrocarburos|Residuos y saneamiento|Otros|Agroindustrial|Energía|Forestales)\s+', texto_despues, re.MULTILINE)
valores = re.findall(r'(\d+)\s+(\d+\.\d+)%', texto_despues)

# Crear una lista de diccionarios para construir el DataFrame
data = [{'Actividad': encabezados[i], 'Conteo': int(valores[i][0]), '%': float(valores[i][1])} for i in range(len(encabezados))]

# Crear el DataFrame
df = pd.DataFrame(data)

