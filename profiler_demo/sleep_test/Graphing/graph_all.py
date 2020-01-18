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
import shutil
from os.path import abspath
from subprocess import call


from distutils.dir_util import copy_tree


def read_metrics_file(metrics):

	if (len(metrics) == 1 and path.exists(metrics[0])):
		metrics_file= metrics[0]
		with open(metrics_file, 'r') as f:
			metrics= f.readline().split()
		f.close()
		return ' '.join(metrics)

		
	else:
		print("Error: Too many arguments or path does not exist")

def read_cmdline_metrics(metrics):
	return ' '.join(metrics)



#give, x folders, give metrics, give smoothening delta,

parser = argparse.ArgumentParser(description="generates plotly graphs by giving folders, metrics, and delta smoothening value")
parser.add_argument('-f', "--folders", action="store", nargs='*', help='determines sampling size')
parser.add_argument("-s", "--sampling_interval", type=str, nargs='?', default=1, action="store", help='determines sampling size')
parser.add_argument("-m", "--metrics", action="store", nargs='*', default=[], help='list of metrics to graph over')
parser.add_argument("-d", "--dynamic_creation", action="store_true", default=False, help='list of metrics to graph over')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')



args= parser.parse_args()
metrics = args.read_metrics(args.metrics)

#print(args.folders);
#print(args.sampling_interval);

print("making delta_json_gen script")
os.system("python delta_json_generation.py")
print("finished delta_json_gen script")

current_directory = os.getcwd()
final_directory = os.path.join(current_directory, r'graph_all_json')

if os.path.exists(final_directory):
	shutil.rmtree(final_directory)
if not os.path.exists(final_directory):
   os.makedirs(final_directory)

print("running delta_json_gen  on each path given")
for path in args.folders:
	path = os.path.expanduser(path)
	os.system("python auto_generated_delta_script.py {} {}".format(path, args.sampling_interval))
	copy_tree(path+"/delta_json", final_directory)
	
print("Finished running delta_json_gen  on each path given")

print("Creating a csv file based on dela information created")
os.system("python csv_generation_2.py {} {} {}".format(final_directory, "1", metrics))
print("Finished Creating a csv file based on dela information created")

print("Starting Graphing process")
if (args.dynamic_creation) :
	os.system("python plotly_graph_generation.py {} {} -d".format("vm_container.csv", metrics)) 
else :
	os.system("python plotly_graph_generation.py {} {}".format("vm_container.csv", metrics)) 

print("Finished Graphing process")

