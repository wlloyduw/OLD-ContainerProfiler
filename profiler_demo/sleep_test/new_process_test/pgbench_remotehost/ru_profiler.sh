#/bin/bash

function get_cpid() {
    cpids=($(pgrep -P $1 | xargs))
    for cpid in "${cpids[@]}";do 
      echo $cpid
      get_cpid $cpid
    done
}




runcmd=$1
deltaT=$2

$runcmd &

pname=$(basename "${runcmd}")
echo "processname: " $pname

ppid=$(pgrep -x "${pname}") 
echo "parent process ID: " $ppid

#create an array to hold the json in main memory and another to hold the date filenames
#used to write the data at the end of collection.
#declare -a json
#index=0
#declare -a dates

while true; do
  cpids=($(get_cpid $ppid | xargs))
  echo "All the children PIDs: " ${cpids[@]}
  if kill -0 $ppid &> /dev/null; then  
    #dates[$index]=`date '+%Y_%m_%d__%H_%M_%S'`;
    #echo "Date=${dates[$index]}"
    today=`date '+%Y_%m_%d__%H_%M_%S'`;
    file_name="$today.json"
    t1=$(date '+%H%M%S')
    /data/rudataall.sh  > "/data/${file_name}"
    t2=$(date '+%H%M%S')
    #json[$index]=$(/data/rudataall.sh)
    #let index=$index+1
    let sleep_time=$deltaT-$t1-t2
    sleep $sleep_time
  else
    #for i in "${#json[@]}"
    #do
     #   echo ${json[$i]} > "/data/${dates[$i]}.txt"
    #done
    break
  fi  
done

