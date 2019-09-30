#! /bin/bash
#pmIp="192.168.10.102"
# Capture the resource utilization profile of the Virtural Machine, the 
# docker container, as well as the processes statistics inside the container. 

# The first time this is run current cpu, disk, and network storage is snapshot
# The second time this is run the differences are calculated in order to determine 
# the CPU time, Sectors read/written, and Network bytes rcv'd/transmitted 

# flags -v, -c, and -p can be used to ommit vm, container, and/or process-level metric respectively

# Notes for VM level statistics:
# CPU time is in hundreths of a second (centisecond:cs)
# Sectors read is number of sectors read, where a sector is typically 512 bytes (col 2) assumes /dev/sda1
# Sectors written (col 3) assumes /dev/sda1
# network Bytes recv'd assumes eth0 (col ?)
# network Bytes written assumes eth0 (col ?)
# col 6 cpu time for processes executing in user mode
# col 7 cpu time for processes executing in kernel mode
# col 8 cpu idle time
# col 9 cpu time waiting for I/O to complete
# col 10 cpu time servicing interrupts
# col 11 cpu time servicing soft interrupts
# col 12 number of context switches
# col 13 number of disk reads completed succesfully
# col 14 number of disk reads merged together (adjacent and merged for efficiency) 
# col 15 time in ms spent reading
# col 16 number of disk writes completed succesfully
# col 17 number of disk writes merged together (adjacent and merged for efficiency)
# col 18 time in ms spent writing

# Notes for container level statistics:
# TBD...

# Notes for process level statistics:
# TBD...
 
VM=true
CONTAINER=true
PROCESS=true

#get the flags and omit levels as requested
while [ -n "$1" ]
do
  case "$1" in
    -v) VM=false;;
    -c) CONTAINER=false;;
    -p) PROCESS=false;;
  esac
  shift
done
     

outfile=rudata_all.json
echo "{" > $outfile
epochtime=$(date +%s)

