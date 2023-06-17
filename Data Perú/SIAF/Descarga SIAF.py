from selenium import webdriver
from selenium.webdriver.support.ui import Select
import pandas as pd
from bs4 import BeautifulSoup
import time
from datetime import datetime, timedelta
import numpy as np
import chromedriver_autoinstall

date = datetime.today() - timedelta(1)

inicio = time.time()

chromedriver_autoinstall.install()
options = webdriver.ChromeOptions()
options.add_argument( '--ignore-certificate-errors' )
options.add_argument( '--incognito' )  # Para que entre en modo incógnito
options.add_argument( '--headless' )  # No abrirá una ventana de buscador
driver = webdriver.Chrome( chrome_options=options )

driver.set_page_load_timeout( 10 )
web = driver.get( 'https://apps5.mineco.gob.pe/transparencia/mensual/' )
time.sleep( 10 )

## Scraping por gobierno regional

frame = driver.find_element_by_xpath( '//*[@id="frame0"]' )
driver.switch_to.frame( frame )

#Seleccionar proyecto
select = Select(driver.find_element_by_id('ctl00_CPH1_DrpActProy'))
# select by value
select.select_by_value('Proyecto')

# frame = driver.find_element_by_xpath( '//*[@id="frame0"]' )
# driver.switch_to.frame( frame )
#
# ## Total (Sin ingresar a los niveles de gobierno)
#
# departamento = driver.find_element_by_id('ctl00_CPH1_BtnDepartamentoMeta')
# departamento.click()
# time.sleep(1.5)
#
# data = pd.DataFrame()
#
# x = BeautifulSoup(driver.page_source, 'html.parser')
# table = x.find( 'table', attrs={'class': 'Data'} )
# table_body = table.find( 'tbody' )
# rows = table_body.find_all( 'tr' )
# tab = []
# for row in rows:
#     cols = row.find_all( 'td' )
#     cols = [ele.text.strip() for ele in cols]
#     tab.append( [ele for ele in cols if ele] )
#
# total = pd.DataFrame(tab)
# total = total.assign(nivel='Total')
# total.columns = ['departamento', 'pia','pim','certificacion','compromiso',
#                  'atencion','devengado','girado','avance','nivel']
#
# data = data.append(total)


## Por niveles de gobierno

frame = driver.find_element_by_xpath( '//*[@id="frame0"]' )
driver.switch_to.frame( frame )

driver.execute_script( "document.querySelector('#tr0').click();" )
time.sleep( 1.5 )

nivel = driver.find_element_by_id('ctl00_CPH1_BtnTipoGobierno')
nivel.click()
time.sleep(1.5)

x = BeautifulSoup(driver.page_source, 'html.parser')
table = x.find( 'table', attrs={'class': 'Data'} )
table_body = table.find( 'tbody' )
rows = table_body.find_all( 'tr' )
niveles_gob = []
for row in rows:
    cols = row.find_all( 'td' )
    cols = [ele.text.strip() for ele in cols]
    niveles_gob.append( [ele for ele in cols if ele] )
niveles_gob = pd.DataFrame( niveles_gob)
niveles_gob = niveles_gob.assign(departamento = 'Nacional')
niveles_gob.columns = ['nivel',1,2,3,4,5,6,7,8,'departamento']
niveles_gob = niveles_gob.reindex(columns = ['departamento','nivel',1,2,3,4,5,6,7,8])

# Revisar al final para agregar

niv_gob = niveles_gob['nivel']
niv_gob = niv_gob.to_list()

# Para todos menos Lima metropolitana y provincias

data = pd.DataFrame()

for n in range(len(niv_gob)):
    driver.execute_script("document.querySelector('#tr" + str(n) +"').click();")
    time.sleep( 1.5 )
    departamento = driver.find_element_by_id('ctl00_CPH1_BtnDepartamentoMeta')
    departamento.click()
    time.sleep(1.5)
    x = BeautifulSoup( driver.page_source, 'html.parser' )
    table = x.find( 'table', attrs={'class': 'Data'} )
    table_body = table.find( 'tbody' )
    rows = table_body.find_all( 'tr' )
    tab = []
    for row in rows:
        cols = row.find_all( 'td' )
        cols = [ele.text.strip() for ele in cols]
        tab.append( [ele for ele in cols if ele] )
    niv = pd.DataFrame(tab)
    niv = niv.assign( nivel = niv_gob[n])
    niv.columns = ['departamento',1,2,3,4,5,6,7,8,'nivel']
    niv = niv.reindex( columns = ['departamento','nivel',1,2,3,4,5,6,7,8])
    data = data.append(niv)
    driver.execute_script("document.querySelector( '#ctl00_CPH1_RptHistory_ctl02_TD0' ).click();")
    time.sleep( 1.5 )

driver.close()

data = data.append(niveles_gob)

