import psutil
import json
import argparse
from datetime import datetime
import re      
import subprocess
import os.path
from os import path

#add the virtual level.
CORRECTION_MULTIPLIER=100
CORRECTION_MULTIPLIER_MEMORY=(1/1000)

parser = argparse.ArgumentParser(description='process path and file /or string of metrics.')
parser.add_argument('output_dir', action='store', help='stores directory to where the files will be output to')
parser.add_argument("-v", "--vm_profiling", action="store_true", default=False, help='list of metrics to graph over')
parser.add_argument("-c", "--container_profiling", action="store_true", default=False, help='list of metrics to graph over')
parser.add_argument("-p", "--processor_profiling", action="store_true", default=False, help='list of metrics to graph over')
args= parser.parse_args()
output_dir = args.output_dir

if all(v is False for v in [args.vm_profiling, args.container_profiling, args.processor_profiling]):
	args.vm_profiling = True
	args.container_profiling=True
	args.processor_profiling=True

filename = datetime.now().strftime(output_dir+"/%Y_%m_%d_%H_%M_%S.json")
output_dict={}


def getContainerInfo():
	
	
	cpuTime_file = open("/sys/fs/cgroup/cpuacct/cpuacct.usage", "r")
	cpuTime=int(cpuTime_file.readline())


	container_mem_file = open("/sys/fs/cgroup/memory/memory.stat", "r")
	container_mem_stats=container_mem_file.read()#line().split()
	cpgfault = int(re.findall(r'pgfault.*', container_mem_stats)[0].split()[1])
	cpgmajfault = int(re.findall(r'pgmajfault.*', container_mem_stats)[0].split()[1])
	
	cpuinfo_file=  open("/proc/stat", "r")
	cpuinfo_file_stats=cpuinfo_file.read()
	cCpuTimeUserMode = int(re.findall(r'cpu.*', cpuinfo_file_stats)[0].split()[1])
	cCpuTimeKernelMode = int(re.findall(r'cpu.*', cpuinfo_file_stats)[0].split()[3])
	

	cProcessorStatsFile= open("/sys/fs/cgroup/cpuacct/cpuacct.usage_percpu", "r")
	cProcessorStatsFileArr= cProcessorStatsFile.readline().split()
	cProcessorDict={}
	count =0
	for el in cProcessorStatsFileArr:
		temp_str="cCpu${}TIME".format(count)
		count+=1
		cProcessorDict[temp_str]=int(el)
	
	cDiskSectorIO=0
	if path.exists('/sys/fs/cgroup/blkio/blkio.sectors'):
		cDiskSectorIOFile=open("/sys/fs/cgroup/blkio/blkio.sectors", "r")
		cDiskSectorIOFileArr = re.findall(r'cpu.*', cDiskSectorIOFile)[0].split()
		cDiskSectorIO=sum(cDiskSectorIOFileArr)
	cDiskReadBytes=0
	cDiskWriteBytes=0

	
	try:
		cmd1= ['lsblk', '-a']
		cmd2=['grep', 'disk']
		p1 = subprocess.Popen(cmd1, stdout=subprocess.PIPE)
		p2 = subprocess.Popen(cmd2, stdin=p1.stdout, stdout=subprocess.PIPE)
		o, e = p2.communicate()
		major_minor_arr=[]
		
		for line in o.decode('UTF-8').split(sep='\n')[:-1]:
			major_minor_arr.append(line.split()[1])

		 #   temp=($line)
		  #  disk_arr+=(${temp[1]})
		  #done
		#major_minor=str(o.decode('UTF-8')).split()[1]
		

		cDiskReadBytesFile=open("/sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes", "r")
		cProcessorStatsFile_info=cDiskReadBytesFile.read()
		cDiskReadBytesArr=re.findall(r'.*Read.*', cProcessorStatsFile_info)

		for el in cDiskReadBytesArr:
			temp_arr = el.split()
			for major_minor in major_minor_arr:
				if (temp_arr[0] == major_minor):
					cDiskReadBytes += int(temp_arr[2])

	except:
		pass


	try:
		cmd1= ['lsblk', '-a']
		cmd2=['grep', 'disk']
		p1 = subprocess.Popen(cmd1, stdout=subprocess.PIPE)
		p2 = subprocess.Popen(cmd2, stdin=p1.stdout, stdout=subprocess.PIPE)
		o, e = p2.communicate()
		major_minor_arr=[]
		
		for line in o.decode('UTF-8').split(sep='\n')[:-1]:
			major_minor_arr.append(line.split()[1])

		cDiskWriteBytesFile=open("/sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes", "r")
		cProcessorStatsFile_info=cDiskWriteBytesFile.read()
		cDiskWriteBytesArr=re.findall(r'.*Write.*', cProcessorStatsFile_info)
		for el in cDiskWriteBytesArr:
			temp_arr = el.split()
			for major_minor in major_minor_arr:
				if (temp_arr[0] == major_minor):
					cDiskWriteBytes += int(temp_arr[2])

	except:
		pass




	
	cNetworkBytesFile=open("/proc/net/dev", "r")
	cNetworkBytesFileStats=cNetworkBytesFile.read()
	cNetworkBytesRecvd=0
	cNetworkBytesSent=0
	try:
		cNetworkBytesArr=re.findall(r'eth0.*',cNetworkBytesFileStats)[0].split()
		cNetworkBytesRecvd=int(cNetworkBytesArr[1])
		cNetworkBytesSent=int(cNetworkBytesArr[9])

	except:	
		pass
		


	MEMUSEDC_file=open("/sys/fs/cgroup/memory/memory.usage_in_bytes", "r")
	MEMMAXC_file=open("/sys/fs/cgroup/memory/memory.max_usage_in_bytes", "r")
	cMemoryUsed=int(MEMUSEDC_file.readline().rstrip('\n'))
	cMemoryMaxUsed=int(MEMMAXC_file.readline().rstrip('\n'))

	cId_file=open("/etc/hostname", "r")
	cId=cId_file.readline().rstrip('\n')
	#CPU=(`cat /proc/stat | grep '^cpu '`)

	cNumProcesses = sum(1 for line in open("/sys/fs/cgroup/pids/tasks", "r")) -2



	container_dict={		
		"cCpuTime": cpuTime,
		"cNumProcessors": psutil.cpu_count(),
		"cPGFault": cpgfault,
		"cMajorPGFault": cpgmajfault,
		"cProcessorStats": cProcessorDict,
		"cCpuTimeUserMode":   cCpuTimeUserMode,
		"cCpuTimeKernelMode": cCpuTimeKernelMode,
		"cDiskSectorIO":      cDiskSectorIO,
		"cDiskReadBytes":  cDiskReadBytes,
		"cDiskWriteBytes": cDiskWriteBytes	,
		"cNetworkBytesRecvd":cNetworkBytesRecvd,
		"cNetworkBytesSent": cNetworkBytesSent,
		"cMemoryUsed": cMemoryUsed,
		"cMemoryMaxUsed": cMemoryMaxUsed,	
		"cId": cId,
		"cNumProcesses": cNumProcesses,
		"pMetricType": "Process level"
	}
	return container_dict

