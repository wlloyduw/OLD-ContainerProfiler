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
 
VM=false
CONTAINER=false
PROCESS=false

#get the flags and omit levels as requested
if [ $# -eq 0 ]
then
  VM=true;CONTAINER=true;PROCESS=true
else
  while [ -n "$1" ]
  do
    case "$1" in
      -v) VM=true;;
      -c) CONTAINER=true;;
      -p) PROCESS=true;;
    esac
    shift
  done
fi    

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
  T_CPUUSR=$(date +%s%N)
  CPUNICE=${CPU[2]}
  T_CPUNICE=$(date +%s%N)
  CPUKRN=${CPU[3]}
  T_CPUKRN=$(date +%s%N)
  CPUIDLE=${CPU[4]}  
  T_CPUIDLE=$(date +%s%N)
  CPUIOWAIT=${CPU[5]}
  T_CPUIOWAIT=$(date +%s%N)
  CPUIRQ=${CPU[6]}
  CPUSOFTIRQ=${CPU[7]}
  T_CPUSOFTIRQ=$(date +%s%N)
  CPUSTEAL=${CPU[8]}
  T_CPUSTEAL=$(date +%s%N)
  CPUTOT=`expr $CPUUSR + $CPUKRN`
  T_CPUTOT=$(date +%s%N)
  CONTEXT=(`cat /proc/stat | grep '^ctxt '`)
  unset CONTEXT[0]
  CSWITCH=${CONTEXT[1]}
  T_CSWITCH=$(date +%s%N) 

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
  T_CPUTYPE=$(date +%s%N)
  CPUMHZ=${CPU_MHZ[0]}
  T_CPUMHZ=$(date +%s%N)
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
    T_COMPLETEDREADS=$(date +%s%N)
    T_MEGEDREADS=$(date +%s%N)
    T_SR=$(date +%s%N)
    T_READTIME=$(date +%s%N)
    T_COMPLETEDWRITES=$(date +%s%N)
    T_MERGEDWRITES=$(date +%s%N)
    T_SW=$(date +%s%N)
    T_WRITETIME=$(date +%s%N)
  else
    DISK=(`cat /proc/diskstats | grep 'xvda1'`)
    unset DISK[0]
    COMPLETEDREADS=${DISK[3]}
    T_COMPLETEDREADS=$(date +%s%N)
    MERGEDREADS=${DISK[4]}
    T_MERGEDREADS=$(date +%s%N)
    SR=${DISK[5]}
    T_SR=$(date +%s%N)
    READTIME=${DISK[6]}
    T_READTIME=$(date +%s%N)
    COMPLETEDWRITES=${DISK[7]}
    T_COMPLETEDWRITES=$(date +%s%N)
    MERGEDWRITES=${DISK[8]}
    T_MERGEDWRITES=$(date +%s%N)
    SW=${DISK[9]}
    T_SW=$(date +%s%N)
    WRITETIME=${DISK[10]}
    T_WRITETIME=$(date +%s%N)
  fi

  # Get network stats
  BR=0
  T_BT=0
  BT=0
  T_BT=0
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
      T_BR=$(date +%s%N)
      BT=`expr ${currnet[9]} + $BT`
      T_BT=$(date +%s%N)
    done
  else
    NET=(`cat /proc/net/dev | grep 'eth0'`)
    space=`expr substr $NET 6 1`
    # Need to determine which column to use based on spacing of 1st col
    if [ -z $space  ]
    then
      BR=${NET[1]}
      T_BR=$(date +%s%N)
      BT=${NET[9]}
      T_BT=$(date +%s%N)
    else
      BR=`expr substr $NET 6 500`
      T_BR=$(date +%s%N)
      BT=${NET[8]}
      T_BT=$(date +%s%N)
    fi
  fi
  LOADAVG=(`cat /proc/loadavg`)
  T_LOADAVG=$(date +%s%N)
  LAVG=${LOADAVG[0]}
  T_LAVG=$(date +%s%N)

  # Get Memory Stats
  MEMTOT=$(cat /proc/meminfo | grep 'MemTotal' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB
  T_MEMTOT=$(date +%s%N)

  MEMFREE=$(cat /proc/meminfo | grep 'MemFree' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB
  T_MEMFREE=$(date +%s%N)

  BUFFERS=$(cat /proc/meminfo | grep 'Buffers' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB
  T_BUFFERS=$(date +%s%N)

  CACHED=$(cat /proc/meminfo | grep -w 'Cached' | cut -d":" -f 2 | sed 's/^ *//' | cut -d" " -f 1 ) # in KB
  T_CACHED=$(date +%s%N)


  vmid="unavailable"



  
  echo "  \"currentTime\": $epochtime," >> $outfile
  echo "  \"vMetricType\": \"VM level\"," >> $outfile
  ## print VM level data 
  echo "  \"vCpuTime\": $CPUTOT," >> $outfile
  echo "  \"tvCpuTime\": $T_CPUTOT," >> $outfile
  echo "  \"vDiskSectorWrites\": $SW," >> $outfile
  echo "  \"tvDiskSectorWrites\": $T_SW," >> $outfile
  echo "  \"vNetworkBytesRecvd\": $BR," >> $outfile
  echo "  \"tvNetworkBytesRecvd\": $T_BR," >> $outfile
  echo "  \"vNetworkBytesSent\": $BT," >> $outfile
  echo "  \"tvNetworkBytesSent\": $T_BT," >> $outfile
  echo "  \"vCpuTimeUserMode\": $CPUUSR," >> $outfile
  echo "  \"tvCpuTimeUserMode\": $T_CPUUSR," >> $outfile
  echo "  \"vCpuTimeKernelMode\": $CPUKRN," >> $outfile
  echo "  \"tvCpuTimeKernelMode\": $T_CPUKRN," >> $outfile
  echo "  \"vCpuIdleTime\": $CPUIDLE," >> $outfile
  echo "  \"tvCpuIdleTime\": $T_CPUIDLE," >> $outfile
  echo "  \"vCpuTimeIOWait\": $CPUIOWAIT," >> $outfile
  echo "  \"tvCpuTimeIOWait\": $T_CPUIOWAIT," >> $outfile
  echo "  \"vCpuTimeIntSrvc\": $CPUIRQ," >> $outfile
  echo "  \"tvCpuTimeIntSrvc\": $T_CPUIRQ," >> $outfile
  echo "  \"vCpuTimeSoftIntSrvc\": $CPUSOFTIRQ," >> $outfile
  echo "  \"tvCpuTimeSoftIntSrvc\": $T_CPUSOFTIRQ," >> $outfile
  echo "  \"vCpuContextSwitches\": $CSWITCH," >> $outfile
  echo "  \"tvCpuContextSwitches\": $T_CSWITCH," >> $outfile
  echo "  \"vCpuNice\": $CPUNICE," >> $outfile
  echo "  \"tvCpuNice\": $T_CPUNICE," >> $outfile
  echo "  \"vCpuSteal\": $CPUSTEAL," >> $outfile
  echo "  \"tvCpuSteal\": $T_CPUSTEAL," >> $outfile
  echo "  \"vDiskSuccessfulReads\": $COMPLETEDREADS," >> $outfile
  echo "  \"tvDiskSuccessfulReads\": $T_COMPLETEDREADS," >> $outfile
  echo "  \"vDiskMergedReads\": $MERGEDREADS," >> $outfile
  echo "  \"tvDiskMergedReads\": $T_MERGEDREADS," >> $outfile
  echo "  \"vDiskReadTime\": $READTIME," >> $outfile
  echo "  \"tvDiskReadTime\": $T_READTIME," >> $outfile
  echo "  \"vDiskSuccessfulWrites\": $COMPLETEDWRITES," >> $outfile
  echo "  \"tvDiskSuccessfulWrites\": $T_COMPLETEDWRITES," >> $outfile
  echo "  \"vDiskMergedWrites\": $MERGEDWRITES," >> $outfile
  echo "  \"tvDiskMergedWrites\": $T_MERGEDWRITES," >> $outfile
  echo "  \"vDiskWriteTime\": $WRITETIME," >> $outfile
  echo "  \"tvDiskWriteTime\": $T_WRITETIME," >> $outfile

  echo "  \"vMemoryTotal\": $MEMTOT," >> $outfile     # KB
  echo "  \"tvMemoryTotal\": $T_MEMTOT," >> $outfile
  echo "  \"vMemoryFree\": $MEMFREE," >> $outfile     # KB
  echo "  \"tvMemoryFree\": $T_MEMFREE," >> $outfile
  echo "  \"vMemoryBuffers\": $BUFFERS," >> $outfile  # KB
  echo "  \"tvMemoryBuffers\": $T_BUFFERS," >> $outfile
  echo "  \"vMemoryCached\": $CACHED," >> $outfile    # KB
  echo "  \"tvMemoryCached\": $T_CACHED," >> $outfile


  echo "  \"vLoadAvg\": $LAVG," >> $outfile
  echo "  \"tvLoadAvg\": $T_LAVG," >> $outfile
  echo "  \"vId\": \"$vmid\"," >> $outfile
  echo "  \"tvId\": \"$t_vmid\"," >> $outfile
  echo "  \"vCpuType\": \"$CPUTYPE\"," >> $outfile
  echo "  \"tvCpuType\": \"$T_CPUTYPE\"," >> $outfile
  echo "  \"vCpuMhz\": \"$CPUMHZ\"," >> $outfile
  echo "  \"tvCpuMhz\": \"$T_CPUMHZ\"," >> $outfile
fi


## Container level metrics
if [ $CONTAINER = true ]
then
  #echo "CONTAINER is Running!!"
  echo "  \"cMetricType\": \"Container level\"," >> $outfile

  # Get CPU stats

  CPUUSRC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'user' | cut -d" " -f 2) # in cs
  T_CPUUSRC=$(date +%s%N)

  CPUKRNC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'system' | cut -d" " -f 2) # in cs
  T_CPUKRNC=$(date +%s%N)

  CPUTOTC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage) # in ns
  T_CPUTOTC=$(date +%s%N)

  IFS=$'\n'

  PROS=(`cat /proc/cpuinfo | grep 'processor' | cut -d":" -f 2`)
  T_PROS=$(date +%s%N)
  NUMPROS=${#PROS[@]}
  T_NUMPROS=$(date +%s%N)


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
    T_SRWC=$(date +%s%N)
  else
    SRWC=$( ( IFS=+; echo "${arr[*]}" ) | bc )
    T_SRWC=$(date +%s%N)
  fi


  IFS=$'\n'
  arr=($(cat /sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes  | grep 'Read')) # in Bytes
  unset IFS

  if [ -z "$arr" ]; then
    BRC=0
    T_BRC=$(date +%s%N)
  else
    BRC=0
    T_BRC=$(date +%s%N)
    for line in "${arr[@]}"
    do 
      temp=($line)
      for elem in "${disk_arr[@]}"
      do 
        if [ "$elem" == "${temp[0]}" ]
        then
          BRC=$(echo "${temp[2]} + $BRC" | bc)
          T_BRC=$(date +%s%N)
        fi
      done
    done
  fi



  IFS=$'\n'
  arr=($(cat /sys/fs/cgroup/blkio/blkio.throttle.io_service_bytes  | grep 'Write')) # in Bytes
  unset IFS

  if [ -z "$arr" ]; then
    BWC=0
    T_BWC=$(date +%s%N)
  else
    BWC=0
    T_BWC=$(date +%s%N)
    for line in "${arr[@]}"
    do 
      temp=($line)
      for elem in "${disk_arr[@]}"
      do 
        if [ "$elem" == "${temp[0]}" ]
        then
          BWC=$(echo "${temp[2]} + $BWC" | bc)
          T_BWC=$(date +%s%N)
        fi
      done
    done
  fi


  # Get network stats

  NET=(`cat /proc/net/dev | grep 'eth0'`)
  NRC=${NET[1]}  # bytes received
  T_NRC=$(date +%s%N)
  [[ -z "$NRC" ]] && NRC=0

  NTC=${NET[9]}  # bytes transmitted
  T_NTC=$(date +%s%N)
  [[ -z "$NTC" ]] && NTC=0


  #Get container ID
  CIDS=$(cat /etc/hostname)
  T_CIDS=$(date +%s%N)

  # Get memory stats
  MEMUSEDC=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
  T_MEMUSEDC=$(date +%s%N)
  MEMMAXC=$(cat /sys/fs/cgroup/memory/memory.max_usage_in_bytes)
  T_MEMMAXC=$(date +%s%N)

  unset IFS
  CPUPERC=(`cat /sys/fs/cgroup/cpuacct/cpuacct.usage_percpu`) # in ns, 0, 1, 2, 3 elements
  T_CPUPERC=$(date +%s%N)


  # print container level data
  echo "  \"cCpuTime\": $CPUTOTC," >> $outfile     # ns
  echo "  \"tcCpuTime\": $T_CPUTOTC," >> $outfile
  echo "  \"cNumProcessors\": $NUMPROS," >> $outfile
  echo "  \"tcNumProcessors\": $T_NUMPROS," >> $outfile
  echo "  \"cProcessorStats\": {" >> $outfile
  for (( i=0; i<NUMPROS; i++ ))
  do 
    echo "  \"cCpu${i}TIME\": ${CPUPERC[$i]}, " >> $outfile
  done
  echo "  \"tcCpu#TIME\": $T_CPUPERC," >> $outfile
  echo "  \"cNumProcessors\": $NUMPROS," >> $outfile
  echo "  \"tcNumProcessors\": $T_NUMPROS," >> $outfile
  echo "  }," >> $outfile

  echo "  \"cCpuTimeUserMode\": $CPUUSRC," >> $outfile    # cs
  echo "  \"tcCpuTimeUserMode\": $T_CPUUSRC," >> $outfile
  echo "  \"cCpuTimeKernelMode\": $CPUKRNC," >> $outfile  # cs
  echo "  \"tcCpuTimeKernelMode\": $T_CPUKRNC," >> $outfile

  echo "  \"cDiskSectorIO\": $SRWC," >> $outfile
  echo "  \"tcDiskSectorIO\": $T_SRWC," >> $outfile
  echo "  \"cDiskReadBytes\": $BRC," >> $outfile
  echo "  \"tcDiskReadBytes\": $T_BRC," >> $outfile
  echo "  \"cDiskWriteBytes\": $BWC," >> $outfile
  echo "  \"tcDiskWriteBytes\": $T_BWC," >> $outfile

  echo "  \"cNetworkBytesRecvd\": $NRC," >> $outfile
  echo "  \"tcNetworkBytesRecvd\": $T_NRC," >> $outfile
  echo "  \"cNetworkBytesSent\": $NTC," >> $outfile
  echo "  \"tcNetworkBytesSent\": $T_NTC," >> $outfile

  echo "  \"cMemoryUsed\": $MEMUSEDC," >> $outfile
  echo "  \"tcMemoryUsed\": $T_MEMUSEDC," >> $outfile
  echo "  \"cMemoryMaxUsed\": $MEMMAXC," >> $outfile
  echo "  \"tcMemoryMaxUsed\": $T_MEMMAXC," >> $outfile


  echo "  \"cId\": \"$CIDS\"," >> $outfile
  echo "  \"tcId\": \"$T_CIDS\"," >> $outfile
  echo "  \"cNumProcesses\": $PIDS," >> $outfile
  echo "  \"tcNumProcesses\": $T_PIDS," >> $outfile

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





