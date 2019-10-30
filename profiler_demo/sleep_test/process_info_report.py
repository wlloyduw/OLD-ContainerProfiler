import argparse
import os
import sys
import json
import copy
import ConfigParser
import pandas as pd
import time

from collections import namedtuple

parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
args= parser.parse_args()
file_path = args.file_path


dirs= [i for i in os.listdir( file_path ) if i.endswith(".csv")]
dirs.sort()
dfObj = pd.DataFrame()

used_count = []
for file_name in dirs:
	with open(file_path + '/' + file_name) as csv_file: 
		data_frame = pd.read_csv(csv_file)
		data_frame.head()
		
		series=data_frame.mean()
		series = series.rename(file_name)

		dfObj = dfObj.append(series)
		used_count.append(len(data_frame.index))
	

dfObj.insert(len(dfObj.columns) ,'Times Used', used_count)
dfObj.sort_values(by='Times Used', ascending=False)
dfObj.to_csv("process_info.csv", sep=',')



