import pandas as pd
import os
# # Get the current script directory and create paths to the data and output folders
script_dir = os.path.dirname(os.path.abspath(__file__))
data_folder_path = os.path.join(script_dir, '..', '0_data/external')
pipeline_folder_path = os.path.join(script_dir, '..', '2_pipeline/preprocessed')
tmp_folder_path = os.path.join(script_dir, '..', '2_pipeline/tmp')

# Load the csv file
df = pd.read_csv(os.path.join(data_folder_path,'gdp-per-capita-maddison-2020.csv'))

# Extract the rows for China and for years from 1950 onwards
gdp_df = df[(df['Entity'] == 'China') & (df['Year'] >= 1950)]

# Prevalence data
prevalence_df = pd.read_csv(os.path.join(data_folder_path,'prevalence.csv'))

# Merge the two dataframes
# Assuming gdp_df and prevalence_df are your dataframes
external_df = pd.merge(gdp_df, prevalence_df, left_on='Year', right_on='year')

# Columns to drop
columns_to_drop = ["Entity", "Code", "417485-annotations", "Unnamed: 0","Year"]

# Drop the columns
external_df = external_df.drop(columns_to_drop, axis=1)

# Save the China data to a new csv file
external_df.to_csv(os.path.join(pipeline_folder_path,'external.csv') , index=False)