conditions = [(data['departamento'] == 'Nacional'),
              (data['departamento'] == '01: AMAZONAS'),
              (data['departamento'] == '02: ANCASH'),
              (data['departamento'] == '03: APURIMAC') ,
              (data['departamento'] == '04: AREQUIPA'),
              (data['departamento'] == '05: AYACUCHO'),
              (data['departamento'] == '06: CAJAMARCA'),
              (data['departamento'] == '07: PROVINCIA CONSTITUCIONAL DEL CALLAO'),
              (data['departamento'] == '08: CUSCO'),
              (data['departamento'] == '09: HUANCAVELICA'),
              (data['departamento'] == '10: HUANUCO'),
              (data['departamento'] == '11: ICA'),
              (data['departamento'] == '12: JUNIN'),
              (data['departamento'] == '13: LA LIBERTAD'),
              (data['departamento'] == '14: LAMBAYEQUE'),
              (data['departamento'] == '15: LIMA'),
              (data['departamento'] == '16: LORETO'),
              (data['departamento'] == '17: MADRE DE DIOS'),
              (data['departamento'] == '18: MOQUEGUA'),
              (data['departamento'] == '19: PASCO'),
              (data['departamento'] == '20: PIURA'),
              (data['departamento'] == '21: PUNO'),
              (data['departamento'] == '22: SAN MARTIN'),
              (data['departamento'] == '23: TACNA'),
              (data['departamento'] == '24: TUMBES'),
              (data['departamento'] == '25: UCAYALI'),
              (data['departamento'] == '98: EXTERIOR')]

values = ['Nacional',
          'Amazonas',
          'Áncash',
          'Apurímac',
          'Arequipa',
          'Ayacucho',
          'Cajamarca',
          'Callao',
          'Cusco',
          'Huancavelica',
          'Huánuco',
          'Ica',
          'Junín',
          'La Libertad',
          'Lambayeque',
          'Lima',
          'Loreto',
          'Madre de Dios',
          'Moquegua',
          'Pasco',
          'Piura',
          'Puno',
          'San Martín',
          'Tacna',
          'Tumbes',
          'Ucayali',
          'Exterior']

data['departamento'] = np.select( conditions, values )

conditions = [(data['nivel'] == 'E: GOBIERNO NACIONAL'), (data['nivel'] == 'M: GOBIERNOS LOCALES'), (data['nivel'] == 'R: GOBIERNOS REGIONALES')]
values = ['Gobierno Nacional', 'Gobiernos Locales' , 'Gobiernos Regionales']
data['nivel'] = np.select( conditions, values )

data = data[['departamento','nivel',2,6]]

data[[2,6]] = data[[2,6]].replace(',','',regex = True).astype(float)

data['ejecucion_pim'] = data[6] / data[2]

data.columns = ['departamento','nivel','pim','ejecucion','ejecucion_pim']
data = data.reindex( columns = ['departamento','nivel','ejecucion_pim','pim','ejecucion'])

# Lima metropolitana y Lima provincias

driver = webdriver.Chrome( chrome_options=options )
driver.set_page_load_timeout( 10 )
web = driver.get( 'https://apps5.mineco.gob.pe/transparencia/mensual/' )
time.sleep( 10 )

frame = driver.find_element_by_xpath( '//*[@id="frame0"]' )
driver.switch_to.frame( frame )

#Seleccionar proyecto
select = Select(driver.find_element_by_id('ctl00_CPH1_DrpActProy'))
# select by value
select.select_by_value('Proyecto')

## Por niveles de gobierno

frame = driver.find_element_by_xpath( '//*[@id="frame0"]' )
driver.switch_to.frame( frame )

driver.execute_script( "document.querySelector('#tr0').click();" )
time.sleep( 1.5 )

nivel = driver.find_element_by_id('ctl00_CPH1_BtnTipoGobierno')
nivel.click()
time.sleep(1.5)

### Gobierno local

driver.execute_script( "document.querySelector('#tr1').click();" )
time.sleep( 1.5 )

departamento = driver.find_element_by_id('ctl00_CPH1_BtnDepartamentoMeta')
departamento.click()
time.sleep(1.5)

driver.execute_script( "document.querySelector('#tr14').click();" )
time.sleep( 1.5 )

sub = driver.find_element_by_id('ctl00_CPH1_BtnSubTipoGobierno')
sub.click()
time.sleep(1.5)

driver.execute_script( "document.querySelector('#tr0').click();" )
time.sleep( 1.5 )

desagregacion = driver.find_element_by_id('ctl00_CPH1_BtnDepartamento')
desagregacion.click()
time.sleep(1.5)

driver.execute_script( "document.querySelector('#tr0').click();" )
time.sleep( 1.5 )

prov = driver.find_element_by_id('ctl00_CPH1_BtnProvincia')
prov.click()
time.sleep(1.5)

x = BeautifulSoup(driver.page_source, 'html.parser')
table = x.find( 'table', attrs={'class': 'Data'} )
table_body = table.find( 'tbody' )
rows = table_body.find_all( 'tr' )
lima_metro = []
for row in rows:
    cols = row.find_all( 'td' )
    cols = [ele.text.strip() for ele in cols]
    lima_metro.append( [ele for ele in cols if ele] )

