# Age Bias in People's Daily

This repository contains Python scripts for analyzing word embeddings for age bias in text data. It computes cosine similarities and embedding bias between target words and foundational words and includes visualizations of the results.

## How to use
To run the project, follow these steps:

1. Make sure you have the necessary dependencies installed (pandas, gensim, numpy and others mentioned in the import section of each file).
2. Run main.py to compute cosine similarities using word2vec models and save the results as a CSV file.
3. Adjust the target words, foundational words and word2vec models as needed and re-run main.py to update the results based on your specific requirements.

Additionally, you may also run other analysis scripts, such as extract_cosine_similarities.py, calculate_embedding_bias.py, and PeopleDaily_GrangerTest.py to perform relevant data analysis tasks.

| Filename                                  | Description                                                |
| ----------------------------------------- | ---------------------------------------------------------- |
| 1_code/extract_cosine_similarities.py     | Calculates cosine similarities between given target and foundational words in different yearly Word2Vec models |
| 1_code/calculate_embedding_bias.py        | Computes word biases in text and generates a bias DataFrame (Pandas DataFrame) |
| 1_code/plot_results.py                    | Creates various visualizations of word embedding analysis |
| 1_code/main.py                            | The main script for computing cosine similarities and storing results as CSV file |
| 1_code/build_null_associations.py         | [TODO]|
| 1_code/analysis/PeopleDaily_GrangerTest.py | [TODO] Performs Granger Causality Test on People's Daily dataset. |
## Project Folder Structure
The project folder is organized into several sub-folders to facilitate clear and organized data processing and analysis.

- 0_data: contains all input data retrieved from external sources or created manually. The data in this folder should remain identical to the way it was retrieved or created.
- 1_code: contains all code files for Python, and Jupyter Notebooks for exploratory analysis. The code files should be named starting with a number to indicate the order of execution.
- 2_pipeline: contains a separate sub-folder for each code file in the 1_code folder, corresponding to the name (minus the file extension). Each sub-folder should have three folders: out (final data for analysis), preprocessed, and tmp (can be deleted), to organize generated outputs.
- 3_output: contains final output files intended to go into the paper, including tables and figures.
- 4_docs: appendix, notes, papers, etc.

### Additional Principles
- Load data only from 0_data or out folders in 2_pipeline. 
- Load data only from out folders belonging to code files that are executed before the current code file.
- Set the working directory to the top-level project folder to use relative paths.
