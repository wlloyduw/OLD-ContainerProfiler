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
#run command goes in background
${@} &
#capture the pid of the run command
rpid=$!

#kill the runcmd if there is an error
trap "kill -9 $rpid 2> /dev/null" EXIT

while kill -0 $rpid 2> /dev/null; do
    today=`date '+%Y_%m_%d__%H_%M_%S'`;
    file_name="$today.json"
    rudataall.sh  > "${OUTPUTDIR}/${file_name}"
    sleep $DELTA
done


