
import os
from extract_cosine_similarities import load_dict , load_word2vec_models, calculate_cosine_similarities
from calculate_embedding_bias import create_bias_dataframe
from plot_results import plot_results

# # Get the current script directory and create paths to the data and output folders
script_dir = os.path.dirname(os.path.abspath(__file__))
data_folder_path = os.path.join(script_dir, '..', '0_data')
pipeline_folder_path = os.path.join(script_dir, '..', '2_pipeline/preprocessed')
tmp_folder_path = os.path.join(script_dir, '..', '2_pipeline/tmp')

# Evaluations
foundations_path = os.path.join(data_folder_path, 'wordlist', 'dict_mft.json')
posneg_path = os.path.join(data_folder_path, 'wordlist', 'dict_posneg.json')
scm_path = os.path.join(data_folder_path, 'wordlist', 'dict_scm.json')

# Targets (e.g., age groups)
age_groups_path = os.path.join(data_folder_path, 'wordlist', 'age_groups.json')

foundations = load_dict(foundations_path)
posneg = load_dict(posneg_path)
scm = load_dict(scm_path)
targets = load_dict(age_groups_path)

# Models
model_folder_path = os.path.join(data_folder_path, 'model')
models = load_word2vec_models(model_folder_path)

# Change or add foundations to the dictionary here as needed
# For example:
# foundations['new_foundation_name'] = ['word1', 'word2', 'word3']

evaluations = {'foundations': foundations,  'scm': scm,'posneg': posneg}
for name, evaluations in evaluations.items():
    # Calculate cosine similarities
    similarities = calculate_cosine_similarities(models, targets, evaluations)

    # Calculate embedding bias
    dfbias = create_bias_dataframe(similarities, targets, evaluations)
    
    # Save the DataFrame as a CSV
    csv_filepath = os.path.join(pipeline_folder_path, name+ '.csv')
    dfbias.to_csv(csv_filepath, index=False)

# Plot the results
# eventyear = 1978
# eventname = "Economic Reform"
# plot_results(df_embedding_bias, targets, eventyear, eventname, str(tmp_folder_path) + "/",foundations=foundations)
