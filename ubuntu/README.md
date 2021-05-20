To build
```
docker build -t biodepot/profiler:alpine_3.7 .
```

To use the alpine container

```
docker run --rm  -it -v $PWD:/.cprofiles  biodepot/profiler:alpine_3.7 sleep 10
```

If you leave out the volume mapping 

```
-v <host_dir>:/.cprofiles
```

then no profiling will take place. Otherwise the json files will appear in <host_dir>

The delta is set to 1 second by default. This can be changed by changing the DELTA environment variable i.e.

The following command collects data every 2 seconds
```
docker run --rm  -it -v $PWD:/.cprofiles -e DELTA=2 biodepot/profiler:alpine_3.7 sleep 10
```

Finally, internally the json files are stored in the /.cprofiles directory. This can be changed using the OUTPUTDIR environment variable i.e.
to have the json files written internally to /var/profiles:
```
docker run --rm  -it -v $PWD:/var/profiles -e OUTPUTDIR='/var/profiles' biodepot/profiler:alpine_3.7 sleep 10
```
This option is included on the off-chance that the default /.cprofiles is in use for something else.

### Using profiler that consists of docker inside
# To build the docker image
```
docker build -t profiler
```

# To use the container
```
docker run --rm -it -v ${PWD}:/data -e PROFILER_OUTPUT_DIR=CONTAINER_DIRECTORY profiler "YOUR_SET_OF_COMMANDS"
docker run --rm -it -v ${PWD}:/data -e PROFILER_OUTPUT_DIR=/data profiler "sleep 10"
docker run --rm -it -v ${PWD}:/data -e PROFILER_OUTPUT_DIR=/data profiler "sleep 10; ls /data"
docker run --rm -it -v ${PWD}:/data -e PROFILER_OUTPUT_DIR=/data -v /var/run/docker.sock:/var/run/docker.sock profiler "docker run --rm -v ${PWD}:/data varikmp/bwa mem -M -t 1 /data/hg19bwaidx/hg19bwaidx /data/TUMOR.bam.fq"
```

# To use already-built container image and get the delta for quick test
```
docker run --rm -it -v ${PWD}:/data -e PROFILER_OUTPUT_DIR=/data varikmp/profiler "sleep 10"
docker run --rm -it -v ${PWD}:/data varikmp/delta /data/2021_05_20_00_04_45.json /data/2021_05_20_00_04_35.json
docker run --rm -it -v ${PWD}:/data varikmp/delta /data/2021_05_20_00_04_45.json /data/2021_05_20_00_04_35.json > delta.json
```
