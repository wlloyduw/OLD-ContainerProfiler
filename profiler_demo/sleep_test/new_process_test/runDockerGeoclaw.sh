#!/bin/bash
# This script converts a series of mRNA sequencing data file in FASTQ format
# to a table of UMI read counts of human genes in multiple sample conditions.



# 1 Parameters

#Docker parameters
NWELLS=96
DOCKERCMD="sudo docker run --rm -it  -v $PROFILEDIR:/.cprofiles -v $1:/data -e NWELLS=$NWELLS clawpack_geoclaw:profiler "

# 1.1 Global

TOP_DIR=/data

# 1.2 Dataset
DATA_DIR=${TOP_DIR}
BOWLRADIALDIR="${PWD}/bowl_radial"

DOCKERCMD="sudo docker run --rm -it  -v $PROFILEDIR:/.cprofiles -v $1:/data -e NWELLS=$NWELLS clawpack_geoclaw:profiler "

sysbench --test=cpu --cpu-max-prime=20000 --max-requests=0 --max-time=7 run

