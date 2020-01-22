# Time-Series Graphing - Python Plotly

The Container Profiler has included Graphing Scripts which can create Graph representations of the resource contention metrics.
These Graphs are saved locally and can be created in a browser dynamically.

### Getting Started

To use the Graphing Scripts, Below are all the required dependencies by running these commands at the command line.
python&nbsp;
python-pip&nbsp;
numpy&nbsp;
pandas&nbsp;
plotly&nbsp;
matplotlib&nbsp;
python-tk&nbsp;
psutil&nbsp;
requests
npm &nbsp;
orca&nbsp;
libcanberra-gtk-module&nbsp; 
libcanberra-gtk3-module&nbsp;
libgconf-2-4&nbsp;
 
### Example run 

Included by default in this directory is a folder with sample JSON from a prior experiment using the Container Profiler.&nbsp; 
We can create Sample graphs with this json by calling:

python graph_all.py -f ./json

#### Example run Output

[image here]

Two new directories are created:
one named graph_all_json which holds all the JSON information of the json directory after being delta'd. 
The other named vm_container_images which is where all the new graph images are exported to.
&nbsp;

### Mandatory and Optional flags 

| **Flag** | **Type** | **Description** |
| --------- | --------------- |
| -f | Space Delimited String |This flag is mandatory. Following this flag in the command line will be a space delimited list of paths to JSON folders |
| -s | int | This flag is non-mandatory and defaults to 0. Following this flag is a time interval that determines when to apply a delta operation on the JSON files |
| -m | Space Delimited String | This flag is non-mandatory. Following this flag is a space delimited list of Container Profiler metrics that you want to graph |
| -d | boolean | This flag is non-mandatory and defaults to False. | If this flag is included then if your browser is supported, all graphs will be created in your browser as well as being exported locally |
&nbsp;
