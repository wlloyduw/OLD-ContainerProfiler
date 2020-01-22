# Time-Series Graphing   

# Table of Contents
   * [FAQ](#faq)
      * [General](#general)
         * [Why should I use these Graphing Scripts?](#why-should-i-use-these-graphing-scripts)
      * [Usage](#usage)
         * [How do you graph JSON from the Container Profiler?](#how-do-i-graph-json-from-the-container-profiler)
         * [How do I control which metrics are delta'd and which are raw?](#how-do-I-control-which-metrics-are-delta'd-and-which-are-raw)
   * [MANUAL](#manual)
      * [GENERAL INFORMATION](#general-information)
      * [Setup and Dependencies](#setup-and-dependencies)
         * [Linux](#linux)
      * [Graphing](#graphing)
	 * [Metrics](#metrics)
	 * [Flags](#flags)

# FAQ
## General

### Why should I use these Graphing Scripts?

#### Data deltas are done for you

The JSON from the ContainerProfiler is the raw data collected from many linux metrics aimed to collect information about your Computer's resource utilization. So while there are many alternatives
to creating graphical visualizations with the collected JSON, certain metrics from the JSON need to have a delta operation done on them. This is because not all linux resource contention metrics are the same. Some are constant values as as the maximum memory in your computer, some are dynamic and will raise or fall such as amount of memory being used currently, and some will only ever rise in value such as the number of write operations performed or time.

These Graphing Scripts by default will delta only metrics that are non-dynamic, and non-static, such that what you see will be a time-series visualization. If you just used any graphing tool with the JSON from the container profiler without any modifications, many of the created graphs may just be straight upward lines.

## Usage

### How do you graph JSON from the Container Profiler?

Graphing JSON from the Container Profiler can be done by calling the graph_all.py script in the Graphing Directory of the Container Profiler repository.
This can be done with any JSON from the Container Profiler, by included by default is a JSON folder created with the Container Profiler on a simple pgbench test.

To create time-series graphs using this sample JSON folder, from the command line you can call:

python graph_all.py -f ./json  

### How do I control which metrics are delta'd and which are raw?
Included in the repository is a config.ini file named delta_configuration.ini
Included is a list of every metric in the Container Profiler currently and in the format of one of the three:

metric=numeric-delta
metric=non-delta
metric=non-numeric

numeric-delta means that this metric should be delta'd
non-delta means that this metric should be left raw
non-numeric means that the recorded metric is not a numeric value, and usually is a string

If you want a metric to be a delta value instead or left raw, you can find it in this configuration file and change it to be equal to a value of numeric-delta or non-delta.

# MANUAL
## GENERAL INFORMATION

The Container Profiler has included Graphing Scripts which can create time-series graph visualizations of linux resource contention metrics.
These Graphs are saved locally and can be created in a browser dynamically.

## Setup and Dependencies

### Linux
<a name="DockerInstall"></a>
1\. Update your package manager index. 

On Debian based distros such as Ubuntu the package manager is apt-get
```bash
sudo apt-get -y update
```

Install Python and Python-pip
```bash
sudo apt install python
sudo apt-get install python-pip
Install Pandas
```bash
sudo pip install pandas
```
Install Plotly and Matplotlib
```bash
sudo pip install plotly
sudo pip install matplotlib
```
Install Tkinter (for dynamic graph creation)
```bash
sudo apt-get install python-tk
```
Install Orca dependcies and Orca(needed for image exports)
```bash
sudo pip install psutil
sudo pip install requests
sudo apt install npm
sudo npm install -g electron@1.8.4 orca
```
Additional dependencies that may be needed incase you are on a 64bit machine with 32-bit software
```bash
sudo apt install libcanberra-gtk-module libcanberra-gtk3-module
sudo apt install libgconf-2-4

```

## Graphing

After you have installed the dependencies on your machine, Graphs of any Container Profiler JSON can be made. All metrics in a non-modified format will be created using the command
python graph_all.py -f ./json.

### Metrics

The text below describes the metrics captured by the script **rudataall.sh** for profiling resource utilization on the 
virtual machine (VM) level, container level and process level. A complete metrics description spreadsheet can be found at 
https://github.com/wlloyduw/ContainerProfiler/blob/master/metrics_description_for_rudataall.xlsx 

VM Level Metrics
----------------


| **Attribute** | **Description** |
| ------------- | --------------- |
| vCpuTime | Total CPU time (cpu_user+cpu_kernel) in centiseconds (cs) (hundreths of a second) |
| vCpuTimeUserMode | CPU time for processes executing in user mode in centiseconds (cs) |  
| vCpuTimeKernelMode | CPU time for processes executing in kernel mode in centiseconds (cs) |  
| vCpuIdleTime | CPU idle time in centiseconds (cs) |  
| vCpuTimeIOWait | CPU time waiting for I/O to complete in centiseconds (cs) |  
| vCpuTimeIntSrvc | CPU time servicing interrupts in centiseconds (cs) |  
| vCpuTimeSoftIntSrvc | CPU time servicing soft interrupts in centiseconds (cs) |  
| vCpuContextSwitches | The total number of context switches across all CPUs |  
| vCpuNice | Time spent with niced processes executing in user mode in centiseconds (cs) |  
| vCpuSteal | Time stolen by other operating systems running in a virtual environment in centiseconds (cs) |  
| vCpuType | The model name of the processor |  
| vCpuMhz | The precise speed in MHz for thee processor to the thousandths decimal place |  
| vDiskSectorReads | The number of disk sectors read, where a sector is typically 512 bytes, assumes /dev/sda1|  
| vDiskSectorWrites | The number of disk sectors written, where a sector is typically 512 bytes, assumes /dev/sda1 |  
| vDiskSuccessfulReads | Number of disk reads completed succesfully |
| vDiskMergedReads | Number of disk reads merged together (adjacent and merged for efficiency) |
| vDiskReadTime | Time spent reading from the disk in millisecond (ms) |
| vDiskSuccessfulReads | Number of disk reads completed succesfully |
| vDiskSuccessfulWrites | Number of disk writes completed succesfully |
| vDiskMergedWrites | Number of disk writes merged together (adjacent and merged for efficiency) |
| vDiskWriteTime | Time spent writing in milliseconds (ms) |
| vMemoryTotal | Total amount of usable RAM in kilobytes (KB) |
| vMemoryFree | The amount of physical RAM left unused by the system in kilobytes (KB) |
| vMemoryBuffers | The amount of temporary storage for raw disk blocks in kilobytes (KB) |
| vMemoryCached | The amount of physical RAM used as cache memory in kilobytes (KB) |
| vNetworkBytesRecvd | Network Bytes received assumes eth0 in bytes |
| vNetworkBytesSent | Network Bytes written assumes eth0 in bytes |
| vLoadAvg | The system load average as an average number of running plus waiting threads over the last minute |
| vId | VM ID (default is "unavailable") |
| currentTime | Number of seconds (s) that have elapsed since January 1, 1970 (midnight UTC/GMT) |

          
Container Level Metrics
----------------

| **Attribute** | **Description** |
| ------------- | --------------- |
| cCpuTime | Total CPU time consumed by all tasks in this cgroup (including tasks lower in the hierarchy) in nanoseconds (ns) |
| cProcessorStats | Self-defined parameter |
| cCpu${i}TIME | CPU time consumed on each CPU by all tasks in this cgroup (including tasks lower in the hierarchy) in nanoseconds (ns) |
| cNumProcessors | Number of CPU processors |
| cCpuTimeUserMode | CPU time consumed by tasks in user mode in this cgroup in centiseconds (cs) |
| cCpuTimeKernelMode | PU time consumed by tasks in kernel mode in this cgroup in centiseconds (cs) |
| cDiskSectorIO | Number of sectors transferred to or from specific devices by a cgroup |
| cDiskReadBytes | Number of bytes transferred from specific devices by a cgroup in bytes |
| cDiskWriteBytes | Number of bytes transferred to specific devices by a cgroup in bytes |
| cMemoryUsed | Total current memory usage by processes in the cgroup in bytes |
| cMemoryMaxUsed | Maximum memory used by processes in the cgroup in bytes |
| cNetworkBytesRecvd | The number of bytes each interface has received |
| cNetworkBytesSent | The number of bytes each interface has sent |
| cId | Container ID |

Process Level Metrics
----------------

| **Attribute** | **Description** |
| ------------- | --------------- |
| pId | Process ID |  
| pNumThreads | Number of threads in this process |  
| pCpuTimeUserMode | Total CPU time this process was scheduled in user mode, measured in clock ticks (divide by sysconf(\_SC_CLK_TCK)) |  
| pCpuTimeKernelMode | Total CPU time this process was scheduled in kernel mode, measured in clock ticks (divide by sysconf(\_SC_CLK_TCK)) |
| pChildrenUserMode | Total time children processes of the parent were scheduled in user mode, measured in clock ticks |
| pChildrenKernelMode | Total time children processes of the parent were scheduled in kernel mode, measured in clock ticks |
| pVoluntaryContextSwitches | Number of voluntary context switches | 
| pNonvoluntaryContextSwitches | Number of involuntary context switches | 
| pBlockIODelays | Aggregated block I/O delays, measured in clock ticks | 
| pVirtualMemoryBytes | Virtual memory size in bytes | 
| pResidentSetSize | Resident Set Size: number of pages the process has in real memory.  This is just the pages which count toward text, data, or stack space.  This does not include pages which have not been demand-loaded in, or which are swapped out | 
| pNumProcesses | Number of processes inside a container | 

### Flags

| **Flag** | **Type** | **Description** |
| --------- | ------------------- |--------------- |
| -f | Space Delimited String |This flag is mandatory. Following this flag in the command line will be a space delimited list of paths to JSON folders |
| -s | int | This flag is non-mandatory and defaults to 0. Following this flag is a time interval that determines when to apply a delta operation on the JSON files |
| -m | Space Delimited String | This flag is non-mandatory. Following this flag is a space delimited list of Container Profiler metrics that you want to graph |
| -d | boolean | This flag is non-mandatory and defaults to False. | If this flag is included then if your browser is supported, all graphs will be created in your browser as well as being exported locally |



