# Time-Lapse Graphing - Python Plotly

The Container Profiler has included Graphing Scripts which can create Graph representations of the resource contention metrics.
These Graphs are saved locally and can be created in a browser dynamically.

### Getting Started

To use the Graphing Scripts, Below are all the dependencies needed which can be installed by running these commands at the command line.
sudo apt install python
sudo apt-get install python-pip
sudo pip install numpy
sudo pip install pandas
sudo pip install plotly
sudo pip install matplotlib
sudo apt-get install python-tk
sudo pip install psutil
sudo pip install requests
sudo apt install npm
sudo npm install -g electron@1.8.4 orca
sudo apt install libcanberra-gtk-module libcanberra-gtk3-module
sudo apt install libgconf-2-4
 
### Example run 

Included by default in this directory is a folder with sample JSON from a prior experiment using the Container Profiler.
we can create the graphs for this json by calling:

python graph_all.py -f ./json

#### Example run Output

$ python graph_all.py -f ./json
making delta_json_gen script
finished delta_json_gen script
running delta_json_gen  on each path given
Finished running delta_json_gen  on each path given
Creating a csv file based on dela information created
Finished Creating a csv file based on dela information created
Starting Graphing process
metrics to graph: ['cCpuTime', 'cCpuTimeKernelMode', 'cCpuTimeUserMode', 'cDiskReadBytes', 'cDiskSectorIO', 'cDiskWriteBytes', 'cId', 'cMemoryMaxUsed', 'cMemoryUsed', 'cMetricType', 'cNetworkBytesRecvd', 'cNetworkBytesSent', 'cNumProcesses', 'cNumProcessors', 'currentTime', 'pMetricType', 'vCpuContextSwitches', 'vCpuIdleTime', 'vCpuMhz', 'vCpuNice', 'vCpuSteal', 'vCpuTime', 'vCpuTimeIOWait', 'vCpuTimeIntSrvc', 'vCpuTimeKernelMode', 'vCpuTimeSoftIntSrvc', 'vCpuTimeUserMode', 'vCpuType', 'vDiskMergedReads', 'vDiskMergedWrites', 'vDiskReadTime', 'vDiskSectorReads', 'vDiskSectorWrites', 'vDiskSuccessfulReads', 'vDiskSuccessfulWrites', 'vDiskWriteTime', 'vId', 'vLoadAvg', 'vMemoryBuffers', 'vMemoryCached', 'vMemoryFree', 'vMemoryTotal', 'vMetricType', 'vNetworkBytesRecvd', 'vNetworkBytesSent']
saved image: cCpuTime.png to /home/david/ContainerProfiler/profiler_demo/sleep_test/Graphing/vm_container_images
saved image: cCpuTimeKernelMode.png to /home/david/ContainerProfiler/profiler_demo/sleep_test/Graphing/vm_container_images
...
...
saved image: vNetworkBytesRecvd.png to /home/david/ContainerProfiler/profiler_demo/sleep_test/Graphing/vm_container_images
saved image: vNetworkBytesSent.png to /home/david/ContainerProfiler/profiler_demo/sleep_test/Graphing/vm_container_images
Finished Graphing process

Two new directories are created:
one named graph_all_json which holds all the JSON information of the json directory after being delta'd. 
The other named vm_container_images which is where all the new graph images are exported to.
&nbsp;

### Mandatory and Optional flags 

| **Field** | **Description** |
| --------- | --------------- |
| -f | Followed by this flag are the path(s) to folders containing json information from the Container Profiler. This flag is mandatory. |
| -s | The delta average interva based on time. As the container Profiler cannot sample perfectly every second, we do not delta every file following the next file. Instead we aim to delta as close
to this interval as possible. Once the time interval has been passed based on the currentTime attribute in the json, it will then perform a delta based on the first json sample and the end json sample
after reaching this time interval. This flag is non-mandatory and defaults to 1 if not specified. |
| -m | This flag will allow you to choose which metrics you want to create graphs of. This flag is not mandatory and metrics used defaults to all metrics found within the json files. |
| -d | This flag determines whether you want to dynamically create the graphs in your browser or if you just want to export them. This flag is non-mandatory and may not work on all browsers |
&nbsp;
