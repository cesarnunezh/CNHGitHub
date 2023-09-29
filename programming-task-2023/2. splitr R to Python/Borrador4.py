# IMPORTAR LIBRERIAS

import shutil
import calendar
import numpy as np
import os
import pandas as pd
import platform
import re
import requests
import struct
import subprocess

from datetime import datetime, timedelta
from ftplib import FTP
from urllib.request import urlopen


# DESCARGA DE MET FILES (ARCHIVOS.GBL, SOLO REANALYSIS)

def dosc(x):
    if len(str(x))==2:
        return str(x)
    elif len(str(x))==1:
        return "0"+str(x)
    else:
        pass

def yearsmonths(start_time, end_time):

    # Inicializa la lista de resultados
    years_months = []

    # Crea un objeto datetime para el primer día del mes de la fecha de inicio
    actual_time = datetime(start_time.year, start_time.month, 1)

    # Mientras la fecha actual sea menor o igual a la fecha de fin
    while actual_time <= end_time:
        # Agrega el año y el mes actual a la lista de resultados
        years_months.append((actual_time.year, actual_time.month))

        # Avanza al primer día del mes siguiente
        if actual_time.month == 12:
            actual_time = datetime(actual_time.year + 1, 1, 1)
        else:
            actual_time = datetime(actual_time.year, actual_time.month + 1, 1)

    return years_months



def download_ftp_files(met_type,start_time,end_time, dest_folder):
    
    try:
        shutil.rmtree(dest_folder)
    except OSError as e:
         pass

    os.mkdir(dest_folder)
    
    
    if met_type=="reanalysis":
        try:
            filesx=[]
            for x in yearsmonths(start_time, end_time):
                filesx.append("RP"+str(x[0])+dosc(x[1])+".gbl")

            # Parse the FTP URL to extract hostname and path
            ftp_parts = "ftp://arlftp.arlhq.noaa.gov/archives/reanalysis".split("/")
            ftp_hostname = ftp_parts[2]
            ftp_path = "/".join(ftp_parts[3:])

            # Connect to the FTP server
            with FTP(ftp_hostname) as ftp:
                # Login with anonymous credentials
                ftp.login()

                # Change to the specified directory
                ftp.cwd(ftp_path)

                # List the files in the directory
                files = ftp.nlst()


                # Download files to the destination folder
                for file in files:
                    if file in filesx:

                        local_filepath = os.path.join(dest_folder, file)
                        with open(local_filepath, "wb") as local_file:
                            ftp.retrbinary("RETR " + file, local_file.write)

                        print(f"Downloaded: {file}")

                print("Download completed successfully.")

        except Exception as e:
            print("An error occurred:", str(e))
        


destination_folder = "C:/Users/User/OneDrive - Universidad del Pacífico/1. Documentos/0. Bases de datos/12. RA NLP"

download_ftp_files("reanalysis",datetime(2015,1,25,0,0),datetime(2015,1,26,0,0), destination_folder)


















# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------











# VISUALIZAR NOMBRES DE TODOS LOS TIPOS DE ARCHIVOS

def download_ftp_files(ftp_url, dest_folder):
    try:
        # Parse the FTP URL to extract hostname and path
        ftp_parts = ftp_url.split("/")
        ftp_hostname = ftp_parts[2]
        ftp_path = "/".join(ftp_parts[3:])
        
        # Connect to the FTP server
        with FTP(ftp_hostname) as ftp:
            # Login with anonymous credentials
            ftp.login()
            
            # Change to the specified directory
            ftp.cwd(ftp_path)
            
            # List the files in the directory
            files = ftp.nlst()
            
        return files

#             # Download files to the destination folder
#             for file in files:
#                 local_filepath = os.path.join(dest_folder, file)
#                 with open(local_filepath, "wb") as local_file:
#                     ftp.retrbinary("RETR " + file, local_file.write)
                
#                 print(f"Downloaded: {file}")
            
#             print("Download completed successfully.")
    
    except Exception as e:
        print("An error occurred:", str(e))

# # Specify the FTP URL and destination folder
# ftp_url = "ftp://arlftp.arlhq.noaa.gov/archives/reanalysis"
# destination_folder = "C:/Users/matia/Documents/dispersion_model/met"

# # Call the function to download FTP files
# files=download_ftp_files(ftp_url, destination_folder)


met_links=[
"ftp://arlftp.arlhq.noaa.gov/archives/edas40", # edas40
"ftp://arlftp.arlhq.noaa.gov/forecast/", # forecast_nam
"ftp://arlftp.arlhq.noaa.gov/archives/gdas0p5", # gdas0.5
"ftp://arlftp.arlhq.noaa.gov/archives/gdas1", # gdas1
"ftp://arlftp.arlhq.noaa.gov/archives/gfs0p25", # gfs0.25
"ftp://arlftp.arlhq.noaa.gov/pub/archives/hrrr", # hrrr
"ftp://arlftp.arlhq.noaa.gov/archives/nam12", # nam12
"ftp://arlftp.arlhq.noaa.gov/archives/narr", # narr
"ftp://arlftp.arlhq.noaa.gov/archives/reanalysis"] # reanalysis

files1={}
# 
for x in met_links:
    files0=download_ftp_files(x, destination_folder)
    files1[x.split("/")[-1]]=files0
    
    
    
