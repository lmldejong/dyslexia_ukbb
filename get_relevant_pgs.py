import pandas as pd

def get_overlap_and_subset(file1, file2, file3, output_file):
    """
    Finds overlapping entries between two files using pandas, gets their row numbers,
    and subsets a third file based on those row numbers.
    """
    # Load file1 into a DataFrame
    df1 = pd.read_csv(file1, sep=" ", header=None, names=["entry", "extra"], usecols=[0])
    df1["index"] = df1.index  # Keep track of original indices

    # Load file2 into a DataFrame
    df2 = pd.read_csv(file2, header=None, names=["entry"])

    # Load file3 into a DataFrame
    df3 = pd.read_csv(file3, header=None, names=["data"])

    print(f"Length of file1: {len(df1)}")
    print(f"Length of file2: {len(df2)}")
    print(f"First 10 entries in file1:\n{df1.head(10)}")
    print(f"First 10 entries in file2:\n{df2.head(10)}")

    # Find overlaps and their indices
    merged = pd.merge(df2, df1, on="entry", how="inner")  # Inner join to get overlaps
    print(f"Number of overlapping entries: {len(merged)}")
    print(f"First 10 overlaps:\n{merged.head(10)}")

    # Subset the third file based on the indices of overlaps
    overlap_indices = merged["index"].tolist()
    subset = df3.iloc[overlap_indices]

    # Save the subsetted data to the output file
    subset.to_csv(output_file, index=False, header=False)

    print(f"Subsetted file saved to: {output_file}")
    print(f"First 10 rows of subsetted data:\n{subset.head(10)}")

def add_intercept(input_file, output_file):
    """
    Adds a second column with an intercept (all 1s) to the input file and saves the updated file.

    Args:
    - input_file (str): Path to the input text file (pgs_baseline.txt).
    - output_file (str): Path to save the updated file.
    """
    # Load the input file into a pandas DataFrame
    df = pd.read_csv(input_file, header=None, names=["pgs"], delim_whitespace=True)

    # Add an intercept column
    df["intercept"] = 1

    # Save the updated file
    df.to_csv(output_file, index=False, header=False, sep=" ")

    print(f"Updated file saved to: {output_file}")
    print(f"First 10 rows of updated file:\n{df.head(10)}")

# Example usage
get_overlap_and_subset(
    file1='/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/list-all-subjects-genetics-subid-and-indices.txt',
    file2='/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/merged_jac/baseline/covar_filt.subs',
    file3='/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/results/dyslexia_auto-cs.pgs',
    output_file='/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/pgs_baseline.txt'
)


# Example usage
add_intercept(
    input_file="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/pgs_baseline.txt",
    output_file="/data/clusterfs/lag/projects/lg-ukbiobank/projects/Lucas/data/pgs_baseline_with_intercept.txt"
)
