#!/bin/bash

cd ../..
cp rudataall.sh ./profiler_demo/sleep_test
cd profiler_demo/sleep_test
mkdir ~/.config/graphing_tool
cp graph_generation_config.shlib ~/.config/graphing_tool
cp graph_generation_config.cfg ~/.config/graphing_tool


#takes care of all dependencies needed for csv creation, delta creation, plotly graph creation
sudo apt install python -y
sudo apt-get install python-pip -y
sudo pip install numpy
sudo pip install pandas
sudo pip install plotly
sudo pip install matplotlib 
sudo apt-get install python-tk -y
sudo pip install psutil
sudo pip install requests
sudo apt install npm -y 
sudo npm install -g electron@1.8.4 orca -y 
sudo apt install libcanberra-gtk-module libcanberra-gtk3-module -y
sudo apt install libgconf-2-4 -y

