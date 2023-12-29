import os
import pickle
import re
import gensim
from gensim.models import Word2Vec
import jieba
import argparse

# change the path to your own path
rawtext_path = '/home/local/PSYCH-ADS/xuqian_chen/YES_lab/Amber/nlp/PeopleDaily/raw_data/'
model_folder_path = '/home/local/PSYCH-ADS/xuqian_chen/YES_lab/Amber/nlp/PeopleDaily/models_tmp/'
cleanedtext_path = '/home/local/PSYCH-ADS/xuqian_chen/YES_lab/Amber/nlp/PeopleDaily/cleaned_sentences'

def split_into_sentences(text):
    # Regular expression for Chinese sentence splitting
    sentence_endings = re.compile(r'[\u3002\uff1f\uff01]+')
    list_of_sentences = []
    passages_split_by_line = text.split('\n')
    for passage in passages_split_by_line:
        sentences = sentence_endings.split(passage)
        list_of_sentences.extend(sentences)
    
    # Filter out empty sentences and strip whitespace
    cleaned_sentences = [sentence.strip() for sentence in list_of_sentences if sentence.strip()]
    return cleaned_sentences

def tokenCleaner(token):
    '''Clear token, return empty str "" if the token is bad for Chinese text.'''
    # # Keep only Chinese characters
    # new_token = re.sub(r'[^\u4e00-\u9fff]+', '', token)

    # Keep only Chinese characters, English letters and numbers
    new_token = re.sub(r'[^\u4e00-\u9fff0-9a-zA-Z]+', '', token)
    if new_token:
        return new_token
    else:
        return ""

def sen2token(sentence):
    '''Segment and clean Chinese sentence, return a list of tokens.'''
    clear_tokens = []
    word_punct_token = jieba.cut(sentence)
    for token in word_punct_token:
        token = tokenCleaner(token)
        if token:
            clear_tokens.append(token)
    return clear_tokens

def list_sen2token(text):
    sentences = split_into_sentences(text)
    alltokens = [sen2token(sentence) for sentence in sentences]
    # save cleaned sentences to pickle file
    with open(cleanedtext_path+'cleaned_'+year+'.pkl', 'wb') as f:
        pickle.dump(alltokens, f)
    return alltokens

def train_word2vec(tokenized_data, model_path):
    """
    Trains a Word2Vec model.

    Parameters:
    tokenized_data: A list of tokenized sentences containing Chinese text.
    model_path: The path to save the trained Word2Vec model.

    Returns:
    model: The trained Word2Vec model.

    Note:
    The default settings for model training are used, which include the following parameters:
    - size: The dimensionality of the word vectors (default: 100).
    - window: The maximum distance between the current and predicted word within a sentence (default: 5).
    - min_count: The minimum count of words to consider when training the model (default: 5).
    - workers: The number of worker threads to train the model (default: 3).
    - sg: The training algorithm, where 0 represents CBOW and 1 represents skip-gram (default: 0).
    - hs: Whether to use hierarchical softmax for training (default: 0).
    - negative: The number of negative samples to use for negative sampling (default: 5).
    - iter: The number of iterations over the corpus during training (default: 5).
    """
    model = Word2Vec(tokenized_data)
    model.save(model_path)
    return model

def main(year):
    
    # Load txt data
    with open(rawtext_path+'renmin+year+'.txt', 'r') as f:
        data = f.readlines()

    # Join the data into a single string
    text = ''.join(data)

    # Process the text
    tokenized_data = list_sen2token(text)

    # Train the model
    model = train_word2vec(tokenized_data, model_folder_path+'pd_'+year+'.model')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Train Word2Vec model for Chinese text.')
    parser.add_argument('year', type=int, help='The year for which the model is being trained.')
    args = parser.parse_args()
    main(args.year)
