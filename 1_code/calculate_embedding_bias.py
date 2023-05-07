import pandas as pd
# from extract_cosine_similarities import load_dict, load_word2vec_models, calculate_cosine_similarities

def create_bias_dataframe(similarities: dict, targets: dict, foundations: dict) -> pd.DataFrame:
    colnames = ['year'] + [f'{target}_{foundation}' for foundation in foundations for target in targets]
    dfbias = pd.DataFrame(columns=colnames, index=range(1950, 2022))
    for year, yearly_similarities in similarities.items():
        dfbias.loc[year] = [year] + [yearly_similarities[target][foundation] for col in colnames[1:] for target, foundation in [col.split('_', 1)]]
    if any("_" in key for key in list(foundations.keys())):

        for target in targets:
            for foundation in foundations:
                domain = foundation.split('_')[0]
                dfbias[f'{target}_{domain}'] = dfbias[f'{target}_{foundation}']
            dfbias[f'{target}_virtue'] = dfbias[[f'{target}_{foundation}' for foundation in foundations if 'vir' in foundation]].mean(axis=1)
            dfbias[f'{target}_vice'] = dfbias[[f'{target}_{foundation}' for foundation in foundations if 'vic' in foundation]].mean(axis=1)
        return dfbias
    # dfbias.set_index('year', inplace=True)
    else:
        return dfbias
