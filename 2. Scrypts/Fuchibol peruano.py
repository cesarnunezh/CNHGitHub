"""
@author: César Núñez
"""
#Importamos las librerías que utilizaremos
import pandas as pd
import requests
from bs4 import BeautifulSoup

# Definiendo la url a utilizar
url = "https://fbref.com/en/comps/44/stats/Liga-1-Stats"

# Creamos un objeto de consulta de pagina
page = requests.get(url)

# parser-lxml = Change html to Python friendly format
# Obtain page's information
soup = BeautifulSoup(page.text, 'lxml')
soup

# Obtain information from tag <table>
soup.table.div


table1 = soup.find( 'table' , id ="stats_standard")
table1