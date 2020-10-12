#!/bin/bash

#if there is no output directory mapping then we pass the command through

if [ -z $OUTPUTDIR ]; then
	OUTPUTDIR="/.cprofiles"
fi
if [ -z $DELTA ]; then
	DELTA=1000
fi

if [ ! -d "$OUTPUTDIR" ]; then
	${@}
	exit
fi
echo "Command is: ${@}"
#run command goes in background
${@} &
#capture the pid of the run command
rpid=$!
#kill the runcmd if there is an error
trap "kill -9 $rpid 2> /dev/null" EXIT

#SECONDS=0 && rudataall.sh  > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json"
while [ -n "$rpid" -a -e /proc/$rpid ]
do

    t1=$(date '+%s%3N')
    rudataall.sh > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json" &
    t2=$(date '+%s%3N')
    let profile_time=$t2-$t1
    let sleep_time=$DELTA-$profile_time
    sleep_time=`echo $sleep_time / 1000 | bc -l`
    sleep $sleep_time

done
#rudataall.sh > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json"



