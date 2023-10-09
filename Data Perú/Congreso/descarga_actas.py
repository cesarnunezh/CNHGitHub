import os
import re
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
import time

urlVotaciones = "https://www.congreso.gob.pe/AsistenciasVotacionesPleno/asistencia-votacion-pleno"
gruposParlamentarios = "https://www.congreso.gob.pe/integrantes-grupos-parlamentarios-2021-2026"
actasComisiones = "https://www.congreso.gob.pe/actascomisiones/"

# URL base de la página que contiene los enlaces a los PDFs
base_url = "https://www.congreso.gob.pe/actascomisiones/"

# Directorio donde se guardarán los archivos PDF descargados
download_dir = "pdfActasComisiones"
if not os.path.exists(download_dir):
    os.makedirs(download_dir)

page_url = base_url.format(page_num)

response = requests.get(page_url)
response.raise_for_status()
soup = BeautifulSoup(response.content, "html.parser")

pdf_links = soup.find_all("a", href=lambda href: href and href.endswith(".pdf") and ("Salud" in href or "conflictos" in href))



'''
# Registro de nombres de archivos descargados
downloaded_files = set()

# Función para extraer números del nombre de archivo
def extract_numbers(filename):
    numbers = re.findall(r'\d{1,3}', filename)  # Extraer números de hasta 3 cifras
    return numbers

# Función para descargar archivos PDF de una página específica
def download_pdfs(page_num):
    page_url = base_url.format(page_num)

    response = requests.get(page_url)
    response.raise_for_status()
    soup = BeautifulSoup(response.content, "html.parser")

    pdf_links = soup.find_all("a", href=lambda href: href and href.endswith(".pdf") and ("Salud" in href or "conflictos" in href))

    for link in pdf_links:
        pdf_url = urljoin(page_url, link["href"])
        pdf_name = link["href"].split("/")[-1]

        # Verificar si el archivo ya ha sido descargado
        if pdf_name in downloaded_files:
            print(f"{pdf_name} ya descargado. Omitiendo.")
            continue

        pdf_path = os.path.join(download_dir, pdf_name)

        print(f"Descargando {pdf_name}...")
        pdf_response = requests.get(pdf_url)
        with open(pdf_path, "wb") as pdf_file:
            pdf_file.write(pdf_response.content)

        # Extraer números del nombre de archivo
        numbers = extract_numbers(pdf_name)
        new_filename = "_".join(numbers) + ".pdf"
        new_filepath = os.path.join(download_dir, new_filename)

        # Renombrar el archivo descargado
        try:
            os.rename(pdf_path, new_filepath)
            downloaded_files.add(pdf_name)
        except:
            continue
        print(f"{pdf_name} renombrado como {new_filename}.")

# Iterar a través de las páginas (por ejemplo, de la 1 a la 91)
start_page = 1
end_page = 91  # Actualiza este valor con el número de la última página
for page_num in range(start_page, end_page + 1):
    download_pdfs(page_num)
    time.sleep(4)

print("Descarga y renombrado completados.")



