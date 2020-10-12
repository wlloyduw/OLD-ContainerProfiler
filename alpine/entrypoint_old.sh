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
echo "Command is: ${@}"
#run command goes in background
${@} &
#capture the pid of the run command
rpid=$!
#kill the runcmd if there is an error
trap "kill -9 $rpid 2> /dev/null" EXIT
SECONDS=0 && rudataall.sh  > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json"
while [ -n "$rpid" -a -e /proc/$rpid ]
do
    if [ "$SECONDS" -ge "$DELTA" ]; then
      SECONDS=0 && rudataall.sh  > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json"
    fi
    sleep 1
done
rudataall.sh  > "${OUTPUTDIR}/$(date '+%Y_%m_%d__%H_%M_%S').json"

