#! /bin/bash
# Read the .json files output file1.json and file2.json
# by rudata_all.sh to calculate the delta for specified variables.

# This is the OLD Delta script - it may not work correctly


# Packages required for Ubuntu
# bc (An arbitrary precision calculator language)
# jq (A command-line JSON processor)


file1=$1
file2=$2

IFS=$'\n'



preContStats=(`jq '."cpuTime(ns)", \
            ."cpuTimeUserMode(cs)", ."cpuTimeKernelMode(cs)", \
            .diskSectorIO, .diskReadBytes, .diskWriteBytes, \
            .networkBytesRecvd, .networkBytesSent, \
            .memoryUsed, .memoryMaxUsed, \
            .cpuType, .cpuMhz, .containerId, \
            .currentTime' \
             $file1`) 


numProcessors=$(jq '.processorStats[-1].numProcessors' $file1)


aftContStats=(`jq '."cpuTime(ns)", \
           ."cpuTimeUserMode(cs)", ."cpuTimeKernelMode(cs)", \
             .diskSectorIO, .diskReadBytes, .diskWriteBytes, \
             .networkBytesRecvd, .networkBytesSent, \
             .memoryUsed, .memoryMaxUsed, \
             .cpuType, .cpuMhz, .containerId, \
             .currentTime' \
              $file2`) 

cpuTimeDelta=$(echo ${aftContStats[0]} - ${preContStats[0]} | bc)
cpuUserDelta=$(echo ${aftContStats[1]} - ${preContStats[1]} | bc)
cpuKernelDelta=$(echo ${aftContStats[2]} - ${preContStats[2]} | bc)
diskIODelta=$(echo ${aftContStats[3]} - ${preContStats[3]} | bc)
diskReadDelta=$(echo ${aftContStats[4]} - ${preContStats[4]} | bc)
diskWriteDelta=$(echo ${aftContStats[5]} - ${preContStats[5]} | bc)
networkRecvdDelta=$(echo ${aftContStats[6]} - ${preContStats[6]} | bc)
networkSentDelta=$(echo ${aftContStats[7]} - ${preContStats[7]} | bc)
memUsedDelta=$(echo ${aftContStats[8]} - ${preContStats[8]} | bc)
memMaxUsedDelta=$(echo ${aftContStats[9]} - ${preContStats[9]} | bc)
cpuType=${aftContStats[10]}
cpuMhz=${aftContStats[11]}
contID=${aftContStats[12]}
timeDelta=$(echo ${aftContStats[13]} - ${preContStats[13]} | bc) 
#seconds since 1970-01-01 00:00:00 UTC


# Process stats
#preProc1Stats=$(jq '."1"' rudata_all_1.json) 
#aftProc1Stats=$(jq '."1"' rudata_all_2.json)

# Easier way?
#KEYS=$(jq '."1"' rudata_all_2.json | jq 'keys_unsorted[]')
# i=1
#pid1=$(jq .processes[$i].pid rudata_all_1.json)


preNumProcesses=$(jq '.processes[-1].numProcesses' $file1)
aftNumProcesses=$(jq '.processes[-1].numProcesses' $file2)
numProcessesDelta=$(echo ${aftNumProcesses} - ${preNumProcesses} | bc)


#KEYS=(jq .processes[0] rudata_all_1.json | jq 'keys_unsorted[]')

outfile=rudata_delta.json


echo "{" > $outfile

echo "  \"timeDiffSeconds\": $timeDelta," >> $outfile

echo "  \"cpuTimeDiff\": $cpuTimeDelta," >> $outfile

echo "  \"processorStats\": [ " >> $outfile
for (( i=0; i<numProcessors; i++ ))
do 
  preCPU=$(jq .processorStats[$i].CPU${i}TIME $file1)
  aftCPU=$(jq .processorStats[$i].CPU${i}TIME $file2)
  cpuDiff=$(echo "${aftCPU} - ${preCPU}" | bc)
  echo "  {\"CPU${i}TimeDiff\": $cpuDiff}, " >> $outfile
done
echo "  {\"numProcessors\": $numProcessors} " >> $outfile
echo "  ], " >> $outfile

echo "  \"cpuTimeUserDiff\": $cpuUserDelta," >> $outfile

echo "  \"cpuTimeKernelDiff\": $cpuKernelDelta," >> $outfile

echo "  \"diskSectorIODiff\": $diskIODelta," >> $outfile

echo "  \"diskReadDiff\": $diskReadDelta," >> $outfile

echo "  \"diskWriteDiff\": $diskWriteDelta," >> $outfile

echo "  \"networkRecvdDiff\": $networkRecvdDelta," >> $outfile

echo "  \"networkSentDiff\": $networkSentDelta," >> $outfile

echo "  \"memUsedDiff\": $memUsedDelta," >> $outfile

echo "  \"memoryMaxUsedDiff\": $memMaxUsedDelta," >> $outfile

echo "  \"cpuType\": $cpuType," >> $outfile

