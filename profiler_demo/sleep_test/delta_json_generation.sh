#!/bin/bash

#usage: ./delta_json_generation.sh (path to this folder) (folder containing json)
#example usage: ./delta_json_generation.sh /home/david/ContainerProfiler/profiler_demo/sleep_test 2019_08_07__03_53_14
path=$1
folder=$2
if [ ! -d "$path" ]; then
	echo "Please enter a valid file path"
	exit 1
fi

delta_json_path=$path/$folder/delta_json
mkdir -m 777 $delta_json_path

file1="empty"
file2="empty"
x=1
echo $path/$folder
for file_name in $path/$folder/*.json; do
	[ -e "$file_name" ] || continue 

	if [[ $file1 == "empty" ]]; then
		file1=$file_name
		continue
	fi

	if [[ $file2 == "empty" ]]; then
		file2=$file_name
		cd $delta_json_path
		#$path/deltav2.sh $file2 $file1 1>"${x}_delta.json"
		$path/deltav2.sh $file2 $file1 1>"${x}_delta.json"


		file1=$file2
		file2="empty"
		cd ..
		((x++))
		continue
	fi
#Usage .deltav2.sh file1.json file2.json 2>missing.txt 1>delta.json
done


