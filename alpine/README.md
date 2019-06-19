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
