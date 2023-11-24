import os

path = r"C:\Users\User\Downloads\ENDES\Data"
listYear = os.listdir(path)

for year in listYear:
    newPath = path + "/" + year
    listData = os.listdir(newPath)
    for data in listData:
        dataPath = path + "/" + year + "/" + data
        newDataPath = path + "/" + year + "/" + data[:-4] + f"_{year}" + data[-4:]
        os.rename(dataPath, newDataPath)