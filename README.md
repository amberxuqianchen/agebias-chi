# Age Bias in People's Daily

This repository contains Python scripts for analyzing word embeddings for age bias in text data. It computes cosine similarities and embedding bias between target words and evaluative words and includes visualizations of the results.

## Abstract
**Background and Objectives**: Older adults have been traditionally portrayed to be respected in China. However, findings have been mixed on contemporary Chinese attitudes towards the older adults, especially the holistic changes amidst socio-economic transformation and an aging population that occurred in recent decades. Addressing this gap, our study investigates the holistic evolution of societal attitudes towards older age groups, as reflected in narratives from the People’s Daily Newspaper (Renmin Ribao) from 1950 to 2021
**Research Design and Methods**: Societal attitudes were measured with three metrics: moral judgment (virtue versus vice), ageist evaluations (positive versus negative), and stereotypes (warmth versus competence). Natural language processing was used to quantify how specific attitude-related words became more closely associated with older adults compared to younger adults over time, referred to as age bias.  Time series models and granger tests were applied to examine the association and precedence between cultural values and age bias. 
**Results**: The semantic age bias has become more negative after Chinese economic reform. The results of time series models identified a positive relationship between collectivistic values and Warmth Bias in China after accounting for GDP per capita, while concurrent positive correlations of both cultural tightness and looseness with Virtue Bias and Warmth Bias were observed. Granger test results show that the shifts in changes in cultural looseness can positively precede changes in Positive Bias.
Discussion and Implications****: This is the first known study longitudinally exploring societal attitudes towards older age groups in China with natural language processing methods. Our findings highlight the significance of the temporal dynamics of societal attitudes along with cultural changes.
**Keywords**: Societal attitudes,  Stereotype, Culture, Natural Language Processing

## How to use
To run the project, follow these steps:

1. Make sure you have the necessary dependencies installed (pandas, gensim, numpy and others mentioned in the import section of each file).
2. Download trained Word2Vec models from OSF resipotory (upon request) and place all files under `0_data/model` folder.
3. Run main.py to compute cosine similarities using word2vec models and save the results as a CSV file.
4. Adjust the target words, foundational words and word2vec models as needed and re-run main.py to update the results based on your specific requirements.

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
- 3_output: contains final output files intended to go into the paper, including statistical results and figures.
- 4_docs: appendix, notes, papers, etc.

### Additional Principles
- Load data only from 0_data or out folders in 2_pipeline. 
- Load data only from out folders belonging to code files that are executed before the current code file.
- Set the working directory to the top-level project folder to use relative path.
- Checkout the [collaboration tips](https://github.com/amberxuqianchen/lab-general/blob/main/Git/git_collaboration_tips.md).
