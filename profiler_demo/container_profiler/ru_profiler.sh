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


while true; do
  cpids=($(get_cpid $ppid | xargs))
  echo "All the children PIDs: " ${cpids[@]}
  if kill -0 $ppid &> /dev/null; then  
    today=`date '+%Y_%m_%d__%H_%M_%S'`;
    file_name="$today.json"
    /data/rudataall.sh  > "/data/${file_name}"
    sleep $deltaT
  else
    break
  fi  
done