gl_lima = pd.DataFrame(lima_metro)
gl_lima = gl_lima[[2,6]]
gl_lima[[2,6]] = gl_lima[[2,6]].replace(',','',regex = True).astype(float)

gl_lima = gl_lima.transpose()

gl_lima['Lima provincias'] = gl_lima[1] + gl_lima[2] + gl_lima[3] + gl_lima[4] + gl_lima[5] + \
                             gl_lima[6] + gl_lima[7] + gl_lima[8] + gl_lima[9]
gl_lima['Lima metropolitana'] = gl_lima[0]

gl_lima = gl_lima[['Lima provincias','Lima metropolitana']]

gl_lima = gl_lima.transpose()
gl_lima = gl_lima.reset_index()

gl_lima = gl_lima.assign(nivel = 'Gobiernos Locales')

gl_lima['ejecucion_pim'] = gl_lima[6] / gl_lima[2]

gl_lima.columns = ['departamento','pim','ejecucion','nivel','ejecucion_pim']
gl_lima = gl_lima.reindex( columns = ['departamento','nivel','ejecucion_pim','pim','ejecucion'])


### Gobierno regional

atras = driver.find_element_by_id('ctl00_CPH1_RptHistory_ctl02_TD0')
atras.click()
time.sleep(1.5)

driver.execute_script( "document.querySelector('#tr2').click();" )
time.sleep( 1.5 )

departamento = driver.find_element_by_id('ctl00_CPH1_BtnDepartamentoMeta')
departamento.click()
time.sleep(1.5)

driver.execute_script( "document.querySelector('#tr14').click();" )
time.sleep( 1.5 )

sector = driver.find_element_by_id('ctl00_CPH1_BtnSector')
sector.click()
time.sleep( 1.5 )

driver.execute_script( "document.querySelector('#tr0').click();" )
time.sleep( 1.5 )

pliego = driver.find_element_by_id('ctl00_CPH1_BtnPliego')
pliego.click()
time.sleep( 1.5 )

x = BeautifulSoup(driver.page_source, 'html.parser')
table = x.find( 'table', attrs={'class': 'Data'} )
table_body = table.find( 'tbody' )
rows = table_body.find_all( 'tr' )
lima_metro = []
for row in rows:
    cols = row.find_all( 'td' )
    cols = [ele.text.strip() for ele in cols]
    lima_metro.append( [ele for ele in cols if ele] )

gr_lima = pd.DataFrame(lima_metro)
gr_lima = gr_lima[[0,2,6]]

gr_lima[[2,6]] = gr_lima[[2,6]].replace(',','',regex = True).astype(float)

conditions = [(gr_lima[0] == '463: GOBIERNO REGIONAL DEL DEPARTAMENTO DE LIMA'),
              (gr_lima[0] == '465: MUNICIPALIDAD METROPOLITANA DE LIMA')]

values = ['Lima provincias','Lima metropolitana']

gr_lima[0] = np.select( conditions, values )

gr_lima = gr_lima.assign(nivel = 'Gobiernos Regionales')

gr_lima['ejecucion_pim'] = gr_lima[6] / gr_lima[2]

gr_lima.columns = ['departamento','pim','ejecucion','nivel','ejecucion_pim']
gr_lima = gr_lima.reindex( columns = ['departamento','nivel','ejecucion_pim','pim','ejecucion'])

driver.close()

############################################################

# Union de datos - Parte 1

data = data.append(gr_lima)
data = data.append(gl_lima)

############################################################

# Generados los totales de datos

total = data[['departamento','pim','ejecucion']]
total = total.groupby(['departamento']).sum().reset_index()

total['ejecucion_pim'] = total['ejecucion'] / total['pim']
total = total.assign(nivel = 'Total')
total = total[['departamento','nivel','ejecucion_pim','pim','ejecucion']]

############################################################

# Union de datos - Parte 2

data = data.append(total)
data= data.loc[(data['departamento'] != 'Exterior')]

############################################################

date = datetime.now()
a = date.year
m = date.month
d = date.day

if m == 1:
    anio = a - 1
else:
    anio = a

data = data.assign( anio= anio )
data = data.assign( grafico= 26 )
data = data.assign( estado=1 )
data = data.assign( audi_user_crea=1 )
data = data.assign( audi_user_edita=1 )
data = data.assign( audi_fecha_crea=date )
data = data.assign( audi_fecha_edita=date )
data = data.reindex( columns=['grafico', 'estado', 'audi_user_crea', 'audi_user_edita',
                              'audi_fecha_crea', 'audi_fecha_edita', 'anio','departamento',
                              'nivel','ejecucion_pim','pim','ejecucion'] )

# data.to_excel(r'C:\Users\Carolina\Desktop\Productos - Preliminar\Automatizaciones\ge_101_mod.xlsx',index=False)

fin = time.time()
print( fin - inicio )