echo "  \"cpuMhz\": $cpuMhz," >> $outfile

echo "  \"containerId\": $contID," >> $outfile

echo "  \"numCurrentProcesses\": $aftNumProcesses," >> $outfile

echo "  \"numProcessesDiff\": $numProcessesDelta," >> $outfile


echo "  \"processes\": [" >> $outfile

cnt=0
for (( i=0; i<preNumProcesses; i++))
do
  preObj=$(jq .processes[$i] $file1)
  pid1=$(echo $preObj | jq .pid)
  for (( j=0; j<aftNumProcesses; j++))
  do
    aftObj=$(jq .processes[$j] $file2)
    pid2=$(echo $aftObj | jq .pid)
    if [ "$pid1" == "$pid2" ]
    then
      
      cnt=$((cnt + 1))
      # compute delta
      preNumThreads=$(echo $preObj | jq .numThreads)
      aftNumThreads=$(echo $aftObj | jq .numThreads)
      numThreadsDif=$(echo "${aftNumThreads} - ${preNumThreads}" | bc)

      preCPUUser=$(echo $preObj | jq '."cpuTimeUserMode(cs)"')
      aftCPUUser=$(echo $aftObj | jq '."cpuTimeUserMode(cs)"')
      cpuTimeUserDif=$(echo "${aftCPUUser} - ${preCPUUser}" | bc)
      
      preCPUKernel=$(echo $preObj | jq '."cpuTimeKernelMode(cs)"')
      aftCPUKernel=$(echo $aftObj | jq '."cpuTimeKernelMode(cs)"')
      cpuTimeKernelDif=$(echo "${aftCPUKernel} - ${preCPUKernel}" | bc)

      preChildrenUser=$(echo $preObj | jq '."childrenUserMode(cs)"')
      aftChildrenUser=$(echo $aftObj | jq '."childrenUserMode(cs)"')
      childrenUserDif=$(echo "${aftChildrenUser} - ${preChildrenUser}" | bc)

      preChildrenKernel=$(echo $preObj | jq '."childrenKernelMode(cs)"')
      aftChildrenKernel=$(echo $aftObj | jq '."childrenKernelMode(cs)"')
      childrenKernelDif=$(echo "${aftChildrenKernel} - ${preChildrenKernel}" | bc)

      preVolCS=$(echo $preObj | jq .voluntaryContextSwitches)
      aftVolCS=$(echo $aftObj | jq .voluntaryContextSwitches)
      volCSDif=$(echo "${aftVolCS} - ${preVolCS}" | bc)

      preNonVolCS=$(echo $preObj | jq .nonvoluntaryContextSwitches)
      aftNonVolCS=$(echo $aftObj | jq .nonvoluntaryContextSwitches)
      nonvolCSDif=$(echo "${aftNonVolCS} - ${preNonVolCS}" | bc)

      preBlkIODelays=$(echo $preObj | jq '."blockIODelays(cs)"')
      aftBlkIODelays=$(echo $aftObj | jq '."blockIODelays(cs)"')
      blkIODelaysDif=$(echo "${aftBlkIODelays} - ${preBlkIODelays}" | bc)

      preVirtMem=$(echo $preObj | jq .virtualMemoryBytes)
      aftVirtMem=$(echo $aftObj | jq .virtualMemoryBytes)
      virtMemDif=$(echo "${aftVirtMem} - ${preVirtMem}" | bc)


      preRSS=$(echo $preObj | jq '."residentSetSize(page)"')
      aftRSS=$(echo $aftObj | jq '."residentSetSize(page)"')
      RSSDif=$(echo "${aftRSS} - ${preRSS}" | bc)
      
      # echo delta stats
      echo "  {" >> $outfile
      echo "  \"pid\": $pid1, " >> $outfile
      echo "  \"numThreadsDiff\": $numThreadsDif, " >> $outfile
      echo "  \"cpuTimeUserDiff\": $cpuTimeUserDif, " >> $outfile
      echo "  \"cpuTimeKernelDiff\": $cpuTimeKernelDif, " >> $outfile
      echo "  \"childrenUserDiff\": $childrenUserDif, " >> $outfile
      echo "  \"childrenKernelDiff\": $childrenKernelDif, " >> $outfile
      echo "  \"voluntaryContextSwitchesDiff\": $volCSDif," >> $outfile
      echo "  \"nonVoluntaryContextSwitchesDiff\": $nonvolCSDif," >> $outfile
      echo "  \"blkIODelaysDiff\": $blkIODelaysDif," >> $outfile
      echo "  \"virtualMemoryDiff\": $virtMemDif," >> $outfile
      echo "  \"residentSetSizeDiff\": $RSSDif" >> $outfile
      echo "  }, " >> $outfile 

      break
    fi
    
  done
  
done

echo "  {\"numOverlappingProc\": $cnt } " >> $outfile

echo "  ] " >> $outfile

echo "} " >> $outfile

cat $outfile





