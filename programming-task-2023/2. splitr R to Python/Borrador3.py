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


def met_download(urls, local_path):
    for url in urls:
        response = requests.get(url)
        if response.status_code == 200:
            with open(local_path, 'wb') as f:
                f.write(response.content)


def read_listing_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        return [line.strip() for line in lines]
    


def hysplit_config_init(dir_path):
    # Default SETUP.CFG configuration file
    setup_cfg_content = [
        "&SETUP",
        "tratio = 0.75,",
        "initd = 0,",
        "kpuff = 0,",
        "khmax = 9999,",
        "kmixd = 0,",
        "kmix0 = 250,",
        "kzmix = 0,",
        "kdef = 0,",
        "kbls = 1,",
        "kblt = 2,",
        "conage = 48,",
        "numpar = 2500,",
        "qcycle = 0.0,",
        "efile = '',",
        "tkerd = 0.18,",
        "tkern = 0.18,",
        "ninit = 1,",
        "ndump = 1,",
        "ncycl = 1,",
        "pinpf = 'PARINIT',",
        "poutf = 'PARDUMP',",
        "mgmin = 10,",
        "kmsl = 0,",
        "maxpar = 10000,",
        "cpack = 1,",
        "cmass = 0,",
        "dxf = 1.0,",
        "dyf = 1.0,",
        "dzf = 0.01,",
        "ichem = 0,",
        "maxdim = 1,",
        "kspl = 1,",
        "krnd = 6,",
        "frhs = 1.0,",
        "frvs = 0.01,",
        "frts = 0.10,",
        "frhmax = 3.0,",
        "splitf = 1.0,",
        "tm_pres = 0,",
        "tm_tpot = 0,",
        "tm_tamb = 0,",
        "tm_rain = 0,",
        "tm_mixd = 0,",
        "tm_relh = 0,",
        "tm_sphu = 0,",
        "tm_mixr = 0,",
        "tm_dswf = 0,",
        "tm_terr = 0,",
        "/",
    ]

    # Default ASCDATA.CFG file
    ascdata_cfg_content = [
        "-90.0  -180.0  lat/lon of lower left corner (last record in file)",
        "1.0  1.0    lat/lon spacing in degrees between data points",
        "180  360    lat/lon number of data points",
        "2    default land use category",
        "0.2    default roughness length (meters)",
        "'.'  directory location of data files",
    ]

    # Write SETUP.CFG file
    with open(f"{dir_path}/SETUP.CFG", "w") as setup_file:
        setup_file.write("\n".join(setup_cfg_content))

    # Write ASCDATA.CFG file
    with open(f"{dir_path}/ASCDATA.CFG", "w") as ascdata_file:
        ascdata_file.write("\n".join(ascdata_cfg_content))



        

def get_os():
    if platform.system() == "Windows":
        return "win"
    elif platform.system() == "Darwin":
        return "mac"
    elif platform.system() == "Linux":
        return "unix"
    else:
        raise ValueError("Unknown OS")




def is_64bit_system():
    return struct.calcsize("P") * 8 == 64



def to_null_dev(system_type):
    if system_type in ["mac", "unix"]:
        null_dev = ">> /dev/null 2>&1"
    elif system_type == "win":
        null_dev = "> NUL 2>&1"
    else:
        raise ValueError("Unknown system type")

    return null_dev




