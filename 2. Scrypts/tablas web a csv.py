# -*- coding: utf-8 -*-
"""
Created on Thu Sep  2 13:26:06 2021

@author: canun
"""

import pandas as pd
import requests
import os


url = "https://www.tiobe.com/tiobe-index/"

html = requests.get(url).content
df_list = pd.read_html(html)

df = df_list[-1]
print(df)
df.to_csv("output.csv")