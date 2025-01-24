import os
import pandas as pd

# Input file path
input_file = "/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/dyslexia/dys-sumstats.txt"

# Output directory
output_dir = "/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/dyslexia/preprocessed"

# Output file path
output_file = os.path.join(output_dir, "dys-sumstats-preprocessed-python.txt")

# Create the output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Load the input file into a pandas DataFrame, handling space-separated values
print('reading input file...')
df = pd.read_csv(input_file, delim_whitespace=True)
print('input dataframe created')

# Print the actual column names to check for any discrepancies
print("Columns in the file:", df.columns)

# Strip any leading or trailing whitespace from column names
df.columns = df.columns.str.strip()

# Rename columns for output format (adjust these lines if column names differ)
if 'a1' in df.columns and 'a0' in df.columns:
    df['A1'] = df['a1']
    df['A2'] = df['a0']
    print('renamed a1>A1 and a0>A2')
else:
    # If the column names are different, print a message and exit
    print("Error: Expected columns 'a1' and 'a0' not found.")
    exit(1)

# Select relevant columns: SNP (rsid), A1 (effect allele), A2 (non-effect allele), BETA, P
if 'rsid' in df.columns and 'beta' in df.columns and 'pval' in df.columns:
    print('creating output dataframe')
    output_df = df[['rsid', 'A1', 'A2', 'beta', 'pval']]
    print('created output dataframe')
else:
    # If the expected columns are not found, print a message and exit
    print("Error: Expected columns 'rsid', 'beta', or 'pval' not found.")
    exit(1)

# Rename columns for consistency
output_df.columns = ['SNP', 'A1', 'A2', 'BETA', 'P']
print('renamed other column')

# Save the processed DataFrame to a file
output_df.to_csv(output_file, sep='\t', index=False)

print(f"Data has been processed and saved to: {output_file}")