def execute_on_system(sys_cmd, system_type):
    try:
        if system_type in ["mac", "unix"]:
            subprocess.run(sys_cmd, shell=True, check=True)
        elif system_type == "win":
            subprocess.run(sys_cmd, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print("Error executing command:", e)
        



def set_binary_path(binary_path, binary_name):
    if binary_path is None:
        system_os = get_os()  # Asegúrate de tener definida la función get_os()

        if system_os == "mac":
            binary_path = os.path.join(os.path.dirname(os.getcwd()), "osx", binary_name)

        if system_os == "unix":
            binary_path = os.path.join(os.path.dirname(os.getcwd()), "linux-amd64", binary_name)

        if system_os == "win":
            binary_path = os.path.join(os.path.dirname(os.getcwd()), "win", f"{binary_name}.exe")
    else:
        binary_path = os.path.join(binary_path, binary_name)

    return binary_path




def create_file_list(output_folder, create_file=True, file_name="file_list.txt"):
    # List files from the specified archive folder
    file_list = [file for file in os.listdir(output_folder) if file.startswith("traj")]

    # Create file list in the output folder
    if create_file:
        with open(os.path.join(output_folder, file_name), "w") as f:
            f.write("\n".join(file_list))

    return file_list




def to_short_year(date):
    year = datetime.strptime(date, "%Y-%m-%d").year
    short_year = str(year)[-2:]
    return short_year




def to_short_month(date):
    month = datetime.strptime(date, "%Y-%m-%d").month
    short_month = f"{month:02d}"
    return short_month




def to_short_day(date):
    day = datetime.strptime(date, "%Y-%m-%d").day
    short_day = f"{day:02d}"
    return short_day







def get_monthly_filenames(days, duration, direction, prefix=None, extension=None):
    if direction == "backward":
        min_month = (datetime.strptime(days, "%Y-%m-%d") - timedelta(hours=duration) - timedelta(days=1)).replace(day=1)
    elif direction == "forward":
        min_month = datetime.strptime(days, "%Y-%m-%d").replace(day=1)

    max_month = min_month + timedelta(days=30)
    met_months = [min_month]

    while met_months[-1] < max_month:
        met_months.append(met_months[-1] + timedelta(days=30))

    months_short = [m.strftime("%b") for m in met_months]
    years_long = [str(m.year) for m in met_months]

    filenames = [f"{prefix}{year}{month}{extension}" for year, month in zip(years_long, months_short)]

    return filenames




def get_daily_filenames(days, duration, direction, prefix=None, suffix=None):
    min_day = None
    max_day = None

    if direction == "backward":
        min_day = min([datetime.strptime(day, "%Y-%m-%d") - timedelta(hours=duration) - timedelta(days=1) for day in days])
    elif direction == "forward":
        min_day = min([datetime.strptime(day, "%Y-%m-%d") for day in days])

    if direction == "backward":
        max_day = max([datetime.strptime(day, "%Y-%m-%d") for day in days])
    elif direction == "forward":
        max_day = max([datetime.strptime(day, "%Y-%m-%d") + timedelta(hours=duration) + timedelta(days=1) for day in days])

    met_days = [min_day + timedelta(days=i) for i in range((max_day - min_day).days + 1)]
    met_days_str = [day.strftime("%Y%m%d") for day in met_days]

    return [f"{prefix}{day}{suffix}" for day in met_days_str]








def get_met_files(files, path_met_files, ftp_dir):
    files_in_path = os.listdir(path_met_files)

    if files is not None:
        for file in files:
            if file not in files_in_path:
                url = os.path.join(ftp_dir, file)
                destfile = os.path.expanduser(os.path.join(path_met_files, file))
                
                with urlopen(url) as response:
                    if response.status == 200:
                        with open(destfile, 'wb') as f:
                            chunk = response.read(8192)
                            while chunk:
                                f.write(chunk)
                                chunk = response.read(8192)

    return files







def get_traj_output_filename(traj_name, site, direction, year, month, day, hour, lat, lon, height, duration):
    lat_str = str(lat).replace(".", "p")
    lon_str = str(lon).replace(".", "p")
    
    filename = f"traj-{traj_name}-" if traj_name else ""
    filename += f"{direction}-"
    filename += f"{year}-{month:02d}-{day:02d}-{hour:02d}-"
    filename += f"{site}-lat_{lat_str}_lon_{lon_str}-"
    filename += f"hgt_{height}-{duration}h"
    
    return filename


def get_disp_output_filename(disp_name, direction, year, month, day, hour, lat, lon, height, duration):
    lat_str = str(lat).replace(".", "p")
    lon_str = str(lon).replace(".", "p")
    
    filename = f"disp-{disp_name}-" if disp_name else ""
    filename += f"{direction}-"
    filename += f"{year}-{month}-{day}-{hour}-"
    filename += f"lat_{lat_str}_lon_{lon_str}-"
    filename += f"hgt_{height}-{duration}h"
    
    return filename


def get_receptor_values(receptors_tbl, receptor_i):
    receptor_values = receptors_tbl.iloc[receptor_i].to_dict()
    return receptor_values





def tidy_gsub(x, pattern, replacement, fixed=False):
    if fixed:
        return x.replace(pattern, replacement)
    else:
        return re.sub(pattern, replacement, x)
    
    
    


def tidy_sub(x, pattern, replacement, fixed=False):
    if fixed:
        return x.replace(pattern, replacement, 1)
    else:
        return re.sub(pattern, replacement, x, 1)
    
    



def tidy_grepl(x, pattern):
    return np.vectorize(lambda p: bool(re.search(p, x)))(pattern)


def traj_output_files():
    return [
        "ASCDATA.CFG",
        "CONTROL",
        "MESSAGE",
        "SETUP.CFG",
        "TRAJ.CFG",
        "WARNING"
    ]

def disp_output_files():
    return [
        "ASCDATA.CFG",
        "CONC.CFG",
        "CONTROL",
        "MESSAGE",
        "output.bin",
        "PARDUMP",
        "SETUP.CFG",
        "VMSDIST",
        "WARNING"
    ]



        

# -------------------------------------------------------------------------------------------------------------------
        
        
        
def write_disp_control_file(start_day, start_year_GMT, start_month_GMT,
                            start_day_GMT, start_hour, lat, lon, height,
                            direction, duration, vert_motion, model_height,
                            met_files, species, output_filename, system_type,
                            met_dir, exec_dir):
    
    start_block = (
        f"{start_year_GMT} {start_month_GMT} {start_day_GMT} {start_hour}\n"
        f"1\n"
        f"{lat} {lon} {height}\n"
        f"{'-' if direction == 'backward' else ''}{duration}\n"
        f"{vert_motion}\n"
        f"{model_height}\n"
        f"{len(met_files)}\n"
        '\n'.join([f"{met_dir}/\n{met_file}" for met_file in met_files]) + '\n\n'
    )
    
    release_duration = (species['release_end'] - species['release_start']).seconds
    
    emission_block = (
        f"1\n"
        f"{species['name'][:4]}\n"
        f"{species['rate']}\n"
        f"{release_duration}\n"
        f"{species['release_start'].strftime('%y-%m-%d %H %M')} 00\n"
    )
    
    end_year_GMT = species['release_end'].strftime('%y')
    end_month_GMT = species['release_end'].strftime('%m')
    end_day_GMT = species['release_end'].strftime('%d')
    
    grid_block = (
        f"1\n"
        f"0.0 0.0\n"
        f"0.01 0.01\n"
        f"180 360\n"
        f"./\n"
        f"output.bin\n"
        f"1\n"
        f"0.0\n"
        f"{start_year_GMT} {start_month_GMT} {start_day_GMT} {start_hour} 00\n"
        f"{end_year_GMT} {end_month_GMT} {end_day_GMT} 23 00\n"
        f"00 01 00\n"
    )
    
    species_block = (
        f"1\n"
        f"{species['pdiam']} {species['density']} {species['shape_factor']}\n"
        f"{species['ddep_vel']} {species['ddep_mw']} {species['ddep_a_ratio']} {species['ddep_d_ratio']} {species['ddep_hl_coeff']}\n"
        f"{species['wdep_hl_coeff']} {species['wdep_in_cloud']} {species['wdep_below_cloud']}\n"
        f"{species['rad_decay']}\n"
        f"{species['resuspension']}\n"
    )
    
    with open(os.path.join(exec_dir, "CONTROL"), "w") as control_file:
        control_file.write(start_block + emission_block + grid_block + species_block)

        
        
# -------------------------------------------------------------------------------------------------------------------




def get_met_edas40(files=None, years=None, months=None, path_met_files=None):
    edas40_dir = "ftp://arlftp.arlhq.noaa.gov/archives/edas40/"

    # Download the 'listing' file from NOAA server
    # It contains a list of EDAS40 files currently
    # available on the server
    listing_url = edas40_dir + "listing"
    response = requests.get(listing_url)
    
    if path_met_files is None:
        path_met_files = ""

    edas40_listing = response.text.splitlines()

    edas40_listing = [line.replace(" ", "") for line in edas40_listing]

    if years is not None:
        if len(years) > 1:
            years = list(range(years[0], years[1] + 1))

        years = [str(year)[2:4] for year in years]

        edas40_file_list = []
        for year in years:
            edas40_file_list.extend([
                item for item in edas40_listing if f"{year.lower()}" in item
            ])

    if months is not None:
        months_3_letter = [
            "jan", "feb", "mar", "apr", "may", "jun",
            "jul", "aug", "sep", "oct", "nov", "dec"
        ]

        edas40_file_list_month = []
        for month in months:
            edas40_file_list_month.extend([
                item for item in edas40_file_list if f"edas.{months_3_letter[month - 1]}" in item
            ])

        edas40_file_list = edas40_file_list_month

    if files is not None:
        edas40_file_list = files

    for file in edas40_file_list:
        file_url = edas40_dir + file
        response = requests.get(file_url)
        with open(path_met_files + file, "wb") as f:
            f.write(response.content)




# -------------------------------------------------------------------------------------------------------------------



def get_met_era5(days, duration, direction, path_met_files):
    file_list = get_daily_filenames(
        days=days,
        duration=duration,
        direction=direction,
        suffix=".ARL",
        prefix="ERA5_"
    )
    
    
# -------------------------------------------------------------------------------------------------------------------



def get_met_forecast_nam(path_met_files):
    # Establish which forecast dirs are currently available on the server
    response = requests.get("ftp://arlftp.arlhq.noaa.gov/forecast/")
    forecast_dirs = [
        dir_name for dir_name in response.text.splitlines() if dir_name.isdigit()
    ]

    # Get today's date and write in format equivalent to FTP directories
    today = str.replace(str(date.today()), '-', '')

    # Download today's `namf` file
    # -- CONUS, 12 km, 3 hrly, pressure levels, 48 h forecast
    if today in forecast_dirs:
        url = f"ftp://arlftp.arlhq.noaa.gov/forecast/{today}/hysplit.t00z.namf"
        destfile = os.path.join(path_met_files, f"{today}.t00z.namf")
        
        response = requests.get(url)
        with open(destfile, 'wb') as f:
            f.write(response.content)
            
            
    
# -------------------------------------------------------------------------------------------------------------------



def get_met_gdas0p5(days, duration, direction, path_met_files):
    daily_filenames = get_daily_filenames(
        days=days,
        duration=duration,
        direction=direction,
        suffix="_gdas0p5"
    )
    
    get_met_files(
        files=daily_filenames,
        path_met_files=path_met_files,
        ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/gdas0p5"
    )

   
 
# -------------------------------------------------------------------------------------------------------------------


def get_met_gdas1(days, duration, direction, path_met_files):

    # Determine the minimum date (as a `Date`) for the model run
    if direction == "backward":
        min_date = (days[0] - timedelta(hours=duration))
    elif direction == "forward":
        min_date = days[0]

    min_date = min_date.replace(hour=0, minute=0, second=0, microsecond=0)

    # Determine the maximum date (as a `Date`) for the model run
    if direction == "backward":
        max_date = days[-1]
    elif direction == "forward":
        max_date = (days[-1] + timedelta(hours=duration))

    max_date = max_date.replace(hour=0, minute=0, second=0, microsecond=0)

    met_days = [(min_date + timedelta(days=i)).day for i in range((max_date - min_date).days + 1)]

    os_for_locale = get_os()  # Assuming get_os function exists
    if os_for_locale == "win":
        month_names = [min_date.strftime("%b").lower() for _ in range(len(met_days))]
    else:
        month_names = [calendar.month_abbr[min_date.month].lower() for _ in range(len(met_days))]

    met_years = [str(min_date.year)[2:] for _ in range(len(met_days))]

    met_week = [(day - 1) // 7 + 1 for day in met_days]

    files = list(set(["gdas1." + month + year + ".w" + str(week) for month, year, week in zip(month_names, met_years, met_week)]))

    # Assuming get_met_files function exists
    get_met_files(files=files, path_met_files=path_met_files, ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/gdas1")



# -------------------------------------------------------------------------------------------------------------------

def get_met_gfs0p25(days, duration, direction, path_met_files):
    daily_filenames = get_daily_filenames(
        days=days, 
        duration=duration, 
        direction=direction, 
        suffix="_gfs0p25")
    
    get_met_files(
        files=daily_filenames, 
        path_met_files=path_met_files,         
        ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/gfs0p25")
    
    
# -------------------------------------------------------------------------------------------------------------------




def get_met_hrrr(files=None, path_met_files=None):
    ftp_dir = "ftp://arlftp.arlhq.noaa.gov/pub/archives/hrrr/"
    
    if files is not None:
        for file in files:
            url = os.path.join(ftp_dir, file)
            destfile = os.path.join(path_met_files, file)
            
            response = requests.get(url, stream=True)
            if response.status_code == 200:
                with open(destfile, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                print(f"Downloaded {file} successfully.")
            else:
                print(f"Failed to download {file}. Status code: {response.status_code}")
                

# -------------------------------------------------------------------------------------------------------------------

def get_met_nam12(days, duration, direction, path_met_files):
    daily_filenames = get_daily_filenames(
        days=days, 
        duration=duration, 
        direction=direction, 
        suffix="_nam12")
    
    get_met_files(
        files=daily_filenames, 
        path_met_files=path_met_files,         
        ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/nam12")



# -------------------------------------------------------------------------------------------------------------------

def get_met_narr(days, duration, direction, path_met_files):
    daily_filenames = get_monthly_filenames(
        days=days, 
        duration=duration, 
        direction=direction, 
        prefix="NARR")
    
    get_met_files(
        files=daily_filenames, 
        path_met_files=path_met_files,         
        ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/narr")


# -------------------------------------------------------------------------------------------------------------------

def get_met_reanalysis(days, duration, direction, path_met_files):
    daily_filenames = get_monthly_filenames(
        days=days, 
        duration=duration, 
        direction=direction, 
        prefix="RP",
        extension=".gbl")
    
    get_met_files(
        files=daily_filenames, 
        path_met_files=path_met_files,         
        ftp_dir="ftp://arlftp.arlhq.noaa.gov/archives/reanalysis")

    
# -------------------------------------------------------------------------------------------------------------------

def download_met_files(met_type,days,duration,direction,met_dir):
    
    if met_type == "gdas1":
        met_files=get_met_gdas1(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
    if met_type=="gdas0.5":
        met_files=get_met_gdas0p5(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
            
    if met_type=="gfs0.25":
        met_files=get_met_gfs0p25(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
    if met_type=="reanalysis":
        met_files=get_met_reanalysis(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
    if met_type=="nam12":
        met_files=get_met_nam12(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
    if met_type=="narr":
        met_files=get_met_narr(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
    
    if met_type=="era5":
        met_files=get_met_era5(
            days=days,
            duration=duration,
            direction=direction,
            path_met_files=met_dir
        )
        
    return met_files
    
    

def download_met_files(met_type,start_time,end_time,dest_folder):
    
    if met_type=="reanalysis":
        
        ftp_url = "ftp://arlftp.arlhq.noaa.gov/archives/reanalysis"
        
        try:

            diff_time=end_time-start_time

            days2=[]

            for x in range(diff_time.days):
                days1=start_time+timedelta(x)
                days2.append("RP"+str(days1).replace("-","")[:6]+".gbl")

            filesx=set(days2)
    
            
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


                # Download files to the destination folder
                for file in files:
                    if file in filesx:

                        local_filepath = os.path.join(dest_folder, file)
                        with open(local_filepath, "wb") as local_file:
                            ftp.retrbinary("RETR " + file, local_file.write)

                        print(f"Downloaded: {file}")

                print("Download completed successfully.")
                
                return filesx

        except Exception as e:
            print("An error occurred:", str(e))

# -------------------------------------------------------------------------------------------------------------------



def hysplit_dispersion(lat=49.263,
                       lon=-123.250,
                       height=50,
                       start_day=datetime(2015,7,3),
                       end_day=datetime(2015,7,5),
                       start_hour=0,
                       duration=24,
                       direction="forward",
                       met_type="reanalysis",
                       vert_motion=0,
                       model_height=20000,
                       particle_num=2500,
                       particle_max=10000,
                       species=None,
                       disp_name=None,
                       binary_path=None,
                       binary_name=None,
                       exec_dir=None,
                       met_dir=None,
                       softrun=None,
                       clean_up=True):
    
    # If the execution dir isn't specified, use the working directory
    if exec_dir is None:
        exec_dir = os.getcwd()
    
    # If the meteorology dir isn't specified, use the working directory
    if met_dir is None:
        met_dir = os.getcwd()
    
    # Set the path for the binary file. Defaults to "hycs_std"
    if binary_name is None:
        binary_name = "hycs_std"
    
    hycs_std_binary_path = set_binary_path(binary_path, binary_name)
    parhplot_binary_path = set_binary_path(binary_path, "parhplot")
    
    # Get the system type
    system_type = get_os()
    
    # Download any necessary meteorological data files
    # and return a list of all files required
    
    met_files = download_met_files(met_type, start_day, end_day, met_dir)
    
    recep_file_path_stack = []
    
    # Write default versions of the SETUP.CFG and
    # ASCDATA.CFG files in the working directory
    hysplit_config_init(exec_dir)
    
    # Modify numbers of particles in the SETUP.CFG file
    setup_cfg_path = os.path.join(exec_dir, "SETUP.CFG")
    with open(setup_cfg_path, "r") as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines):
        if " numpar =" in line:
            lines[i] = re.sub(r" numpar = \d+", f" numpar = {particle_num}", line)
        elif " maxpar =" in line:
            lines[i] = re.sub(r" maxpar = \d+", f" maxpar = {particle_max}", line)
    
    with open(setup_cfg_path, "w") as f:
        f.writelines(lines)
    
    # Define starting time parameters
    start_year_GMT = to_short_year(str(start_day))
    start_month_GMT = to_short_month(str(start_day))
    start_day_GMT = to_short_day(str(start_day))
    
    # Format `start_hour` if given as a numeric value
    if isinstance(start_hour, (int, float)):
        start_hour = str(int(start_hour)).zfill(2)
    
    if int(start_year_GMT) > 40:
        full_year_GMT = f"19{start_year_GMT}"
    else:
        full_year_GMT = f"20{start_year_GMT}"
    
    # Construct the output filename string for this model run
    output_filename = get_disp_output_filename(disp_name, direction, start_year_GMT,
                                               start_month_GMT, start_day_GMT, start_hour,
                                               lat, lon, height, duration)
    
    write_disp_control_file(start_day, start_year_GMT, start_month_GMT, start_day_GMT,
                            start_hour, lat, lon, height, direction, duration, vert_motion,
                            model_height, met_files, species, output_filename, system_type,
                            met_dir, exec_dir)
    
    # The CONTROL file is now complete and in the working directory,
    # so execute the model run
    sys_cmd = f"(cd \"{exec_dir}\" && \"{hycs_std_binary_path}\" {to_null_dev(system_type)})"
    
    if softrun is False:
        execute_on_system(sys_cmd, system_type)
    
    # Extract the particle positions at every hour
    sys_cmd = f"(cd \"{exec_dir}\" && \"{parhplot_binary_path}\" -iPARDUMP -a1 {to_null_dev(system_type)})"
    
    if softrun is False:
        execute_on_system(sys_cmd, system_type)
    
    dispersion_tbl = None
    
    if softrun is False:
        dispersion_file_list = [file for file in os.listdir(exec_dir) if re.match(r"^GIS_part_[0-9][0-9][0-9]_ps.txt$", file)]
        
        dispersion_tbl = pd.DataFrame(columns=["particle_i", "hour", "lat", "lon", "height"])
        
        for file in dispersion_file_list:
            hour_index = int(re.sub(r".*GIS_part_([0-9][0-9][0-9])_ps.*", "\\1", file))
            disp_tbl = pd.read_csv(os.path.join(exec_dir, file), names=["particle_i", "lon", "lat", "height"], comment="END")
            disp_tbl["hour"] = hour_index
            dispersion_tbl = pd.concat([dispersion_tbl, disp_tbl], ignore_index=True)
    
    if clean_up:
        file_list = [file for file in os.listdir(exec_dir) if re.match(r"^.*$", file)]
        for file in file_list:
            os.unlink(os.path.join(exec_dir, file))
    
    return dispersion_tbl


# -------------------------------------------------------------------------------------------------------------------


class DispersionModel:
    def __init__(self):
        self.start_time = None
        self.end_time = None
        self.direction = "forward"
        self.met_type = None
        self.sources = None
        self.vert_motion = 0
        self.model_height = 20000
        self.disp_df = None


        
def create_dispersion_model(**kwargs):
    
    disp_model = DispersionModel()
    
    if "start_time" in kwargs:
        
        if type(kwargs["start_time"])==datetime.date:
            disp_model.start_time = kwargs["start_time"]
        else:
            raise ValueError('The variable "start_time" must be a "datetime.date" object')
        
        
    if "end_time" in kwargs:
        
        if type(kwargs["end_time"])==datetime.date:
            disp_model.end_time = kwargs["end_time"]
        else:
            raise ValueError('The variable "end_time" must be a "datetime.date" object')
    
    
    if "direction" in kwargs:
        if kwargs["direction"] in ["forward","backward"]:
            disp_model.direction = kwargs["direction"]
        else:
            raise ValueError('The variable "direction" must be a "str" object and it only can be "forward" or "backward"')
    
    
    if "met_type" in kwargs:
        if kwargs["met_type"] in ["gdas1","reanalysis","narr"]:
            disp_model.met_type = kwargs["met_type"]
        else:
            raise ValueError('The variable "met_type" must be a "str" object and it only can be "gdas1", "reanalysis","narr"')
    
    
    if "sources" in kwargs:
        disp_model.sources = kwargs["sources"]
    
    
    if "vert_motion" in kwargs:
        disp_model.vert_motion = kwargs["vert_motion"]
    
    
    if "model_height" in kwargs:
        disp_model.model_height = kwargs["model_height"]
    
    return disp_model



# -------------------------------------------------------------------------------------------------------------------



def add_source(model, name=None, lat=None, lon=None, height=None,
               release_start=None, release_end=None, rate=None,
               pdiam=None, density=None, shape_factor=None,
               ddep_vel=None, ddep_mw=None, ddep_a_ratio=None,
               ddep_d_ratio=None, ddep_hl_coeff=None, wdep_hl_coeff=None,
               wdep_in_cloud=None, wdep_below_cloud=None, rad_decay=None,
               resuspension=None):
    
    if any(item is None for item in (lat, lon, height)):
        raise ValueError("The 'lat', 'lon', and 'height' values must be provided.")
    
    if name is None:
        name = None
    
    if release_start is None:
        release_start = "1900-01-01 00:00:00"
    
    if release_end is None:
        release_end = "1900-01-01 00:00:00"
    
    arg_names = ["name", "lat", "lon", "height", "release_start", "release_end",
                 "rate", "pdiam", "density", "shape_factor", "ddep_vel",
                 "ddep_mw", "ddep_a_ratio", "ddep_d_ratio", "ddep_hl_coeff",
                 "wdep_hl_coeff", "wdep_in_cloud", "wdep_below_cloud",
                 "rad_decay", "resuspension"]
    
    species_vals = locals()
    
    species_defaults = [5, 15.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    
    missing_values = [item is None for item in species_vals.values()]
    
    species_vals = [default if missing else val for val, default, missing
                    in zip(species_vals.values(), species_defaults, missing_values)]
    
    dispersion_source_line = pd.DataFrame({
        "name": [name],
        "lat": [lat],
        "lon": [lon],
        "height": [height],
        "release_start": [release_start],
        "release_end": [release_end],
        "rate": [rate],
        "pdiam": [pdiam],
        "density": [density],
        "shape_factor": [shape_factor],
        "ddep_vel": [ddep_vel],
        "ddep_mw": [ddep_mw],
        "ddep_a_ratio": [ddep_a_ratio],
        "ddep_d_ratio": [ddep_d_ratio],
        "ddep_hl_coeff": [ddep_hl_coeff],
        "wdep_hl_coeff": [wdep_hl_coeff],
        "wdep_in_cloud": [wdep_in_cloud],
        "wdep_below_cloud": [wdep_below_cloud],
        "rad_decay": [rad_decay],
        "resuspension": [resuspension]
    })
    
    if model.sources is None:
        model.sources = dispersion_source_line
    else:
        model.sources = pd.concat([model.sources, dispersion_source_line])
    
    return model


# -------------------------------------------------------------------------------------------------------------------


def add_dispersion_params(model,
                          start_time=None,
                          end_time=None,
                          direction=None,
                          met_type=None,
                          vert_motion=None,
                          model_height=None,
                          exec_dir=None,
                          met_dir=None,
                          binary_path=None,
                          binary_name=None,
                          softrun=False,
                          clean_up=True):
    
    if start_time is not None:
        model.start_time = start_time
    
    if end_time is not None:
        model.end_time = end_time
    
    if direction is not None:
        model.direction = direction
    
    if met_type is not None:
        model.met_type = met_type
    
    if vert_motion is not None:
        model.vert_motion = vert_motion
    
    if model_height is not None:
        model.model_height = model_height
    
    if exec_dir is not None:
        model.exec_dir = exec_dir
    
    if met_dir is not None:
        model.met_dir = met_dir
    
    if binary_path is not None:
        model.binary_path = binary_path
        
    if binary_name is not None:
        model.binary_name = binary_name
    
    if softrun is not None:
        model.softrun = softrun
    
    if clean_up is not None:
        model.clean_up = clean_up
    
    return model

# -------------------------------------------------------------------------------------------------------------------


def add_emissions(model, rate=None, duration=None, start_day=None, start_hour=None, name=None):
    if name is None:
        if model.emissions is None:
            name = "emissions_1"
        else:
            name = f"emissions_{model.emissions.shape[0] + 1}"
    
    if rate is None:
        rate = 1
    
    if duration is None:
        duration = 1
    
    if start_day is None:
        start_day = "10-05-01"
    
    if start_hour is None:
        start_hour = 0
    
    # Write emissions parameters to a dictionary
    emissions = {
        "name": name,
        "rate": rate,
        "duration": duration,
        "start_day": start_day,
        "start_hour": start_hour
    }
    
    # Write dictionary to the 'emissions' list component of 'model'
    if model.emissions is None:
        model.emissions = pd.DataFrame([emissions])
    else:
        emissions_df = pd.DataFrame([emissions])
        model.emissions = pd.concat([model.emissions, emissions_df], ignore_index=True)
    
    return model




# -------------------------------------------------------------------------------------------------------------------




def run_model(model):


    # Get time window for observations
    start_day = model.start_time.date()
    end_day = model.end_time.date()
    
    start_hour = model.start_time.hour
    duration = (model.end_time - model.start_time).total_seconds() / 3600

    # Get ith source parameters
    lat = model.sources['lat'][0]
    lon = model.sources['lon'][0]
    height = model.sources['height'][0]

    release_start = model.sources['release_start'][0]
    release_end = model.sources['release_end'][0]

    rate = model.sources['rate'][0]


    species_list={}

    for x in disp_model.sources.columns:
        species_list[x]=disp_model.sources[x][0]

    disp_df = hysplit_dispersion(
        lat=lat,
        lon=lon,
        height=height,
        start_day=start_day,
        end_day=end_day,
        start_hour=start_hour,
        duration=duration,
        direction="forward",
        met_type=model.met_type,
        vert_motion=model.vert_motion,
        model_height=model.model_height,
        particle_num=2500,
        particle_max=10000,
        species=species_list,
        exec_dir=model.exec_dir,
        met_dir=model.met_dir,
        binary_path=None,
        binary_name=None,
        softrun=model.softrun,
        clean_up=model.clean_up
    )

    model.disp_df = disp_df

    return model




disp_model = DispersionModel()

# Agregar fuente al modelo
disp_model = add_source(disp_model, name="particle", lat=49.0, lon=-123.0, height=50,
                        release_start=datetime.strptime("2015-07-01 00:00", "%Y-%m-%d %H:%M"), release_end=datetime.strptime("2015-07-01 02:00", "%Y-%m-%d %H:%M"))

# Agregar parámetros de dispersión al modelo
disp_model = add_dispersion_params(disp_model, 
                                   start_time=datetime.strptime("2015-07-01 00:00", "%Y-%m-%d %H:%M"),
                                   end_time=datetime.strptime("2015-07-01 06:00", "%Y-%m-%d %H:%M"),
                                   direction="forward", 
                                   met_type="reanalysis",
                                   met_dir="C:/Users/matia/Documents/dispersion_model/met",
                                   exec_dir="C:/Users/matia/Documents/dispersion_model/out")

disp_model = run_model(disp_model)