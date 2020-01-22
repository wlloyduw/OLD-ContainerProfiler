#!/bin/bash

NWELLS=96
container_name=
host_path=
# mount the container profiler directory on host machine into /data directory in container
# then start the sysbench container
#DOCKERCMD="docker run -d --rm -v /home/ubuntu/profiler_demo/container_profiler:/data -e NWELLS=$NWELLS sysbench"
DOCKERCMD="docker run -d --rm -v $host_path:/data -e NWELLS=$NWELLS $container_name"
runCmd=/data/processpack.sh
deltaT=1
$DOCKERCMD bash -c "/data/ru_profiler.sh $runCmd $deltaT"





