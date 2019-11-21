#!/bin/bash
# This script runs a test for 2 cpu bounded processes and a memory bounded process

echo "This is the start for testing..."
echo "The process: "
echo ""
echo 
echo

#some command in the container
#make all in one of the directories 
#or some script
#cd /home/clawpack

#make all
cd /home/clawpack_src/clawpack-v5.6.1/amrclaw/examples/advection_2d_blob
make all
