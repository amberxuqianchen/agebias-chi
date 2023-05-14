import pandas as pd
import glob
import os
# Specify the pattern matching for csv files
# # Get the current script directory and create paths to the data and output folders
script_dir = os.path.dirname(os.path.abspath(__file__))
pipeline_folder_path = os.path.join(script_dir, '..', '2_pipeline/preprocessed')
tmp_folder_path = os.path.join(script_dir, '..', '2_pipeline/tmp')
out_folder_path = os.path.join(script_dir, '..', '2_pipeline/out')
csv_files = glob.glob(os.path.join(pipeline_folder_path, '*.csv'))

# Create an empty list to store dataframes
dfs = []

# Read and append each csv file into the list
for csv_file in csv_files:
    df = pd.read_csv(csv_file)
    df['year'] = df['year'].astype(int)
    dfs.append(df)

# Merge DataFrames
merged_df = dfs[0]
for df in dfs[1:]:
    merged_df = pd.merge(merged_df, df, on='year', how='outer')

# Sort the merged dataframe based on 'Year'
merged_df = merged_df.sort_values('year')

# Reset index after sorting
merged_df.reset_index(drop=True, inplace=True)

# Write the merged dataframe to a new csv file
merged_df.to_csv(os.path.join(out_folder_path, 'merged.csv'), index=False)
