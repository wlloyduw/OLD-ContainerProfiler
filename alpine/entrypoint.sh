#!/bin/bash

#if there is no output directory mapping then we pass the command through

if [ -z $OUTPUTDIR ]; then
	OUTPUTDIR="/.cprofiles"
fi
if [ -z $DELTA ]; then
	DELTA=1
fi

if [ ! -d "$OUTPUTDIR" ]; then
	${@}
	exit
fi

let deltaT=$DELTA*1000

#run command goes in background
${@} &
#capture the pid of the run command
rpid=$!
#kill the runcmd if there is an error
trap "kill -9 $rpid 2> /dev/null" EXIT

#Keep track of min and max profiling time
let min=2**31
let max=0
echo "" > "${OUTPUTDIR}/sample_times.txt"

SECONDS=0
while [ -n "$rpid" -a -e /proc/$rpid ]
do
      today=`date '+%Y_%m_%d__%H_%M_%S'`;
      t1=$(date '+%s%3N')
      file_name="$today.json"
      rudataall.sh  > "${OUTPUTDIR}/${file_name}"
      t2=$(date '+%s%3N')

      #Test to see if we have a new min or max profiling time
      let profile_time=$t2-$t1
      if [ $profile_time -lt $min ]
      then
      	let min=$profile_time
      elif [ $profile_time -gt $max ]
      then
        let max=$profile_time
      fi

      echo "$profile_time" >> "${OUTPUTDIR}/sample_times.txt"

      SECONDS=0
      let sleep_time=$deltaT-$profile_time
      #convert time to sleep back into seconds
      sleep_time=`echo $sleep_time / 1000 | bc -l`
      #Sleep
    
      sleep $sleep_time
done


