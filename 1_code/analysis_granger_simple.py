import pandas as pd
import os
import numpy as np
from statsmodels.tsa.stattools import grangercausalitytests
from statsmodels.tsa.api import VAR

# # Get the current script directory and create paths to the data and output folders
script_dir = os.path.dirname(os.path.abspath(__file__))
data_folder_path = os.path.join(script_dir, '..', '0_data')
pipeline_folder_path = os.path.join(script_dir, '..', '2_pipeline/preprocessed')
pipeline_out_folder_path = os.path.join(script_dir, '..', '2_pipeline/out')
tmp_folder_path = os.path.join(script_dir, '..', '2_pipeline/tmp')
output_folder_path = os.path.join(script_dir, '..', '3_output/results/granger')
df = pd.read_csv(os.path.join(pipeline_out_folder_path, 'merged.csv'))

df['positive'] = df['old_positive'] - df['young_positive']
df['negative'] = df['old_negative'] - df['young_negative']
df['competent'] = df['old_competent'] - df['young_competent']
df['warm'] = df['old_warm'] - df['young_warm']
df['incompetent'] = df['old_incompetent'] - df['young_incompetent']
df['unwarm'] = df['old_unwarm'] - df['young_unwarm']
df['virtue'] = df['old_virtue'] - df['young_virtue']
df['vice'] = df['old_vice'] - df['young_vice']
df['indicoll'] = df['indi'] - df['coll']
df['tightloose'] = df['tight'] - df['loose']
# df['gdp_per_capita_log'] = np.log(df['GDP.per.capita'])
df = df.set_index('year')

dvs = ['positive', 'negative', 'competent', 'warm', 'incompetent', 'unwarm', 'virtue', 'vice']
ivs = ['indi','coll','indicoll', 'tight','loose', 'tightloose']



def calculate_aic(data, maxlag):
    """
    Calculates the AIC values for a VAR model with different numbers of lags.
    :param data: DataFrame with time series data.
    :param maxlag: Maximum number of lags to use.
    :return: List of AIC values.
    """
    model = VAR(data)
    aic_values = []
    for i in range(1, maxlag+1):
        result = model.fit(i)
        aic_values.append(result.aic)
    return aic_values
def granger_test(df, dvs, ivs, maxlagnum=10):
    """
    Performs a Granger causality test on each combination of dependent and independent variables.
    :param dvs: List of dependent variables.
    :param ivs: List of independent variables.
    :param maxlagnum: Maximum number of lags to use.
    :return: DataFrame with significant results.
    """
    results_dict = {
        "Direction": [],
        "Lag": [],
        "F-statistic": [],
        "p-value": [],
        "AIC": []
    }
    for dv in dvs:
        for iv in ivs:
            data = pd.concat([df[dv], df[iv]], axis=1)
            data = data.dropna(how='any', axis=0)  # Drops rows with missing values.
            aic_values = calculate_aic(data, maxlagnum)
            gc_res = grangercausalitytests(data, maxlag=maxlagnum, verbose=False)
            for lag, test_results in gc_res.items():
                f_statistic = test_results[0]['ssr_ftest'][0]
                p_value = test_results[0]['ssr_ftest'][1]
                results_dict['Direction'].append(iv + ' -> ' + dv)
                results_dict['Lag'].append(lag)
                results_dict['F-statistic'].append(f_statistic)
                results_dict['p-value'].append(p_value)
                results_dict['AIC'].append(aic_values[lag-1])  # Indexing starts from 0, lag starts from 1.
    results_df = pd.DataFrame(results_dict)
    # Get the row with minimum AIC for each direction
    results_df = results_df.loc[results_df.groupby("Direction")["AIC"].idxmin()]
    # Filter DataFrame to only include significant results
    significant_results_df = results_df[results_df['p-value'] < 0.05]
    return significant_results_df

iv_predict_dv = granger_test(df,dvs,ivs,10)
dv_predict_iv = granger_test(df,ivs,dvs,10)


iv_predict_dv.to_csv(os.path.join(output_folder_path,'iv_predict_dv_simple.csv'))
dv_predict_iv.to_csv(os.path.join(output_folder_path,'dv_predict_iv_simple.csv'))