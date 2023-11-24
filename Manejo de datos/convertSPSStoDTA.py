import os
import pyreadstat

# Specify the directory containing .sav files
directory_path = r"C:\Users\User\Downloads\ENDES\Data"

# List all files in the directory
files = [file for file in os.listdir(directory_path) if file.endswith(".sav")]

# Iterate through each .sav file
for file in files:
    # Construct full paths for input (.sav) and output (.dta) files
    input_file_path = os.path.join(directory_path, file)
    output_file_path = os.path.join(directory_path, file[:-4] + ".dta")

    # List of encodings to try
    encodings = ['utf-8', 'latin-1']

    for encoding in encodings:
        try:
            # Read the SPSS file with explicit encoding
            df, meta = pyreadstat.read_sav(input_file_path, encoding=encoding)

            # Save as Stata file
            df.to_stata(output_file_path, write_index=False)

            print(f"Converted {input_file_path} to {output_file_path}")
            break  # Break the loop if successful
        except pyreadstat._readstat_parser.ReadstatError as e:
            print(f"Error converting {input_file_path} with encoding {encoding}: {e}")
