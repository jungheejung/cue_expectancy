import pandas as pd

# Specify the path to the input TSV file
input_file = 'path/to/input/file.tsv'

# Specify the path to the output TSV file
output_file = 'path/to/output/file.tsv'

# Read the input TSV file into a DataFrame
df = pd.read_csv(input_file, delimiter='\t')

# Remove trailing spaces from all columns
df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# Save the updated DataFrame to a new TSV file
df.to_csv(output_file, sep='\t', index=False)

# Print a message indicating the process is complete
print("Trailing spaces removed and saved to", output_file)