# Find the number of processes inside the container
IFS=$'\n'
PPS=(`cat /sys/fs/cgroup/pids/tasks`)
unset IFS
length=${#PPS[@]}
PIDS=$((length-2)) 

## VM level metrics

if [ $VM = true ]
then
  #echo "VM is Running!!"
  # Get CPU stats
  CPU=(`cat /proc/stat | grep '^cpu '`)
  unset CPU[0]
  CPUUSR=${CPU[1]}
  CPUNICE=${CPU[2]}
  CPUKRN=${CPU[3]}
  CPUIDLE=${CPU[4]}  
  CPUIOWAIT=${CPU[5]}
  CPUIRQ=${CPU[6]}
  CPUSOFTIRQ=${CPU[7]}
  CPUSTEAL=${CPU[8]}
  CPUTOT=`expr $CPUUSR + $CPUKRN`
  CONTEXT=(`cat /proc/stat | grep '^ctxt '`)
  unset CONTEXT[0]
  CSWITCH=${CONTEXT[1]} 

  # Get disk stats
  COMPLETEDREADS=0
  MERGEDREADS=0
  SR=0
  READTIME=0
  COMPLETEDWRITES=0
  MERGEDWRITES=0
  SW=0
  WRITETIME=0

  IFS=$'\n'
  CPU_TYPE=(`cat /proc/cpuinfo | grep 'model name' | cut -d":" -f 2 | sed 's/^ *//'`)
  CPU_MHZ=(`cat /proc/cpuinfo | grep 'cpu MHz' | cut -d":" -f 2 | sed 's/^ *//'`)
  CPUTYPE=${CPU_TYPE[0]}
  CPUMHZ=${CPU_MHZ[0]}
  DISK=($(cat /proc/diskstats | grep 'd.[0-9]') )

  unset IFS
  length=${#DISK[@]}
  if [ $length > 1 ]
  then
    for (( i=0 ; i < length; i++ ))
    do
      currdisk=(${DISK[$i]})
      COMPLETEDREADS=`expr ${currdisk[3]} + $COMPLETEDREADS`
      MERGEDREADS=`expr ${currdisk[4]} + $MERGEDREADS`
      SR=`expr ${currdisk[5]} + $SR`
      READTIME=`expr ${currdisk[6]} + $READTIME`
      COMPLETEDWRITES=`expr ${currdisk[7]} + $COMPLETEDWRITES`
      MERGEDWRITES=`expr ${currdisk[8]} + $MERGEDWRITES`
      SW=`expr ${currdisk[9]} + $SW`
      WRITETIME=`expr ${currdisk[10]} + $WRITETIME`
    done
  else
    DISK=(`cat /proc/diskstats | grep 'xvda1'`)
    unset DISK[0]
    COMPLETEDREADS=${DISK[3]}
    MERGEDREADS=${DISK[4]}
    SR=${DISK[5]}
    READTIME=${DISK[6]}
    COMPLETEDWRITES=${DISK[7]}
    MERGEDWRITES=${DISK[8]}
    SW=${DISK[9]}
    WRITETIME=${DISK[10]}
  fi

  # Get network stats
  BR=0
  BT=0
  IFS=$'\n'
  NET=($(cat /proc/net/dev | grep 'eth0') )
  unset IFS
  length=${#NET[@]}
  #Parse multiple network adapters if they exist
  if [ $length > 1 ]
  then
    for (( i=0 ; i < length; i++ ))
    do
      currnet=(${NET[$i]})
      BR=`expr ${currnet[1]} + $BR`
      BT=`expr ${currnet[9]} + $BT`
    done
  else
    NET=(`cat /proc/net/dev | grep 'eth0'`)
    space=`expr substr $NET 6 1`
    # Need to determine which column to use based on spacing of 1st col
    if [ -z $space  ]
    then
      BR=${NET[1]}
      BT=${NET[9]}
    else
      BR=`expr substr $NET 6 500`
      BT=${NET[8]}
    fi
  fi
  LOADAVG=(`cat /proc/loadavg`)
  LAVG=${LOADAVG[0]}

  # Get Memory Stats
  MEMTOT=$(cat /proc/meminfo | grep 'MemTotal' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB

  MEMFREE=$(cat /proc/meminfo | grep 'MemFree' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB

  BUFFERS=$(cat /proc/meminfo | grep 'Buffers' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB

  CACHED=$(cat /proc/meminfo | grep -w 'Cached' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB


  vmid="unavailable"



  
  echo "  \"currentTime\": $epochtime," >> $outfile
  echo "  \"vMetricType\": \"VM level\"," >> $outfile
  ## print VM level data 
  echo "  \"vCpuTime\": $CPUTOT," >> $outfile
  echo "  \"vDiskSectorWrites\": $SW," >> $outfile
  echo "  \"vNetworkBytesRecvd\": $BR," >> $outfile
  echo "  \"vNetworkBytesSent\": $BT," >> $outfile
  echo "  \"vCpuTimeUserMode\": $CPUUSR," >> $outfile
  echo "  \"vCpuTimeKernelMode\": $CPUKRN," >> $outfile
  echo "  \"vCpuIdleTime\": $CPUIDLE," >> $outfile
  echo "  \"vCpuTimeIOWait\": $CPUIOWAIT," >> $outfile
  echo "  \"vCpuTimeIntSrvc\": $CPUIRQ," >> $outfile
  echo "  \"vCpuTimeSoftIntSrvc\": $CPUSOFTIRQ," >> $outfile
  echo "  \"vCpuContextSwitches\": $CSWITCH," >> $outfile
  echo "  \"vCpuNice\": $CPUNICE," >> $outfile
  echo "  \"vCpuSteal\": $CPUSTEAL," >> $outfile
  echo "  \"vDiskSuccessfulReads\": $COMPLETEDREADS," >> $outfile
  echo "  \"vDiskMergedReads\": $MERGEDREADS," >> $outfile
  echo "  \"vDiskReadTime\": $READTIME," >> $outfile
  echo "  \"vDiskSuccessfulWrites\": $COMPLETEDWRITES," >> $outfile
  echo "  \"vDiskMergedWrites\": $MERGEDWRITES," >> $outfile
  echo "  \"vDiskWriteTime\": $WRITETIME," >> $outfile

  echo "  \"vMemoryTotal\": $MEMTOT," >> $outfile     # KB
  echo "  \"vMemoryFree\": $MEMFREE," >> $outfile     # KB
  echo "  \"vMemoryBuffers\": $BUFFERS," >> $outfile  # KB
  echo "  \"vMemoryCached\": $CACHED," >> $outfile    # KB


  echo "  \"vLoadAvg\": $LAVG," >> $outfile
  echo "  \"vId\": \"$vmid\"," >> $outfile
  echo "  \"vCpuType\": \"$CPUTYPE\"," >> $outfile
  echo "  \"vCpuMhz\": \"$CPUMHZ\"," >> $outfile
fi


## Container level metrics
if [ $CONTAINER = true ]
then
  #echo "CONTAINER is Running!!"
  echo "  \"cMetricType\": \"Container level\"," >> $outfile

  # Get CPU stats

  CPUUSRC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'user' | cut -d" " -f 2) # in cs

  CPUKRNC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'system' | cut -d" " -f 2) # in cs

  CPUTOTC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage) # in ns


  IFS=$'\n'

  PROS=(`cat /proc/cpuinfo | grep 'processor' | cut -d":" -f 2`)
  NUMPROS=${#PROS[@]}


  # Get disk stats

  # Get disk major:minor numbers, store them in disk_arr
  # Grep disk first using lsblk -a, find type "disk" and then find the device number
  IFS=$'\n'
  lines=($(lsblk -a | grep 'disk'))
  unset IFS
  disk_arr=()
  for line in "${lines[@]}"
  do 
    temp=($line)
    disk_arr+=(${temp[1]})
  done


  arr=($(cat /sys/fs/cgroup/blkio/blkio.sectors | grep 'Total' | cut -d" " -f 2))

  # if arr is empty, then assign 0; else, sum up all elements in arr
  if [ -z "$arr" ]; then
    SRWC=0
  else
    SRWC=$( ( IFS=+; echo "${arr[*]}" ) | bc )
  fi


  IFS=$'\n'
  arr=($(cat /sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes  | grep 'Read')) # in Bytes
  unset IFS

  if [ -z "$arr" ]; then
    BRC=0
  else
    BRC=0
    for line in "${arr[@]}"
    do 
      temp=($line)
      for elem in "${disk_arr[@]}"
      do 
        if [ "$elem" == "${temp[0]}" ]
        then
          BRC=$(echo "${temp[2]} + $BRC" | bc)
        fi
      done
    done
  fi



  IFS=$'\n'
  arr=($(cat /sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes  | grep 'Write')) # in Bytes
  unset IFS

  if [ -z "$arr" ]; then
    BWC=0
  else
    BWC=0
    for line in "${arr[@]}"
    do 
      temp=($line)
      for elem in "${disk_arr[@]}"
      do 
        if [ "$elem" == "${temp[0]}" ]
        then
          BWC=$(echo "${temp[2]} + $BWC" | bc)
        fi
      done
    done
  fi


  # Get network stats

  NET=(`cat /proc/net/dev | grep 'eth0'`)
  NRC=${NET[1]}  # bytes received
  [[ -z "$NRC" ]] && NRC=0

  NTC=${NET[9]}  # bytes transmitted
  [[ -z "$NTC" ]] && NTC=0


  #Get container ID
  CIDS=$(cat /etc/hostname)

  # Get memory stats
  MEMUSEDC=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
  MEMMAXC=$(cat /sys/fs/cgroup/memory/memory.max_usage_in_bytes)

  unset IFS
  CPUPERC=(`cat /sys/fs/cgroup/cpuacct/cpuacct.usage_percpu`) # in ns, 0, 1, 2, 3 elements


  # print container level data
  echo "  \"cCpuTime\": $CPUTOTC," >> $outfile     # ns
  echo "  \"cNumProcessors\": $NUMPROS," >> $outfile
  echo "  \"cProcessorStats\": {" >> $outfile
  for (( i=0; i<NUMPROS; i++ ))
  do 
    echo "  \"cCpu${i}TIME\": ${CPUPERC[$i]}, " >> $outfile
  done
  echo "  \"cNumProcessors\": $NUMPROS" >> $outfile
  echo "  }," >> $outfile

  echo "  \"cCpuTimeUserMode\": $CPUUSRC," >> $outfile    # cs
  echo "  \"cCpuTimeKernelMode\": $CPUKRNC," >> $outfile  # cs

  echo "  \"cDiskSectorIO\": $SRWC," >> $outfile
  echo "  \"cDiskReadBytes\": $BRC," >> $outfile
  echo "  \"cDiskWriteBytes\": $BWC," >> $outfile

  echo "  \"cNetworkBytesRecvd\": $NRC," >> $outfile
  echo "  \"cNetworkBytesSent\": $NTC," >> $outfile

  echo "  \"cMemoryUsed\": $MEMUSEDC," >> $outfile
  echo "  \"cMemoryMaxUsed\": $MEMMAXC," >> $outfile


  echo "  \"cId\": \"$CIDS\"," >> $outfile
  echo "  \"cNumProcesses\": $PIDS," >> $outfile

  echo "  \"pMetricType\": \"Process level\"," >> $outfile
fi

## Process level metrics

if [ $PROCESS = true ]
then
  #echo "PROCESS is Running!!"
  # For each process, parse the data

  # command cat $outfile in the last line of the script
  # and ./rudataall.sh are counted as 2 extra processes, so -2 here for PIDS

  echo "  \"pProcesses\": [" >> $outfile

  for (( i=0; i<PIDS; i++ ))
  do 
    pid=${PPS[i]}
    #check if pid still exists
    STAT=(`cat /proc/$pid/stat 2>/dev/null`)
    if (( ${#STAT[@]} )); then
	  PID=${STAT[0]}
	  PSHORT=$(echo $(echo ${STAT[1]} | cut -d'(' -f 2 ))
	  PSHORT=${PSHORT%?}
	  NUMTHRDS=${STAT[19]}

	  # Get process CPU stats
	  UTIME=${STAT[13]}
	  STIME=${STAT[14]}
	  CUTIME=${STAT[15]}
	  CSTIME=${STAT[16]}
	  TOTTIME=$((${UTIME} + ${STIME}))

	  # context switch  !! need double check result format
	  VCSWITCH=$(cat /proc/$pid/status | grep "^voluntary_ctxt_switches" | \
        cut -d":" -f 2 | sed 's/^[ \t]*//') 
	  NVCSSWITCH=$(cat /proc/$pid/status | grep "^nonvoluntary_ctxt_switches" | \
        cut -d":" -f 2 | sed 's/^[ \t]*//') 

	  # Get process disk stats
	  DELAYIO=${STAT[41]}

	  # Get process memory stats
	  VSIZE=${STAT[22]} # in Bytes
	  RSS=${STAT[23]} # in pages

	  PNAME=$(cat /proc/$pid/cmdline | tr "\0" " ")
	  PNAME=${PNAME%?}

	  # print process level data
	  echo "  {" >> $outfile
	  echo "  \"pId\": $PID, " >> $outfile
	  echo "  \"pCmdLine\":\"$PNAME\", " >> $outfile                    # process cmdline
	  echo "  \"pName\":\"$PSHORT\", " >> $outfile          # process cmd short version
	  echo "  \"pNumThreads\": $NUMTHRDS, " >> $outfile
	  echo "  \"pCpuTimeUserMode\": $UTIME, " >> $outfile         # cs
	  echo "  \"pCpuTimeKernelMode\": $STIME, " >> $outfile       # cs
	  echo "  \"pChildrenUserMode\": $CUTIME, " >> $outfile       # cs
	  echo "  \"pChildrenKernelMode\": $CSTIME, " >> $outfile     # cs
	  echo "  \"pVoluntaryContextSwitches\": $VCSWITCH, " >> $outfile
	  echo "  \"pNonvoluntaryContextSwitches\": $NVCSSWITCH, " >> $outfile
	  echo "  \"pBlockIODelays\": $DELAYIO, " >> $outfile         # cs
	  echo "  \"pVirtualMemoryBytes\": $VSIZE, " >> $outfile
	  echo "  \"pResidentSetSize\": $RSS " >> $outfile            # page
	  echo "  }, " >> $outfile
   fi	
  done
  echo "  {\"cNumProcesses\": $PIDS}" >> $outfile
  echo "  ]" >> $outfile
fi

echo "}" >> $outfile

cat $outfile





