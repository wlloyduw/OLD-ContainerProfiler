from plotly.subplots import make_subplots
import random
import json
import os, sys
import pandas as pd
import subprocess
import matplotlib.pyplot as plt
import numpy as np

#new
import plotly.express as px
import plotly.graph_objects as go
import argparse
from os import path

#usage: python plotly_graph_generation.py csv_file graphing_method metrics(file or space delimited list, if file include --infile)

#implemented graphing methods
graphing_methods=['scatter', 'bar']

def read_metrics_file(metrics, data_frame):

	if (len(metrics) == 1 and path.exists(metrics[0])):
		metrics_file= metrics[0]
		with open(metrics_file, 'r') as f:
			metrics= f.readline().split()
		f.close()
		return metrics
		
	else:
		print("Error: Too many arguments or path does not exist")

def read_cmdline_metrics(metrics, data_frame):
	if (len(metrics) == 0):
		print(list(data_frame.columns[1:]))
		print("return a big list ok")
		return list(data_frame.columns[1:])
	else:
		return metrics

def graph_selection(graphing_methods, method):
	method = method.lower()
	if (method in graphing_methods):

		if (method == "scatter"):
			return go.Scatter
		elif (method =="bar"):
			return go.Bar
		elif (method =="pie"):
			return go.Pie

	else:
		print("Method not listed in implemented graphing options")


def slice_for_x(theList, start, length):
	if (start + length > len(theList)):
		return theList[start:]
	else:
		return theList[start:start+length]

def makegraphs(metrics, df, graph_function):
	start =0
	length=9

	for i in xrange((len(metrics) // length) + 1):
		sliced_metrics = slice_for_x(metrics, start, length)
		fig = make_subplots(rows=3, cols=3, subplot_titles=sliced_metrics)
		current_row=1
		current_col=1
		axiscounter=1

		for x in sliced_metrics:

			fig.add_trace(graph_function(x=data_frame.currentTime, y=data_frame[x]),
				row=current_row, col=current_col)
			current_col = current_col +1
			if (current_col == 4):
				current_col =1
				current_row +=1
			currentXAxis='xaxis{}'.format(axiscounter)
			currentYAxis='yaxis{}'.format(axiscounter)

			fig['layout'][currentXAxis].update(title="Epoch Time(seconds)")
			fig['layout'][currentYAxis].update(title=x)
			axiscounter+=1

		start += length

		fig.show()

#cmdline parser
parser = argparse.ArgumentParser(description="generates plotly graphs")
parser.add_argument('csv_file', action='store', help='csv file')
parser.add_argument('graph_method', action='store', nargs='?', default='Scatter', help='stores which graphing method to use')
parser.add_argument('metrics', type=str, nargs='*', help='list of metrics to graph over')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')
args= parser.parse_args()



#dataframe read into from cmdline
data_frame = pd.read_csv(args.csv_file)
data_frame.head()

#choosing which method to make the graphs
graph_function = graph_selection(graphing_methods, args.graph_method)

#preparing the x axis of time for all graphs
data_frame.currentTime = (data_frame.currentTime - data_frame.currentTime[0])
#obtains the graphs from cmdline, can have no input for every metric in the csv, n metrics space delimited, or a file if --infile tag included at the end
metrics = args.read_metrics(args.metrics, data_frame)


makegraphs(metrics, data_frame, graph_function)
