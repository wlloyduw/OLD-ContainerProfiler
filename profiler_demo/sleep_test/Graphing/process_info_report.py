import argparse
import os
import sys
import json
import copy
import ConfigParser
import pandas as pd
import time

import os
import glob
import pandas as pd


from collections import namedtuple

parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='')
args= parser.parse_args()
file_path = args.file_path


dirs= [i for i in os.listdir( file_path ) if i.endswith(".csv")]
dirs.sort()
dfObj = pd.DataFrame()


used_count = []
pcmd_list =[]
for file_name in dirs:
	with open(file_path + '/' + file_name) as csv_file: 
		data_frame = pd.read_csv(csv_file)
		data_frame.head()
		value_counts= data_frame['pCmdLine'].value_counts()
		#df = value_counts.rename_axis('unique_values').reset_index(name='counts')
		df = pd.DataFrame(value_counts)
		pcmd_list.append(df)

		series=data_frame.median()
		series = series.rename(file_name)

		dfObj = dfObj.append(series)
		used_count.append(len(data_frame.index))

total = pcmd_list[0]
for i in pcmd_list[1:]:
	total = total.add(i, fill_value=0)


total = total.sort_values(by="pCmdLine", ascending=False)
total.to_csv("processes_used.csv", sep=',')


dfObj.insert(len(dfObj.columns) ,"Times Used", used_count)
dfObj= dfObj.sort_values(by="Times Used", ascending=False)

dfObj.index=dfObj["pId"]
dfObj = dfObj.loc[:, ~dfObj.columns.str.contains('^Unnamed')]

dfObj.to_csv("process_info.csv", sep=',')



