import argparse
import os
import sys
import json
import ConfigParser
from collections import namedtuple

parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('file_path', action='store', help='stores the filepath to the folder holding all the JSON files')
args= parser.parse_args()
file_path = args.file_path
json_array = []
dirs=  [i for i in os.listdir( file_path ) if i.endswith(".json")]
dirs.sort()
for file_name in dirs:
	with open(file_path + '/' + file_name) as json_file: 
		new_json_object = json.load(json_file)
    		json_array.append(new_json_object)

def file_subtraction(the_json_one, the_json_two):
	the_json_two['cCpuTime']=the_json_two['cCpuTime']-the_json_one['cCpuTime']
	the_json_two['cCpuTimeKernelMode']=the_json_two['cCpuTimeKernelMode']-the_json_one['cCpuTimeKernelMode']
	the_json_two['cCpuTimeUserMode']=the_json_two['cCpuTimeUserMode']-the_json_one['cCpuTimeUserMode']
	the_json_two['cDiskReadBytes']=the_json_two['cDiskReadBytes']-the_json_one['cDiskReadBytes']
	the_json_two['cDiskSectorIO']=the_json_two['cDiskSectorIO']-the_json_one['cDiskSectorIO']
	the_json_two['cDiskWriteBytes']=the_json_two['cDiskWriteBytes']-the_json_one['cDiskWriteBytes']
	the_json_two['cMemoryUsed']=the_json_two['cMemoryUsed']-the_json_one['cMemoryUsed']
	the_json_two['cNetworkBytesRecvd']=the_json_two['cNetworkBytesRecvd']-the_json_one['cNetworkBytesRecvd']
	the_json_two['cNetworkBytesSent']=the_json_two['cNetworkBytesSent']-the_json_one['cNetworkBytesSent']
	the_json_two['cNumProcesses']=the_json_two['cNumProcesses']-the_json_one['cNumProcesses']
	the_json_two['cNumProcessors']=the_json_two['cNumProcessors']-the_json_one['cNumProcessors']
	the_json_two['currentTime']=the_json_two['currentTime']-the_json_one['currentTime']
	the_json_two['vCpuContextSwitches']=the_json_two['vCpuContextSwitches']-the_json_one['vCpuContextSwitches']
	the_json_two['vCpuIdleTime']=the_json_two['vCpuIdleTime']-the_json_one['vCpuIdleTime']
	the_json_two['vCpuNice']=the_json_two['vCpuNice']-the_json_one['vCpuNice']
	the_json_two['vCpuSteal']=the_json_two['vCpuSteal']-the_json_one['vCpuSteal']
	the_json_two['vCpuTime']=the_json_two['vCpuTime']-the_json_one['vCpuTime']
	the_json_two['vCpuTimeIOWait']=the_json_two['vCpuTimeIOWait']-the_json_one['vCpuTimeIOWait']
	the_json_two['vCpuTimeIntSrvc']=the_json_two['vCpuTimeIntSrvc']-the_json_one['vCpuTimeIntSrvc']
	the_json_two['vCpuTimeKernelMode']=the_json_two['vCpuTimeKernelMode']-the_json_one['vCpuTimeKernelMode']
	the_json_two['vCpuTimeSoftIntSrvc']=the_json_two['vCpuTimeSoftIntSrvc']-the_json_one['vCpuTimeSoftIntSrvc']
	the_json_two['vCpuTimeUserMode']=the_json_two['vCpuTimeUserMode']-the_json_one['vCpuTimeUserMode']
	the_json_two['vDiskMergedReads']=the_json_two['vDiskMergedReads']-the_json_one['vDiskMergedReads']
	the_json_two['vDiskMergedWrites']=the_json_two['vDiskMergedWrites']-the_json_one['vDiskMergedWrites']
	the_json_two['vDiskReadTime']=the_json_two['vDiskReadTime']-the_json_one['vDiskReadTime']
	the_json_two['vDiskSectorReads']=the_json_two['vDiskSectorReads']-the_json_one['vDiskSectorReads']
	the_json_two['vDiskSectorWrites']=the_json_two['vDiskSectorWrites']-the_json_one['vDiskSectorWrites']
	the_json_two['vDiskSuccessfulReads']=the_json_two['vDiskSuccessfulReads']-the_json_one['vDiskSuccessfulReads']
	the_json_two['vDiskSuccessfulWrites']=the_json_two['vDiskSuccessfulWrites']-the_json_one['vDiskSuccessfulWrites']
	the_json_two['vDiskWriteTime']=the_json_two['vDiskWriteTime']-the_json_one['vDiskWriteTime']
	the_json_two['vMemoryBuffers']=the_json_two['vMemoryBuffers']-the_json_one['vMemoryBuffers']
	the_json_two['vMemoryCached']=the_json_two['vMemoryCached']-the_json_one['vMemoryCached']
	the_json_two['vMemoryTotal']=the_json_two['vMemoryTotal']-the_json_one['vMemoryTotal']
	the_json_two['vNetworkBytesRecvd']=the_json_two['vNetworkBytesRecvd']-the_json_one['vNetworkBytesRecvd']
	the_json_two['vNetworkBytesSent']=the_json_two['vNetworkBytesSent']-the_json_one['vNetworkBytesSent']
	for (each_key) in the_json_two['cProcessorStats']:
		if ('cCpu' in each_key and 'TIME' in each_key):
			the_json_two['cProcessorStats'][each_key] = the_json_two['cProcessorStats'][each_key] - the_json_one['cProcessorStats'][each_key]

file_subtraction(json_array[0], json_array[1])
