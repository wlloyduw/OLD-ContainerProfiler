# Time-Series Graphing   

# Table of Contents
   * [FAQ](#faq)
      * [General](#general)
         * [Why should I use these Graphing Scripts?](#why-should-i-use-these-graphing-scripts)
      * [Usage](#usage)
         * [How do you graph JSON from the Container Profiler?](#how-do-you-graph-json-from-the-container-profiler)
         * [How do I control which metrics are delta'd and which are raw?](#how-do-I-control-which-metrics-are-delta'd-and-which-are-raw)
      * [GENERAL INFORMATION](#general-information)
      * [Setup and Dependencies](#setup-and-dependencies)
         * [Linux](#linux)
      * [Graphing](#graphing)
	 * [Metrics](#metrics)
	 * [Flags](#flags)
	 * [Example Runs](#example-runs)

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
```bash
python graph_all.py -f ./json
```
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

After you have installed the dependencies on your machine, Graphs of any Container Profiler JSON folder(s) can be made. Basic Time-Series graphing of all metrics of a run can be performed with the command:
```bash
python graph_all.py -f ./json.
```
### Flags

| **Flag** | **Type** | **Description** |
| --------- | ------------------- |--------------- |
| -f | Space Delimited String |This flag is mandatory. Following this flag in the command line will be a space delimited list of paths to JSON folders |
| -s | int | This flag is non-mandatory and defaults to 0. Following this flag is a time interval that determines when to apply a delta operation on the JSON files |
| -m | Space Delimited String | This flag is non-mandatory. Following this flag is a space delimited list of Container Profiler metrics that you want to graph |
| -d | boolean | This flag is non-mandatory and defaults to False. | If this flag is included then if your browser is supported, all graphs will be created in your browser as well as being exported locally |

### Example Runs

Creating Graphs from two folders
```bash
python graph_all.py -f dir_path dir_path2
```
Creating Graphs with a delta interval of 5 seconds
```bash
python graph_all.py -f dir_path -s 5
```
Creating Graphs with a delta interval of 10 seconds
```bash
python graph_all.py -f dir_path -s 10
```
Creating Graphs only with the metrics of currentTime, cId, and vCpuTime
```bash
python graph_all.py -f dir_path -m currentTime cId vCpuTime
```
Creating graphs from multiple folders with only metrics from cId and vCpuTime with a sampling interval of 60
```bash
python graph_all.py -f dir_path dir_path1 dir_path2 -m cId vCpuTime -s 60
```



