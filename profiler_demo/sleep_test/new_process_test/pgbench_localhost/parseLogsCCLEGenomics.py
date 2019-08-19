#!/usr/bin/env python

import os,sys,glob,re
from datetime import datetime as dt

sample_dirs = glob.glob(sys.argv[1] + "/*")

isTime = re.compile(r"\d\d\:\d\d:\d\d")

progress = open("progress.tsv",'w')
progress.write("Sample\tTask\tTime\n")
activity = open("activity.tsv",'w')
activity.write("Sample\tTime Since Start\tMetric\tValue\n")
FMT = "%H:%M:%S"

for dir in sample_dirs:
    id = os.path.basename(dir)
    with open(dir + "/time.txt",'r') as time:
        for line in time:
            line = line.strip()
            line = line.split('\t')

            if line[0] == "Sorting":
                progress.write(id + "\tstart\t" + line[1] + "\n")
            elif line[0] == "Finished Trimming Fastq:":
                progress.write(id + "\ttrimming\t" + line[1] + "\n")
            elif line[0] == "Finished Sorting:":
                progress.write(id + "\tsorting\t" + line[1] + "\n")
            elif line[0] == "Finished Converting to Fastq":
                progress.write(id + "\tfastq\t" + line[1] + "\n")
            elif line[0] == "Taring output":
                progress.write(id + "\tkallisto\t" + line[1] + "\n")

    with open(dir + "/sar.txt",'r') as sar:
        last_blank = False
        current_header = []
        start_time = ""

        for line in sar:
            line = line.strip()
            if len(line) == 0:
                last_blank = True
            elif last_blank:
                last_blank = False
                current_header = line.split()
                if start_time == "":
                    start_time = current_header[0]
            elif line[:5] != 'Linux':

                line = line.split()

                if isTime.match(line[0]):

                    tdelta = dt.strptime(line[0], FMT) - dt.strptime(start_time, FMT)

                    if current_header[1] == "CPU":
                        activity.write("%s\t%d\tCPU %s\t%s\n" % (id,tdelta.seconds,line[1],float(line[2]) + float(line[4])))
                        if (float(line[2]) + float(line[4])) > 100.1:
                            print "Found this:", float(line[2]), float(line[4]), float(line[5]), id, dir
                    elif current_header[1] == "kbmemfree":
                        activity.write("%s\t%d\tmemused\t%s\n" % (id,tdelta.seconds,line[3]))
                    elif current_header[1] == "IFACE" and line[1] == "eth0":
                        activity.write("%s\t%d\tRecieved\t%s\n" % (id,tdelta.seconds,line[4]))
                        activity.write("%s\t%d\tTransmitted\t%s\n" % (id,tdelta.seconds,line[5]))
                    elif current_header[1] == "DEV":
                        if line[1] == "dev8-0":
                            activity.write("%s\t%d\tMain Disk Read\t%s\n" % (id,tdelta.seconds,line[3]))
                            activity.write("%s\t%d\tMain Disk Write\t%s\n" % (id,tdelta.seconds,line[4]))
                        else:
                            activity.write("%s\t%d\tSecondary Disk Read\t%s\n" % (id,tdelta.seconds,line[3]))
                            activity.write("%s\t%d\tSecondary Disk Write\t%s\n" % (id,tdelta.seconds,line[4]))


progress.close()
activity.close()
