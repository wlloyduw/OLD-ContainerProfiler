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

output=$''
output+=$'{\n'
epochtime=$(date +%s)
write_time_start=$(date '+%s%3N')

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

  T_VM_1=$(date +%s%3N)

  # Get CPU stats
  CPU=(`cat /proc/stat | grep '^cpu '`)
  unset CPU[0]
  CPUUSR=${CPU[1]}
  T_CPUUSR=$(date +%s%3N)
  CPUNICE=${CPU[2]}
  T_CPUNICE=$(date +%s%3N)
  CPUKRN=${CPU[3]}
  T_CPUKRN=$(date +%s%3N)
  CPUIDLE=${CPU[4]}  
  T_CPUIDLE=$(date +%s%3N)
  CPUIOWAIT=${CPU[5]}
  T_CPUIOWAIT=$(date +%s%3N)
  CPUIRQ=${CPU[6]}
  T_CPUIRQ=$(date +%s%3N)
  CPUSOFTIRQ=${CPU[7]}
  T_CPUSOFTIRQ=$(date +%s%3N)
  CPUSTEAL=${CPU[8]}
  T_CPUSTEAL=$(date +%s%3N)
  CPUTOT=`expr $CPUUSR + $CPUKRN`
  T_CPUTOT=$(date +%s%3N)
  CONTEXT=(`cat /proc/stat | grep '^ctxt '`)
  unset CONTEXT[0]
  CSWITCH=${CONTEXT[1]}
  T_CSWITCH=$(date +%s%3N) 

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
  T_CPUTYPE=$(date +%s%3N)
  CPUMHZ=${CPU_MHZ[0]}
  T_CPUMHZ=$(date +%s%3N)