def getVmInfo():
	cpu_info=psutil.cpu_times()
	net_info=psutil.net_io_counters(nowrap=True)
	cpu_info2=psutil.cpu_stats()
	disk_info=psutil.disk_io_counters()
	memory=psutil.virtual_memory()
	loadavg=psutil.getloadavg()
	cpu_freq=psutil.cpu_freq()


	vm_file = open("/proc/vmstat", "r")
	vm_file_stats=vm_file.read()#line().split()
	pgfault = int(re.findall(r'pgfault.*', vm_file_stats)[0].split()[1])
	pgmajfault = int(re.findall(r'pgmajfault.*', vm_file_stats)[0].split()[1])

	
	cpuinfo_file= open("/proc/cpuinfo", "r")
	cpuinfo_file_stats=cpuinfo_file.read()
	vCpuType = re.findall(r'model name.*', cpuinfo_file_stats)[0].split(sep=": ")[1]

	kernel_info=str(subprocess.Popen("uname -a", shell=True, stdout =subprocess.PIPE).communicate()[0][:-1], 'utf-8')

	cmd1=['lsblk', '-nd', '--output', 'NAME,TYPE']
	cmd2=['grep','disk']
	p1 = subprocess.Popen(cmd1, stdout=subprocess.PIPE)
	p2 = subprocess.Popen(cmd2, stdin=p1.stdout, stdout=subprocess.PIPE)
	o, e = p2.communicate()

	mounted_filesys=str(o.decode('UTF-8').split()[0])
	vm_disk_file=open("/proc/diskstats", "r")
	vm_disk_file_stats=vm_disk_file.read()
	vDiskSucessfulReads=int(re.findall(rf"{mounted_filesys}.*", vm_disk_file_stats)[0].split(sep=" ")[1])
	vDiskSucessfulWrites=int(re.findall(rf"{mounted_filesys}.*", vm_disk_file_stats)[0].split(sep=" ")[5])


	vm_dict={
		"vMetricType" : "VM Level",
		"vKernelInfo" : kernel_info,
		"vCpuTime" : (cpu_info[0] + cpu_info[2]) *CORRECTION_MULTIPLIER ,
		"vDiskSectorReads" : disk_info[2]/512, 
		"vDiskSectorWrites" : disk_info[3]/512,
		"vNetworkBytesRecvd" : net_info[1],
		"vNetworkBytesSent" : net_info[0], 
		"vPgFault" : int(pgfault),
		"vMajorPageFault" : int(pgmajfault),
		"vCpuTimeUserMode" : cpu_info[0] * CORRECTION_MULTIPLIER, 
		"vCpuTimeKernelMode" : cpu_info[2] * CORRECTION_MULTIPLIER,
		"vCpuIdleTime" :  cpu_info[3]* CORRECTION_MULTIPLIER,
		"vCpuTimeIOWait" :  cpu_info[4]* CORRECTION_MULTIPLIER,
		"vCpuTimeIntSrvc" :  cpu_info[5]* CORRECTION_MULTIPLIER,
		"vCpuTimeSoftIntSrvc" : cpu_info[6] * CORRECTION_MULTIPLIER,
		"vCpuContextSwitches" : cpu_info2[0]* CORRECTION_MULTIPLIER,
		"vCpuNice" : cpu_info[1]* CORRECTION_MULTIPLIER,
		"vCpuSteal" : cpu_info[7]* CORRECTION_MULTIPLIER,
		"vBootTime" : psutil.boot_time(),

		"vDiskSuccessfulReads" : vDiskSucessfulReads,
		"vDiskMergedReads" : disk_info[6],
		"vDiskReadTime" : disk_info[4],
		"vDiskSuccessfulWrites" : vDiskSucessfulWrites,
		"vDiskMergedWrites" : disk_info[7],
		"vDiskWriteTime" : disk_info[5],
		"vMemoryTotal" : round(memory[0] * CORRECTION_MULTIPLIER_MEMORY),	
		"vMemoryFree" : round(memory[4]* CORRECTION_MULTIPLIER_MEMORY),
		"vMemoryBuffers" : round(memory[7]* CORRECTION_MULTIPLIER_MEMORY),
		"vMemoryCached" : round(memory[8]* CORRECTION_MULTIPLIER_MEMORY),
		"vLoadAvg" : loadavg[0],
		"vId" : "unavailable",
		"vCpuType" : vCpuType,
		"vCpuMhz" : cpu_freq[0]
	}
	return vm_dict

