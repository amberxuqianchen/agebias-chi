import os
import json
import glob
from gensim.models import Word2Vec
import pandas as pd
import numpy as np

def load_dict(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        foundations = json.load(f)
    return foundations

def load_word2vec_models(model_folder_path: str):
    models = {}
    for year in range(1950, 2022):
        model_path = os.path.join(model_folder_path, f'pd_{year}.model')
        models[year] = Word2Vec.load(model_path)
    return models

def calculate_cosine_similarities(models, targets, foundations):
    similarities = {}
    for year, model in models.items():
        similarities[year] = {}
        for target_name, target_words in targets.items():
            similarities[year][target_name] = {}
            for foundation_name, foundation_words in foundations.items():
                filtered_target_words = [word for word in target_words if word in model.wv.key_to_index]
                filtered_foundation_words = [word for word in foundation_words if word in model.wv.key_to_index]
                try:
                    similarity = model.wv.n_similarity(filtered_target_words, filtered_foundation_words)
                except:
                    similarity = np.nan
                    print('Not found')

                similarities[year][target_name][foundation_name] = similarity
    return similarities