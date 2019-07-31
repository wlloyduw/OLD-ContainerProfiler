#!/bin/bash
# This script runs a test for 2 cpu bounded processes and a memory bounded process

echo "This is the start for testing..."
echo "The fisrt process: "
echo ""
echo 
echo
sysbench --test=cpu --cpu-max-prime=40000 --max-requests=10000  --num-threads=2 run


#echo
#echo
#echo
#echo "The second process: "
#echo
#echo
#echo

#/data/stress_ng.sh

#echo
#echo
#echo
#echo "The last process: "
#echo
#echo
#echo
#sysbench  --test=memory --memory-block-size=1M --memory-total-size=100G  --num-threads=1 run

#echo
#echo
#echo
#echo "This is the end for testing."
