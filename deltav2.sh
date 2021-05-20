#!/bin/bash
#Ling-Hong Hung Oct 2018

#Usage .deltav2.sh file1.json file2.json 2>missing.txt 1>delta.json

#This version will work if the variables are in different order
#The resulting json file will have the order of the second file

#loop through file1
declare -A map1
declare -A map2
while IFS="\n" read -r line; do
    #search for pattern ': <positive integer>' - the ': ' prefix makes sure that it is actually a field and not part of a name 
    value=$(echo $line | grep -o -E ': [0-9]+' | grep -o -E '[0-9]+')
    [ -z $value ] && continue
    key=$(echo $line | grep -o '".*"')
    map1[$key]=$value
done <"$1"

while IFS="\n" read -r line; do
    #loop through second file - print out missing values in 1 that are in 2
    #will check in next loop for missing values in 2 
    value=$(echo $line | grep -o -E ': [0-9]+' | grep -o -E '[0-9]+')
    key=$(echo $line | grep -o '".*"')
    if [[ -z $value && -z $key ]]; then
        echo $line
    elif [ -z $value ]; then
        if [ -z ${map1[$key]} ]; then
            echo $line
        fi
    elif [[ -z $key || -z ${map1[$key]} ]]; then
        #if the other key does not exist
        >&2 echo $key" : ,"$value
    else
        delta=`expr ${map1[$key]} - $value`
        echo $line | sed -r "s/: [0-9]+/: ${delta}/"
        map2[$key]=$value
    fi
done <"$2"
#check for missing values in 2 that are in 1
for key in "${!map1[@]}"; do
    if [ -z ${map2[$key]} ]; then
        >&2 echo $key" : "${map1[$key]}","
    fi
done
printf "}"
