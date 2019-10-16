from plotly.subplots import make_subplots
import random
import json
import os, sys
import pandas as pd
import subprocess
import numpy as np

import plotly.express as px
import plotly.graph_objects as go
import argparse
from os import path
import math

graphing_methods=['scatter', 'bar']

def export_graphs_as_images(fig, file_name, title):
	file_name=file_name.split('.',1)[0]
	if not os.path.exists(file_name +"_images"):
		os.mkdir(file_name +"_images")
	fig.write_image(file_name +"_images/"+title +".png")
	print("saved image: " +title +".png to " + os.path.abspath(file_name +"_images"))
	

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





def makegraphs(metrics, df, graph_function, graph_title, x_title, y_title):
	start =0
	fig = go.Figure()
	for x in metrics:
		fig.add_trace(graph_function(x=data_frame['currentTime'], y=data_frame[x] / data_frame[x], name=x))



	fig.update_layout(
	    title=go.layout.Title(
		text=graph_title,
		xref="paper",
		x=0,
		font=dict(
			family="Courier New, monospace",
			size=18,
			color="#7f7f7f"
		)
	    ),
	    xaxis=go.layout.XAxis(
		title=go.layout.xaxis.Title(
		    text=x_title,
		    font=dict(
		        family="Courier New, monospace",
		        size=18,
		        color="#7f7f7f"
		    )
		)
	    ),
	    yaxis=go.layout.YAxis(
		title=go.layout.yaxis.Title(
		    text=y_title,
		    font=dict(
		        family="Courier New, monospace",
		        size=18,
		        color="#7f7f7f"
		    )
		)
	    )
	)
	export_graphs_as_images(fig, df.name, "temp3")
	fig.show()





parser = argparse.ArgumentParser(description="generates plotly graphs")
parser.add_argument('csv_file', action='store', help='csv file')
parser.add_argument('graph_method', action='store', nargs='?', default='Scatter', help='stores which graphing method to use')
parser.add_argument('sampling_delta', type=int, nargs='?', help='determines sampling size')
parser.add_argument('title', action='store', help='graph_title')
parser.add_argument('x_axis_title', action='store', help='x_axis_title')
parser.add_argument('y_axis_title', action='store', help='y_axis_title')

parser.add_argument('metrics', type=str, nargs='*', help='list of metrics to graph over')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')
args= parser.parse_args()

#dataframe read into from cmdline
data_frame = pd.read_csv(args.csv_file)
data_frame.head()
data_frame['currentTime'] = data_frame['currentTime'] - data_frame['currentTime'][0]

data_frame=data_frame.iloc[::args.sampling_delta]
data_frame.name=args.csv_file

#choosing which method to make the graphs
graph_function = graph_selection(graphing_methods, args.graph_method)

#preparing the x axis of time for all graphs
#obtains the graphs from cmdline, can have no input for every metric in the csv, n metrics space delimited, or a file if --infile tag included at the end
metrics = args.read_metrics(args.metrics, data_frame)

print(metrics)
makegraphs(metrics, data_frame, graph_function, args.title, args.x_axis_title, args.y_axis_title)

