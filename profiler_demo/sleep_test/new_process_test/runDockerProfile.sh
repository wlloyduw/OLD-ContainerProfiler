#!/bin/bash

NWELLS=96
# mount the container profiler directory on host machine into /data directory in container
# then start the sysbench container
#DOCKERCMD="docker run -d --rm -v /home/ubuntu/profiler_demo/container_profiler:/data -e NWELLS=$NWELLS sysbench"
DOCKERCMD="docker run -d --rm -v /home/ravschoo/Documents/Capstone/Capstone/ContainerProfiler/profiler_demo/sleep_test/new_process_test:/data -e NWELLS=$NWELLS primesieve"
runCmd=/data/processpack.sh
deltaT=1
$DOCKERCMD bash -c "/data/ru_profiler.sh $runCmd $deltaT"