def getProcInfo():
	#need to get pPGFault/pMajorPGFault in a different verbosity level: maybe called MP for manual process
	#pResidentSetSize needs to be get in MP
	
	dictlist=[]
	for proc in psutil.process_iter():
		#procFile="/proc/{}/stat".format(proc.pid) 
		#log = open(procFile, "r")
		#pidProcStat=log.readline().split()

		curr_dict={
			"pId" : proc.pid,
			"pCmdline" : " ".join(proc.cmdline()),
			"pName" : proc.name(),
			"pNumThreads" : proc.num_threads(),
			"pCpuTimeUserMode" : proc.cpu_times()[0]* CORRECTION_MULTIPLIER,
			"pCpuTimeKernelMode" : proc.cpu_times()[1]* CORRECTION_MULTIPLIER,
			"pChildrenUserMode" : proc.cpu_times()[2]* CORRECTION_MULTIPLIER,
			"pChildrenKernelMode" : proc.cpu_times()[3]* CORRECTION_MULTIPLIER,
			#"pPGFault" : int(pidProcStat[9]),
			#"pMajorPGFault" : int(pidProcStat[11]),
			"pVoluntaryContextSwitches" : proc.num_ctx_switches()[0],		
			"pInvoluntaryContextSwitches" : proc.num_ctx_switches()[1],		
			"pBlockIODelays" : proc.cpu_times()[4]* CORRECTION_MULTIPLIER,
			"pVirtualMemoryBytes" : proc.memory_info()[1]
			#"pResidentSetSize" : proc.memory_info()[0]   	      

		}
		

		dictlist.append(curr_dict)
	return dictlist


seconds_since_epoch = round(datetime.now().timestamp())
output_dict["currentTime"] = seconds_since_epoch		#bad value.

if args.vm_profiling == True:
	time_start_VM=datetime.now()
	vm_info=getVmInfo()
	time_end_VM=datetime.now()
	VM_write_time=time_end_VM-time_start_VM

	output_dict.update(vm_info)
if args.container_profiling == True:
	time_start_container=datetime.now()
	container_info=getContainerInfo()
	time_end_container=datetime.now()
	container_write_time=time_end_container-time_start_container

	output_dict.update(container_info)
if args.processor_profiling == True:
	time_start_proc=datetime.now()
	procces_info=getProcInfo()
	time_end_proc=datetime.now()
	process_write_time=time_end_proc-time_start_proc

	output_dict["pProcesses"] = procces_info


if args.vm_profiling == True:
	output_dict["VM_Write_Time"] = VM_write_time.total_seconds()
if args.container_profiling == True:
	output_dict["Container_Write_Time"] = container_write_time.total_seconds()
if args.processor_profiling == True:
	output_dict["Process_Write_Time"] = process_write_time.total_seconds()









with open(filename, 'w') as outfile: 
    json.dump(output_dict, outfile, indent=4)
 






