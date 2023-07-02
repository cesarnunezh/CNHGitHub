import requests

url = "https://api.natstat.com/v2/players/FC/?key=8c85-797b3e&format=json&max=1000"
print(requests.get(url).json())

