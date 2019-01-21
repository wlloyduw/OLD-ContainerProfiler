# ContainerProfiler

ContainerProfiler includes bash scripts **rudataall.sh** to profile the resource utilization on VM level, container level and process level and **deltav2.sh** to compute the delta statistics of resource utilization between two time instances. 

**Authors:** Wes Lloyd & Huazeng Deng & Ling-hong Hung

**Version:** 0.2

**GitHub:**  https://github.com/wlloyduw/ContainerProfiler

**License:** Copyright.




Function Reference
======

**deltav2**.sh calculates the delta from 2 json files produced by **rudataall.sh**

It writes the deltas to stdout in json format and the missing fields to stderr

####Usage:
```bash
deltav2.sh file1.json file2.json 2>missing.txt 1>delta.json
```
Test file and scripts are found in testFiles

####Description
Basically it loops through file1 to find key : numeric_value pairs and store them in an associative array. It then loops through file2 to print out the json elements and calculate deltas. Missing values in file1 are printed here and a second key numericValue associative array is mad. A third loop then searches through the first associative array to fine missing values in file2. 

As long as there is no more than one key : value pair per line in the json files and the key is unique (i.e. doesn't depend on the structure of the higher order json objects), the script should work fine. It is tolerant of order permutations, new or different fields, and missing lines but depends on file2 being valid json.

Metrics Description 
=======

The text below describes the metrics captured by the script **rudataall.sh** for profiling resource utilization on the 
virtual machine (VM) level, container level and process level. A complete metrics description spreadsheet can be found at 
https://github.com/wlloyduw/ContainerProfiler/blob/master/metrics_description_for_rudataall.xlsx 

VM Level Metrics
----------------

  *Parameters*
    
     
        vCpuTime : centisecond (cs)
          Total CPU time (cpu_user+cpu_kernel)in hundreths of a second.
        
        vCpuTimeUserMode: centisecond (cs)
          CPU time for processes executing in user mode.
          
        vCpuTimeKernelMode: centisecond (cs)
          CPU time for processes executing in kernel mode.
          
        vCpuIdleTime: centisecond (cs)
          CPU idle time.
          
        vCpuTimeIOWait: centisecond (cs)
          CPU time waiting for I/O to complete.
        
        vCpuTimeIntSrvc: centisecond (cs)
          CPU time servicing interrupts.
          
        vCpuTimeSoftIntSrvc: centisecond (cs)
          CPU time servicing soft interrupts.
          
        vCpuContextSwitches:
          The total number of context switches across all CPUs.
          
        vCpuNice: centisecond (cs)
          Time spent with niced processes executing in user mode.
        
        vCpuSteal: centisecond (cs)
          Time stolen by other operating systems running in a virtual environment.
          
        vCpuType:
          The common name of the processor, including its project name.
        
        vCpuMhz: megahertz
          The precise speed in MHz for the processor to the thousandths decimal place.
        
        vDiskSectorReads: sector
          Sectors read is number of sectors read, where a sector is typically 512 bytes, assumes /dev/sda1
          
        vDiskSectorWrites: sector
          Sectors written is number of sectors written, assumes /dev/sda1.
        
        vDiskSuccessfulReads:
          Number of disk reads completed succesfully.
          
        vDiskMergedReads:
          Number of disk reads merged together (adjacent and merged for efficiency).
          
        vDiskReadTime: millisecond (ms)
          Time spent reading.
          
        vDiskSuccessfulWrites:
          Number of disk writes completed succesfully.
          
        vDiskMergedWrites:
          Number of disk writes merged together (adjacent and merged for efficiency).
          
        vDiskWriteTime: millisecond (ms)
          Time spent writing.
          
        vMemoryTotal: kilobyte (KB)
          Total amount of usable RAM.
        
        vMemoryFree: kilobyte (KB)
          The amount of physical RAM left unused by the system.
          
        vMemoryBuffers: kilobyte (KB)
          The amount of temporary storage for raw disk blocks.
          
        vMemoryCached: kilobyte (KB)
          The amount of physical RAM used as cache memory.
        
        vNetworkBytesRecvd: byte
          Network Bytes recv'd assumes eth0.
          
        vNetworkBytesSent: byte
          Network Bytes written assumes eth0.
        
        vLoadAvg:
          Load average in regard to both the CPU and IO over last 1 minute.
          
        vId:
          VM ID (default is "unavailable").
          
        currentTime: second (s)
          Number of seconds that have elapsed since January 1, 1970 (midnight UTC/GMT). 
          
          
Container Level Metrics
----------------

  *Parameters* 
    
        cCpuTime : nanosecond (ns)
          Total CPU time consumed by all tasks in this cgroup (including tasks lower in the 
          hierarchy).
          
        cProcessorStats:
          Self-defined parameter.
          
        cCpu${i}TIME: nanosecond (ns)
          CPU time consumed on each CPU by all tasks in this cgroup (including tasks lower 
          in the hierarchy).
          
        cNumProcessors:
          Number of CPU processors.
        
        cCpuTimeUserMode: centisecond (cs)
          CPU time consumed by tasks in user mode in this cgroup.
        
        cCpuTimeKernelMode: centisecond (cs)
          CPU time consumed by tasks in kernel mode in this cgroup.
          
        cDiskSectorIO: sector
          Number of sectors transferred to or from specific devices by a cgroup.
          
        cDiskReadBytes: byte
          Number of bytes transferred from specific devices by a cgroup.
          
        cDiskWriteBytes: byte
          Number of bytes transferred to specific devices by a cgroup.
        
        cMemoryUsed: byte
          Total current memory usage by processes in the cgroup.
          
        cMemoryMaxUsed: byte
          Maximum memory used by processes in the cgroup.
          
        cNetworkBytesRecvd: byte
          The number of bytes each interface has received.
          
        cNetworkBytesSent: byte
          The number of bytes each interface has sent.
          
        cId:
          Container ID.
        

Process Level Metrics
----------------

  *Parameters*
  
    
        pProcesses:
          Process information inside a container. Self-defined parameter.
          
        pId:
          Process ID.
          
        pNumThreads:
          Number of threads in this process.
        
        pCpuTimeUserMode: clocktick
          Amount of time that this process has been scheduled in user mode, measured in clock ticks 
          (divide by sysconf(_SC_CLK_TCK)).
          
        pCpuTimeKernelMode: clocktick
          Amount of time that this process has been scheduled in kernel mode, measured in clock ticks
          (divide by sysconf(_SC_CLK_TCK)).
          
        pChildrenUserMode: clocktick
          Amount of time that this process's waited-for children have been scheduled in user mode, 
          measured in clock ticks.
          
        pChildrenKernelMode: clocktick
          Amount of time that this process's waited-for children have been scheduled in kernel mode, 
          measured in clock ticks.
          
        pVoluntaryContextSwitches:
          Number of voluntary context switches.
          
        pNonvoluntaryContextSwitches:
          Number of involuntary context switches.
          
        pBlockIODelays: clocktick
          Aggregated block I/O delays, measured in clock ticks.
        
        pVirtualMemoryBytes: byte
          Virtual memory size in bytes.
          
        pResidentSetSize: page
          Resident Set Size: number of pages the process has in real memory.  This is just the pages 
          which count toward text, data, or stack space.  This does not include pages which have not
          been demand-loaded in, or which are swapped out.
        
        pNumProcesses:
          Number of processes inside a container.
