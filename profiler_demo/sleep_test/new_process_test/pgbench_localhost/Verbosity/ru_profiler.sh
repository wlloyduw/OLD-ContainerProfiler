#/bin/bash

function get_cpid() {
    cpids=($(pgrep -P $1 | xargs))
    for cpid in "${cpids[@]}";do 
      echo $cpid
      get_cpid $cpid
    done
}




runcmd=$1
#convert deltaT to milliseconds
let deltaT=$2*1000

$runcmd &

pname=$(basename "${runcmd}")
echo "processname: " $pname

ppid=$(pgrep -x "${pname}") 
echo "parent process ID: " $ppid


#Keep track of min and max profiling time
let min=2**31
let max=0

echo "" > "/data/sample_times.txt"

while true; do
  cpids=($(get_cpid $ppid | xargs))
  echo "All the children PIDs: " ${cpids[@]}
  if kill -0 $ppid &> /dev/null; then  
    today=`date '+%Y_%m_%d__%H_%M_%S'`;
    file_name="$today.json"
    t1=$(date '+%s%3N')
    /data/rudataall.sh -v > "/data/${file_name}"
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

    #Write out the time it takes to collect each sample to another file

    echo "$profile_time" >> "/data/sample_times.txt"
    
    #Difference between desired sampling rate and time used to run profiling script
    let sleep_time=$deltaT-$profile_time
    #convert time to sleep back into seconds
    sleep_time=`echo $sleep_time / 1000 | bc -l`
    #Sleep
    
    sleep $sleep_time
  else
    break
  fi  
done

#after profiling is finished print the max and min profiling times
echo '******************************************************************************************'
echo 'Max profiling time is: ' `echo $max / 1000 | bc -l`
echo 'Min profiling time is: ' `echo $min / 1000 | bc -l`
echo '******************************************************************************************'

