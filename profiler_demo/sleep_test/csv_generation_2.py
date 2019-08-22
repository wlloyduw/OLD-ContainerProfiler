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
import glob

#usage: python csv_generation_2.py path_of_folder_with_json metrics(file or space delimited list, if file include --infile, leave blank for all metrics found in the json files.)

def read_metrics_file(metrics):

	if (len(metrics) == 1 and path.exists(metrics[0])):
		metrics_file= metrics[0]
		with open(metrics_file, 'r') as f:
			metrics= f.readline().split()
			print(metrics)
		f.close()
		return metrics
		
	else:
		print("Error: Too many arguments or path does not exist")

def read_cmdline_metrics(metrics):
	return metrics

# vm_container dictionary to store the virtual machine and container data. Key is the filename and value is the virtual machine and container data.
vm_container = {}
# Path from where the json files to be converted to a csv file
parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
parser.add_argument('metrics', type=str, nargs='*', help='list of metrics or file for metrics')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')
args= parser.parse_args()

file_path = args.file_path
metrics = args.read_metrics(args.metrics)

dirs = os.listdir( file_path )
# processes dictionary to store process level data
processes = dict()
dirs=  [i for i in os.listdir( file_path ) if i.endswith(".json")]

for file in dirs:
    with open(file_path+'/'+file) as f:
        # Deserialize into python object
        y = json.load(f)
        # A dictionary which contains the value of vm_container dictionary
        r = {}

        # Check for any list or dictionary in y
        # determines what is chosen out of the metrics.

        for k in y:
            if not (k == "pProcesses" or k == "cProcessorStats"):
                if k in metrics or len(metrics) == 0:
                    r[k] = y[k]

	if(("cProcessorStats" in metrics and "cNumProcessors" in metrics) or len(metrics) ==0):
		if ("cProcessorStats" in y and "cNumProcessors" in y):
		    for k in y["cProcessorStats"]:
		        if k != "cNumProcessors":
		            r[k] = y["cProcessorStats"][k]

        #totalProcesses = y["cNumProcesses"]
        totalProcesses = len(y["pProcesses"]) - 1

        # Loop through the process level data
        for i in xrange(totalProcesses):
            # A dictinary containing process level data
            s = {"filename": file}

            for k in y["pProcesses"][i]:
                s[k] = y["pProcesses"][i][k]

            # If the process id is already in the processes, append to the list of processes
            pids = []
            if y["pProcesses"][i]["pId"] in processes:
                pids = processes[y["pProcesses"][i]["pId"]]
            pids.append( s )
            processes[y["pProcesses"][i]["pId"]] = pids
        vm_container[file] = r

# Create a separate CSV files for each of the processes
for key, value in processes.iteritems():
    df1 = pd.DataFrame(value)
    df1.to_csv(str(key)+".csv")

# Dump dictionary to a JSON file
with open("vm_container.json","w") as f:
    f.write(json.dumps(vm_container))

# Convert JSON to dataframe and convert it to CSV
df = pd.read_json("vm_container.json").T
df.to_csv("vm_container.csv", sep=',')

# Convert JSON to dataframe and convert it to CSV
df = pd.read_json("vm_container.json").T
df.to_csv("vm_container.tsv", sep='\t')

