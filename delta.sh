#!/bin/bash
#Ling-Hong Hung Oct 2018

#Usage delta.sh jsonfile1 jsonfile2

#Join the two files with tab in between 
paste -- $1 $2 |

#loop through lines and separate by tabs to get line1 from file1 and line2 from file2 
while IFS=$'\t' read -r line1 line2 rest; do
    #search for patter ': <positive integer>' - the ': ' prefix makes sure that it is actually a field and not part of a name 
    value1=$(echo $line1 | grep -o -E ': [0-9]+' | grep -o -E '[0-9]+')
    value2=$(echo $line2 | grep -o -E ': [0-9]+' | grep -o -E '[0-9]+')
    if [[ -z $value1 && -z $value2 ]]; then
        #both lines have no integer - print line2
        echo $line2
    elif [[ -z $value1 ]]; then
        #line2 has an integer but not line1 - indicate a missing value
        echo $line2 | sed -r "s/: [0-9]+/: missing1/"
    elif [[ -z $value2 ]]; then
        #line2 has and integer but not line2 - indicate a missing value
        echo $line1 | sed -r "s/: [0-9]+/: missing2/"
    else
        #both lines have integers - calculate the difference and substitute into line1
        delta=`expr $value2 - $value1`
        echo $line1 | sed -r "s/: [0-9]+/: ${delta}/"    
    fi
done
