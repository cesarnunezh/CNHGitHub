import urllib3
url = 'https://api.datosabiertos.mef.gob.pe/DatosAbiertos/v1/datastore_search?resource_id=f075d8af-1352-4f16-a3da-61f45fa4d502&limit=5&q=jones'
urllib3.request(url)
print(fileobj.read())