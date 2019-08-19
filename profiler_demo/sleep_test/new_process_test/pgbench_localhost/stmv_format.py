#Raymond Schooley ravschoo@uw.edu 7-31-2019

#Go through all files in a directory containing json samples and create a new tsv file in 
#(Sample    Time Since Started    Metric    Value)(stmv) format.

#Collect: vCpuTimeUserMode, vCpuTimeKernelMode, vCpuTimeIOWait, vCpuTimeIntSrvc, vCpuTimeSoftIntSrvc, vCpuIdleTime,vDiskSectorReads, #vDiskSectorWrites, vNetworkBytesRecvd, vNetworkBytesRecvd from VM-level

#Collect: cCpuTimeUserMode, cCpuTimeKernelMode, cDiskReadBytes, cDiskWriteBytes, cNetworkBytesRecvd, cNetworkBytesSent, cMemoryUsed, cMemoryMaxUsed from Container-Level

import json
import os, sys
import pickle

#Get list of files in a directory.
path = sys.argv[1]
dirs = os.listdir( path )
dirs.sort()

#Make list of metrics we are interested in
metrics = {"vCpuTimeUserMode", "vCpuTimeKernelMode", "vCpuTimeIOWait", "vCpuTimeIntSrvc", "vCpuTimeSoftIntSrvc", "vCpuIdleTime", "vDiskSectorReads", "vDiskSectorWrites", "vNetworkBytesRecvd", "vNetworkBytesSent", "cCpuTimeUserMode", "cCpuTimeKernelMode", "cDiskReadBytes", "cDiskWriteBytes", "cNetworkBytesRecvd", "cNetworkBytesSent", "cMemoryUsed", "cMemoryMaxUsed"}
tab = "\t"
nL = "\n"

#Open output file to write to and insert headers
outFile = open("./activity.tsv", "w")
outFile.write("Sample" + tab + "Time Since Start" + tab + "Metric" + tab + "Value" + nL)

#Get current time of first file
start = open(path+dirs[0])
y = json.load(start)
startTime = y["currentTime"]

#Loop through directory
for file in dirs:
        with open(path+file) as f:
            print file, ":"
            # Deserialize into python object
            y = json.load(f)
            time = y["currentTime"] - startTime
            #write metrics to file
            for metric in metrics:
                outFile.write(file + tab + str(time) + tab + metric + tab + str(y[metric]) + nL)
            
#Testing
            #print "Current Time:", y["currentTime"]
            #print "vCpuIdleTime:", y["vCpuIdleTime"]
            #print "vCpuTimeKernelMode:", y["vCpuTimeKernelMode"]
            #print "vCpuTimeUserMode:", y["vCpuTimeUserMode"]

            #metrics.append(("vCpuTimeIOWait", time

outFile.close