DISK="$(lsblk -nd --output NAME,TYPE | grep disk)"
DISK=${DISK//disk/}
DISK=($DISK)
#DISK is now an array containing all names of our unique disk devices

unset IFS
length=${#DISK[@]}


for (( i=0 ; i < length; i++ ))
    do
      currdisk=($(cat /proc/diskstats | grep ${DISK[i]}) )
      COMPLETEDREADS=`expr ${currdisk[3]} + $COMPLETEDREADS`
      MERGEDREADS=`expr ${currdisk[4]} + $MERGEDREADS`
      SR=`expr ${currdisk[5]} + $SR`
      READTIME=`expr ${currdisk[6]} + $READTIME`
      COMPLETEDWRITES=`expr ${currdisk[7]} + $COMPLETEDWRITES`
      MERGEDWRITES=`expr ${currdisk[8]} + $MERGEDWRITES`
      SW=`expr ${currdisk[9]} + $SW`
      WRITETIME=`expr ${currdisk[10]} + $WRITETIME`
    done

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

  T_VM_2=$(date +%s%3N)
  let T_VM=$T_VM_2-$T_VM_1

	
 #experimental pagefault
 filedata() {
     volumes=$(cat $1 | grep -m 1 -i $2)
     tr " " "\n" <<< $volumes | tail -n1 
    
 }
 vPGFault=$(filedata "/proc/vmstat" "pgfault")
 vMajorPGFault=$(filedata "/proc/vmstat" "pgmajfault")
 #

  output+=$'  \"currentTime\": '"$epochtime"
  output+=$',\n'
  output+=$'  \"vMetricType\": \"VM level\",\n'
  output+=$'  \"vTime\": '"$T_VM"
  output+=$',\n'

  ## print VM level data 
  output+="  \"vCpuTime\": $CPUTOT"
  output+=$',\n'
  output+="  \"tvCpuTime\": $T_CPUTOT"
  output+=$',\n'
  output+="  \"vDiskSectorReads\": $SR"
  output+=$',\n'
  output+="  \"vDiskSectorWrites\": $SW"
  output+=$',\n'
  output+="  \"vNetworkBytesRecvd\": $BR"
  output+=$',\n'
  output+="  \"vNetworkBytesSent\": $BT"
  output+=$',\n'
  output+="  \"vPgFault\": $vPGFault"
  output+=$',\n'
  output+="  \"vMajorPageFault\": $vMajorPGFault"
  output+=$',\n'
  output+="  \"vCpuTimeUserMode\": $CPUUSR"
  output+=$',\n'
  output+="  \"tvCpuTimeUserMode\": $T_CPUUSR"
  output+=$',\n'
  output+="  \"vCpuTimeKernelMode\": $CPUKRN"
  output+=$',\n'
  output+="  \"tvCpuTimeKernelMode\": $T_CPUKRN"
  output+=$',\n'
  output+="  \"vCpuIdleTime\": $CPUIDLE"
  output+=$',\n'
  output+="  \"tvCpuIdleTime\": $T_CPUIDLE"
  output+=$',\n'
  output+="  \"vCpuTimeIOWait\": $CPUIOWAIT"
  output+=$',\n'
  output+="  \"tvCpuTimeIOWait\": $T_CPUIOWAIT"
  output+=$',\n'
  output+="  \"vCpuTimeIntSrvc\": $CPUIRQ"
  output+=$',\n'
  output+="  \"tvCpuTimeIntSrvc\": $T_CPUIRQ"
  output+=$',\n'
  output+="  \"vCpuTimeSoftIntSrvc\": $CPUSOFTIRQ"
  output+=$',\n'
  output+="  \"tvCpuTimeSoftIntSrvc\": $T_CPUSOFTIRQ"
  output+=$',\n'
  output+="  \"vCpuContextSwitches\": $CSWITCH"
  output+=$',\n'
  output+="  \"tvCpuContextSwitches\": $T_CSWITCH"
  output+=$',\n'
  output+="  \"vCpuNice\": $CPUNICE"
  output+=$',\n'
  output+="  \"tvCpuNice\": $T_CPUNICE"
  output+=$',\n'
  output+="  \"vCpuSteal\": $CPUSTEAL"
  output+=$',\n'
  output+="  \"tvCpuSteal\": $T_CPUSTEAL"
  output+=$',\n'
  output+="  \"vDiskSuccessfulReads\": $COMPLETEDREADS"
  output+=$',\n'
  output+="  \"vDiskMergedReads\": $MERGEDREADS"
  output+=$',\n'
  output+="  \"vDiskReadTime\": $READTIME"
  output+=$',\n'
  output+="  \"vDiskSuccessfulWrites\": $COMPLETEDWRITES"
  output+=$',\n'
  output+="  \"vDiskMergedWrites\": $MERGEDWRITES"
  output+=$',\n'
  output+="  \"vDiskWriteTime\": $WRITETIME"
  output+=$',\n'
  output+="  \"vMemoryTotal\": $MEMTOT" 
  output+=$',\n'
  output+="  \"vMemoryFree\": $MEMFREE"
  output+=$',\n'
  output+="  \"vMemoryBuffers\": $BUFFERS"
  output+=$',\n'
  output+="  \"vMemoryCached\": $CACHED"
  output+=$',\n'
  output+="  \"vLoadAvg\": $LAVG"
  output+=$',\n'
  output+="  \"vId\": \"$vmid\""
  output+=$',\n'
  output+="  \"vCpuType\": \"$CPUTYPE\""
  output+=$',\n'
  output+="  \"tvCpuType\": $T_CPUTYPE"
  output+=$',\n'
  output+="  \"vCpuMhz\": \"$CPUMHZ\""
  output+=$',\n'
  


  if [ $CONTAINER = true ] || [ $PROCESS = true ];
  then
	output+=$'  \"tvCpuMhz\": '"$T_CPUMHZ"
	output+=$',\n'
  else
	output+=$'  \"tvCpuMhz\": '"$T_CPUMHZ"
	output+=$'\n'
  fi
fi


## Container level metrics
if [ $CONTAINER = true ]
then
  #echo "CONTAINER is Running!!"
  T_CNT_1=$(date +%s%3N)

  output+=$'  \"cMetricType\": '"\"Container level\""
  output+=$',\n'

  # Get CPU stats

  CPUUSRC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'user' | cut -d" " -f 2) # in cs
  T_CPUUSRC=$(date +%s%3N)

  CPUKRNC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.stat | grep 'system' | cut -d" " -f 2) # in cs
  T_CPUKRNC=$(date +%s%3N)

  CPUTOTC=$(cat /sys/fs/cgroup/cpuacct/cpuacct.usage) # in ns
  T_CPUTOTC=$(date +%s%3N)

  IFS=$'\n'

  PROS=(`cat /proc/cpuinfo | grep 'processor' | cut -d":" -f 2`)
  NUMPROS=${#PROS[@]}
  T_NUMPROS=$(date +%s%3N)


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
  T_CPUPERC=$(date +%s%3N)

  T_CNT_2=$(date +%s%3N)
  let T_CNT=$T_CNT_2-T_CNT_1

  cPGFault=$(filedata "/sys/fs/cgroup/memory/memory.stat" "pgfault")
  cMajorPGFault=$(filedata "/sys/fs/cgroup/memory/memory.stat" "pgmajfault")


  # print container level data
  output+="  \"cTime\": $T_CNT"
  output+=$',\n'
  output+="  \"cCpuTime\": $CPUTOTC"
  output+=$',\n'
  output+="  \"tcCpuTime\": $T_CPUTOTC"
  output+=$',\n'
  output+="  \"cNumProcessors\": $NUMPROS"
  output+=$',\n'
  output+="  \"cPGFault\": $cPGFault"
  output+=$',\n'
  output+="  \"cMajorPGFault\": $cMajorPGFault"
  output+=$',\n'
  output+="  \"tcNumProcessors\": $T_NUMPROS"
  output+=$',\n'
  output+="  \"cProcessorStats\": {"
  output+=$'\n'


  for (( i=0; i<NUMPROS; i++ ))
  do 
    output+=$"  \"cCpu${i}TIME\": ${CPUPERC[$i]}"
    output+=$',\n'
  done

  output+="  \"tcCpu#TIME\": $T_CPUPERC"
  output+=$',\n'
  output+="  \"cNumProcessors\": $NUMPROS"
  output+=$'\n  },\n'
  output+="  \"cCpuTimeUserMode\": $CPUUSRC"
  output+=$',\n'
  output+="  \"tcCpuTimeUserMode\": $T_CPUUSRC"
  output+=$',\n'
  output+="  \"cCpuTimeKernelMode\": $CPUKRNC"
  output+=$',\n'
  output+="  \"tcCpuTimeKernelMode\": $T_CPUKRNC"
  output+=$',\n'
  output+="  \"cDiskSectorIO\": $SRWC"
  output+=$',\n'
  output+="  \"cDiskReadBytes\": $BRC"
  output+=$',\n'
  output+="  \"cDiskWriteBytes\": $BWC"
  output+=$',\n'
  output+="  \"cNetworkBytesRecvd\": $NRC"
  output+=$',\n'
  output+="  \"cNetworkBytesSent\": $NTC"
  output+=$',\n'
  output+="  \"cMemoryUsed\": $MEMUSEDC"
  output+=$',\n'


  output+="  \"cMemoryMaxUsed\": $MEMMAXC"
  output+=$',\n'
  output+="  \"cId\": \"$CIDS\""
  output+=$',\n'
  output+="  \"cNumProcesses\": $PIDS"
  output+=$',\n'
  output+="  \"pMetricType\": \"Process level\""



  if [ $PROCESS = true ];
  then
    output+=$',\n'
  else
    output+=$'\n'
  fi
fi

## Process level metrics

if [ $PROCESS = true ]
then
  #echo "PROCESS is Running!!"

  T_PRC_1=$(date +%s%3N)
  # For each process, parse the data

  # command cat $outfile in the last line of the script
  # and ./rudataall.sh are counted as 2 extra processes, so -2 here for PIDS

  output+="  \"pProcesses\": ["
  output+=$'\n'


  declare -A "profilerPid=( $(pgrep "rudataall.sh" -v | sed 's/[^ ]*/[&]=&/g') )"
  for i in "${!profilerPid[@]}"
  do
	parent=$(ps -o ppid= ${profilerPid[$i]})
	parent_nowhite_space="$(echo -e "${parent}" | tr -d '[:space:]')"
	
	if [[ ! " ${profilerPid[@]} " =~ " ${parent_nowhite_space} " ]]; then		
		#this if statement checks if parent of pid is not in the list of all profiler proesses.
		#check if pid still exists

		STAT=(`cat /proc/${profilerPid[$i]}/stat 2>/dev/null`)
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
			  VCSWITCH=$(cat /proc/${profilerPid[$i]}/status | grep "^voluntary_ctxt_switches" | \
			    cut -d":" -f 2 | sed 's/^[ \t]*//') 
			  NVCSSWITCH=$(cat /proc/${profilerPid[$i]}/status | grep "^nonvoluntary_ctxt_switches" | \
			    cut -d":" -f 2 | sed 's/^[ \t]*//') 

			  # Get process disk stats
			  DELAYIO=${STAT[41]}
			  pPGFault=$(cat /proc/${profilerPid[$i]}/stat | cut -d' ' -f 10)
			  pMajorPGFault=$(cat /proc/${profilerPid[$i]}/stat | cut -d' ' -f 12)

			  # Get process memory stats
			  VSIZE=${STAT[22]} # in Bytes
			  RSS=${STAT[23]} # in pages

			  PNAME=$(cat /proc/${profilerPid[$i]}/cmdline | tr "\0" " ")
	    		  PNAME=${PNAME%?}

			  # print process level data
	   		  output+=$'  {\n'
	   		  output+="  \"pId\": $PID"
	   		  output+=$',\n'
	  


			  
			  if jq -e . >/dev/null 2>&1 <<<"\"$PNAME\""; then
				:
			  else
				PNAME="Invalid Json"
			  fi


	   		  output+="  \"pCmdLine\":\"$PNAME\""
	   		  output+=$',\n'
	   		  output+="  \"pName\":\"$PSHORT\""
	   		  output+=$',\n'
	   		  output+="  \"pNumThreads\": $NUMTHRDS"
	   		  output+=$',\n'
	   		  output+="  \"pCpuTimeUserMode\": $UTIME"
	   		  output+=$',\n'
	   		  output+="  \"pCpuTimeKernelMode\": $STIME"
	   		  output+=$',\n'
	   		  output+="  \"pChildrenUserMode\": $CUTIME"
	   		  output+=$',\n'
	   		  output+="  \"pPGFault\": $pPGFault"
	   		  output+=$',\n'
	   		  output+="  \"pMajorPGFault\": $pMajorPGFault"
	   		  output+=$',\n'
	   		  output+="  \"pChildrenKernelMode\": $CSTIME"
	   		  output+=$',\n'



			  if  [ -z "$VCSWITCH" ];
			  then
				VCSWITCH="NA"
			  fi
			  output+="  \"pVoluntaryContextSwitches\": $VCSWITCH"
			  output+=$',\n'

			  if  [ -z "$NVCSSWITCH" ];
			  then
				NVCSSWITCH="NA"
			  fi
		          output+="  \"pNonvoluntaryContextSwitches\": $NVCSSWITCH"
		          output+=$',\n'



			  output+="  \"pBlockIODelays\": $DELAYIO"
			  output+=$',\n'
			  output+="  \"pVirtualMemoryBytes\": $VSIZE"
			  output+=$',\n'
			  output+="  \"pResidentSetSize\": $RSS"
			  output+=$'\n  }, \n'
		fi
	fi


  done

  T_PRC_2=$(date +%s%3N)
  let T_PRC=$T_PRC_2-$T_PRC_1
  output+="  {\"cNumProcesses\": $PIDS"
  output+=$',\n'
  output+="  \"pTime\": $T_PRC"
  output+=$',\n'
  write_time_end=$(date '+%s%3N')
  let profile_time=$write_time_end-$write_time_start
  output+="  \"profileTime\": $profile_time"
  output+=$'}'
  
  
  output+=$'\n  ]\n'
fi

output+=$'}'
echo "$output" & > experimental.json

