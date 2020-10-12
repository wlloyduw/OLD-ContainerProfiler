import argparse
import os
import sys
import json
import copy
#import ConfigParser
import pandas as pd
import time
import csv
import glob
import shutil
import re
#import path
from collections import namedtuple


def read_metrics_file(metrics):

	if (len(metrics) == 1): #and path.exists(metrics[0])):
		metrics_file= metrics[0]
		with open(metrics_file, 'r')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        as f:
			metrics= f.readline().split()
			print(metrics)
		f.close()
		return metrics
		
	else:
		print("Error: Too many arguments or path does not exist")

def read_cmdline_metrics(metrics):
	return metrics


parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
parser.add_argument('metrics', type=str, nargs='*', help='list of metrics or file for metrics')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')


args= parser.parse_args()
file_path = args.file_path
metrics = args.read_metrics(args.metrics)



for i in range(0, len(metrics)):
	if os.path.exists('{}/{}'.format(file_path, metrics[i])):
		shutil.rmtree('{}/{}'.format(file_path, metrics[i]))
	if not os.path.exists('{}/{}'.format(file_path, metrics[i])):
		os.makedirs('{}/{}'.format(file_path, metrics[i]))


dirs= [i for i in os.listdir( file_path ) if i.endswith(".csv")]
dirs.sort()

used_count = []
for file_name in dirs:
	with open(file_path + '/' + file_name) as csv_file: 
		data_frame = pd.read_csv(csv_file)
		data_frame.head()


		for i in range(0, len(metrics)):
			contains_metric =  data_frame['pCmdLine'].astype(str).str.contains(metrics[i], na=False, flags=re.IGNORECASE)
			filtered = data_frame[contains_metric]
			filtered.head()
			if (len(filtered.index) > 1) :
				filtered = filtered.loc[:, ~filtered.columns.str.contains('^Unnamed')]
				filtered.to_csv('{}/{}/{}'.format(file_path, metrics[i], file_name))



for i in range(0, len(metrics)):
	#path = "{}/{}".format(file_path, metrics[i])
	path = file_path
	all_files = glob.glob(path+ "/*.csv")
	li = []
	print(path)
	for filtered_file in all_files:
		df = pd.read_csv(filtered_file, index_col=None, header=0)
		li.append(df)
		print(filtered_file)

	frame = pd.concat(li, axis=0, ignore_index=True)
	frame = frame.sort_values(by='currentTime', ascending=True)
	frame = frame.loc[:, ~frame.columns.str.contains('^Unnamed: 0')]
	frame.drop(frame.columns[0], axis=1)
	#frame= frame.groupby(['currentTime']).agg({                         
	#	'filename':'first', 'pBlockIODelays':'sum','pChildrenKernelMode':'sum', 'pChildrenUserMode':'sum','pCmdLine':'first', 'pCpuTimeUserMode':'sum', 'pId':'sum', 'pName':'first', 			'pNonvoluntaryContextSwitches':'sum', 'pNumThreads':'sum', 'pResidentSetSize':'sum','pVirtualMemoryBytes': 'sum', 'pVoluntaryContextSwitches':'sum'})

	#frame = frame.groupby(['currentTime']).sum()

	#frame = frame.diff(axis=1, periods=1)
	frame.drop(frame.index[0])
	frame['pCpuTime'] = frame['pCpuTimeUserMode'] + frame['pCpuTimeKernelMode']
	#print frame
	frame.to_csv('{}/{}/{}'.format(file_path, metrics[i], "agg_sum.csv"))

	



