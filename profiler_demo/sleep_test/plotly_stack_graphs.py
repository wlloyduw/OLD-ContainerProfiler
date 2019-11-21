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

def update_fig(figure, y_title, the_title):

	figure.update_layout(
    annotations=[go.layout.Annotation(
            x=.5,
            y=-0.235,
            showarrow=False,
            text="Time (Seconds)",
            xref="paper",
            yref="paper"
        ),
 
        go.layout.Annotation(
            x=-0.14,
            y=0.5,
			font=dict(
		        family="Courier New, monospace",
		        size=18,
		        color="#000000"
            ),
            showarrow=False,
            text=y_title,
            textangle=-90,
            xref="paper",
            yref="paper"
        )
    ],
    #autosize=True,
    margin=dict(
        b=100
    ),
	font=dict(
        family="Courier New, monospace",
        size=15,
        color="#000000"
    ),	
	showlegend=True
	)






	figure.update_xaxes(
    #ticktext=["end of split", "end of align", "end of merge"],
    #tickvals=["2000", "20000", "27500"],
	#ticktext=["split", "align", "merge"],
	#tickvals=["10", "2100", "20000"],
	tickangle=45, 
	showline=True, linewidth=3, linecolor='black', mirror=True, 
	tickfont=dict(
            family='Courier New, monospace',
            size=14,
            color='black'
        )

	)

	figure.update_yaxes(showline=True, linewidth=3, linecolor='black', mirror=True)
	figure.update_layout(legend_orientation="h")
	figure.update_layout(legend=dict(x=0, y=-.23))
	figure.update_layout(title = { 'text':the_title, 'x':.1, 'y':.87}),



def make_four(data_frame):
	titles1=["Cpu Utilization", "Memory Utilization", "Disk Utilization", "Network Utilization"]


	ytitles=["% of CPU Utilization", "Memory Usage Utilization", "# of Bytes transferred", "# of bytes sent/received"]
	applypercent=[True, False, False, False]
	metrics1=["cCpu0TIME", "cCpu1TIME", "cCpu2TIME", "cCpu3TIME", "cCpu4TIME", "cCpu5TIME", "cCpu6TIME", "cCpu7TIME"]

	metrics2=["cMemoryUsed", "cMemoryMaxUsed"]
	metrics3=["cDiskReadBytes", "cDiskWriteBytes"]
	metrics4=["cNetworkBytesRecvd", "cNetworkBytesSent"]

	
	metricslist1 = [metrics1, metrics2, metrics3, metrics4]


	titles2=["Cpu Utilization", "Memory Usage Utilization", "Network Utilization", "Load Avg"]
	ytitles2=["% of CPU Utilization", "Physical Ram (KB)", "# of bytes sent/received", "System load avg (threadcount)"]
	applypercent=[True, True, False, False]

	metrics1=["vCpuTimeUserMode", "vCpuTimeIOWait", "vCpuTimeKernelMode"]
	metrics2=["vMemoryFree", "vMemoryCached"]
	metrics3=["vNetworkBytesRecvd", "vNetworkBytesSent"]
	metrics4=["vLoadAvg"]


	metricslist2 = [metrics1, metrics2, metrics3, metrics4]

	full_metrics = [metricslist1, metricslist2]

	fig = make_subplots(rows=2, cols=2)#, subplot_titles=titles)

	titles_all = [titles1, titles2]
	ytitles_all = [ytitles, ytitles2]
	

	num = 0
	for metrics in  full_metrics:
		
		current_row = 1
		current_col = 1
		axiscounter=1
		count = 0

		for sublist in metrics:

			export_fig = go.Figure()

			for el in sublist:

				the_max= data_frame[sublist].max().max()
				if applypercent[count] == True:
					fig.add_trace(go.Scatter(x=data_frame['currentTime'], y=data_frame[el]/the_max, name=el, hoverinfo='x+y+name'), row=current_row, col=current_col)
					export_fig.add_trace(go.Scatter(x=data_frame['currentTime'], y=data_frame[el]/the_max, name=el, hoverinfo='x+y+name'))
				else:
					fig.add_trace(go.Scatter(x=data_frame['currentTime'], y=data_frame[el], name=el, hoverinfo='x+y+name'), row=current_row, col=current_col)
					export_fig.add_trace(go.Scatter(x=data_frame['currentTime'], y=data_frame[el], name=el, hoverinfo='x+y+name'))
				#fig.add_trace(go.Scatter(x=data_frame['currentTime'], y=data_frame[el]),
						

				
			current_col = current_col +1
			if (current_col ==  3):
				current_col =1
				current_row +=1
			currentXAxis='xaxis{}'.format(axiscounter)
			currentYAxis='yaxis{}'.format(axiscounter)
			fig['layout'][currentXAxis].update(title="Time (seconds)")
			fig['layout'][currentYAxis].update(title=ytitles[count])
			axiscounter+=1
			update_fig(export_fig, ytitles_all[num][count], titles_all[num][count])
			count +=1

			export_graphs_as_images(export_fig, "stacked {}".format(num), str(count))
		num +=1

	
def makegraphs(metrics, dfs, percentage_flag, graph_title, x_title, y_title):
	start =0
	fig = go.Figure()
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
	
	df = dfs[0]
	the_max= df[metrics].max().max()
	for df in dfs:
		for x in metrics:
			if x in list(df.columns.values):	
				if percentage_flag == True:
					fig.add_trace(go.Scatter(x=df['currentTime'], y=df[x]/the_max, name=x, hoverinfo='x+y+name'))
				else:
					fig.add_trace(go.Scatter(x=df['currentTime'], y=df[x], name=x, hoverinfo='x+y+name', marker=dict(
            color='Blue',
            size=120,
            line=dict(
                color='Blue',
                width=12
            )
        )))
				
	export_graphs_as_images(fig, graph_title, "temp3")
	fig.show()






parser = argparse.ArgumentParser(description="generates plotly graphs")
parser.add_argument('-c', "--csv_file", action="store", help='determines sampling size')
parser.add_argument("-c2", "--csv_second", action="store", help='determines sampling size')

parser.add_argument("-s", "--sampling_interval", type=int, nargs='?', action="store", help='determines sampling size')

parser.add_argument("-t", "--title", action="store", help='determines sampling size')
parser.add_argument("-xt", "--x_title", action="store", help='determines sampling size')
parser.add_argument("-yt", "--y_title", action="store", help='determines sampling size')

parser.add_argument("-p", "--percentage", action="store_true", help='determines sampling size')

parser.add_argument('metrics', type=str, nargs='*', help='list of metrics to graph over')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')
args= parser.parse_args()

#dataframe read into from cmdline
data_frame = pd.read_csv(args.csv_file)
data_frame.head()
data_frame['currentTime'] = data_frame['currentTime'] - data_frame['currentTime'][0]

data_frame.name=args.csv_file

dfs = []
dfs.append(data_frame)
if args.csv_second != None:
	data_frame = pd.read_csv(args.csv_second)
	data_frame.head()
	data_frame['currentTime'] = data_frame['currentTime'] - data_frame['currentTime'][0]
	data_frame.name=args.csv_second
	dfs.append(data_frame)
#choosing which method to make the graphs

#preparing the x axis of time for all graphs
#obtains the graphs from cmdline, can have no input for every metric in the csv, n metrics space delimited, or a file if --infile tag included at the end
metrics = args.read_metrics(args.metrics, data_frame)

print(metrics)
#makegraphs(metrics, dfs, args.percentage, args.title, args.x_title, args.y_title)
make_four(data_frame)
