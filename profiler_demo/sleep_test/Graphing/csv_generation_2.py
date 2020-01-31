import json
import os
import pandas as pd
import argparse


#usage: python csv_generation_2.py path_of_folder_with_json sampling_delta metrics(file or space delimited list, if file include --infile, leave blank for all metrics found in the json files.)

def read_metrics_file(metrics):
	if (len(metrics) == 1 and path.exists(metrics[0])):
		metrics_file= metrics[0]
		with open(metrics_file, 'r') as f:
			metrics= f.readline().split()
			#	print(metrics)
		f.close()
		return metrics
	else:
		print("Error: Too many arguments or path does not exist")

def read_cmdline_metrics(metrics):
	return metrics

# vm_container dictionary to store the virtual machine and container data. Key is the filename and value is the virtual machine and container data.
vm_container = {}
#Parse for folder path, and metrics to add.
parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
parser.add_argument('sampling_delta', type=int, nargs='?', default=1, help='determines sampling size')
parser.add_argument('metrics', type=str, nargs='*', help='list of metrics or file for metrics')
parser.add_argument('--infile', dest='read_metrics', action='store_const', const=read_metrics_file, default=read_cmdline_metrics, help='reads metrics from a file or from command line')

args= parser.parse_args()
file_path = args.file_path
metrics = args.read_metrics(args.metrics)
#currentTime is necessary to be included in metrics as it is used to create time series. We add it here incase its not already included
metrics.append('currentTime')
metrics = set(metrics)
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
	#print metrics
        for k in y:
            if not (k == "pProcesses" or k == "cProcessorStats"):
			if k in metrics or len(metrics) == 1:
				r[k] = y[k]
	if ("cProcessorStats" in y and "cNumProcessors" in y):
	    for k in y["cProcessorStats"]:
		    if (k in metrics or len(metrics) == 0):

	                r[k] = y["cProcessorStats"][k]

        totalProcesses = len(y["pProcesses"]) - 1
	#print y["pProcesses"][len(y["pProcesses"]) - 1]
	
	for k in y["pProcesses"][totalProcesses]:
		if k == "pTime":
			r["pTime"] = y["pProcesses"][totalProcesses]["pTime"]
	
        # Loop through the process level data
        for i in xrange(totalProcesses):
            # A dictinary containing process level data
            s = {"filename": file}

            for k in y["pProcesses"][i]:
                s[k] = y["pProcesses"][i][k]

            s["currentTime"] = r["currentTime"]

            # If the process id is already in the processes, append to the list of processes
            pids = []
            if y["pProcesses"][i]["pId"] in processes:
                pids = processes[y["pProcesses"][i]["pId"]]
            pids.append( s )
            processes[y["pProcesses"][i]["pId"]] = pids
        vm_container[file] = r


#creates empty folder for process info
if not os.path.exists('./process_info/{}'.format(os.path.basename(os.path.normpath(file_path)))):
	os.makedirs('./process_info/{}'.format(os.path.basename(os.path.normpath(file_path))))

for key, value in processes.iteritems():
    df1 = pd.DataFrame(value)
    df1 = df1.sort_values(by='currentTime', ascending=True)
    df1.to_csv("./process_info/{}/Pid, {}.csv".format(os.path.basename(os.path.normpath(file_path)),str(key)))

# Create a separate CSV files for each of the processes
# Dump dictionary to a JSON file
with open("vm_container.json","w") as f:
    f.write(json.dumps(vm_container))

# Convert JSON to dataframe and convert it to CSV
df = pd.read_json("vm_container.json").T
df=df.iloc[::args.sampling_delta]
df.to_csv("vm_container.csv", sep=',')

# Convert JSON to dataframe and convert it to CSV
df = pd.read_json("vm_container.json").T
df=df.iloc[::args.sampling_delta]
df.to_csv("vm_container.tsv", sep='\t')

