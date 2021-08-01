import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
#from wordcloud import WordCloud, STOPWORDS
#from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

#import nltk
import itertools
import collections
# from nltk import bigrams


import networkx as nx

import sys
# print(sys.executable)
# print(sys.version)
# print(sys.version_info)

tweets=pd.read_csv("JWC_alltweets1.csv")

print(tweets)