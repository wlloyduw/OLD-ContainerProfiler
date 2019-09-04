#!/bin/bash

#usage: ./delta_json_generation.sh (path to this folder with script) (folder containing json)
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

array1=()
array2=()
array3=()
x=1
for file_name in $path/$folder/*.json; do
	[ -e "$file_name" ] || continue 

	if [[ $file1 == "empty" ]]; then
		if [ $x -eq 1 ]; then
			((x++))
			continue
		fi
		file1=$file_name
		array1+=($file_name)
		shortened_file_name="$(basename $file_name)" 
		shortened_file_name="${shortened_file_name%.*}"
		array3+=("$delta_json_path/${shortened_file_name}_delta.json")
		echo $file_name
		continue
	fi

	if [[ $file2 == "empty" ]]; then
		file2=$file_name
		array2+=($file_name)
		#cd $delta_json_path
		shortened_file_name="$(basename $file_name)" 
		shortened_file_name="${shortened_file_name%.*}"
		array3+=("$delta_json_path/${shortened_file_name}_delta.json")
		
		#$path/deltav2.sh $file2 $file1 1>"$delta_json_path/${shortened_file_name}_delta.json"
		file1=$file2
		array1+=($file_name)
		file2="empty"
		#cd ..
		continue
	fi
done

runJob()
{
	a=$1
	b=$2
	c=$3
	d=$4
	#echo ${b[0]}
	#echo ${c[0]}
	#echo ${d[0]}
	$a/deltav2.sh ${c[0]} ${b[0]} 1>${d[0]}

}
export -f runJob
parallel --jobs 2 --link runJob ::: $path ::: ${array1[@]} ::: ${array2[@]} ::: ${array3[@]}


