# Age Bias in People's Daily

## Project Folder Structure
The project folder is organized into several sub-folders to facilitate clear and organized data processing and analysis.

- 0_data: contains all input data retrieved from external sources or created manually. The data in this folder should remain identical to the way it was retrieved or created.
1_code: contains all code files for Python, and (or a combination thereof). The code files should be named starting with a number to indicate the order of execution.
- 2_pipeline: contains a separate sub-folder for each code file in the 1_code folder, corresponding to the name (minus the file extension). Each sub-folder should have three folders: out (final data for analysis), preprocessed, and tmp (can be deleted), to organize generated outputs.
- 3_output: contains final output files intended to go into the paper, including tables and figures.
- 4_docs: appendix, notes, papers, etc.

### Additional Principles
- Load data only from 0_data or out folders in 2_pipeline. 
- Load data only from out folders belonging to code files that are executed before the current code file.
- Set the working directory to the top-level project folder to use relative paths.
