import pandas as pd
import gzip
from io import StringIO

def loadDF(file_path, sheet_name=None, file_type='xlsx'):
    try:
        if file_type == 'xlsx':
            if sheet_name:
                db_file_df = pd.read_excel(file_path, sheet_name=sheet_name, engine='openpyxl')
            else:
                db_file_df = pd.read_excel(file_path)
        elif file_type == 'xls':
            if sheet_name:
                db_file_df = pd.read_excel(file_path, sheet_name=sheet_name, engine='xlrd')
            else:
                db_file_df = pd.read_excel(file_path)                
        elif file_type == 'csv':
            db_file_df = pd.read_csv(file_path)
        elif file_type == 'txt':
            db_file_df = pd.read_csv(file_path, sep = '\t')
        else:
            raise ValueError("Unsupported file type. Please use 'xlsx', 'xls', 'csv', or 'txt'")

        return db_file_df
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def save_to_excel(file_name, dfs):
    """
    Saves multiple DataFrames to an Excel file, each in a separate sheet.

    :param file_name: The name of the Excel file.
    :param dfs: A dictionary where keys are sheet names and values are DataFrames.
    """
    with pd.ExcelWriter(file_name, engine='xlsxwriter') as writer:
        for sheet_name, df in dfs.items():
            df.to_excel(writer, sheet_name=sheet_name)

def loadVCF(file_path):
    # Check if the file is gzipped
    if file_path.endswith('.gz'):
        # Open the gzipped file
        with gzip.open(file_path, 'rt') as f:
            lines = [line for line in f if not line.startswith('##')]
    else:
        # Open a regular .vcf file
        with open(file_path, 'r', encoding='ISO-8859-1') as f:
            lines = [line for line in f if not line.startswith('##')]
    
    # Use pandas to read the lines into a DataFrame
    return pd.read_csv(
        StringIO(''.join(lines)),
        sep='\t'
    )

if __name__ == "__main__":
    pass