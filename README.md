# ContainerProfiler
**deltav2**.sh calculates the delta from 2 json files produced by **rudataall.sh**

It writes the deltas to stdout in json format and the missing fields to stderr

####Usage:
```bash
deltav2.sh file1.json file2.json 2>missing.txt 1>delta.json
```
Test file and scripts are found in testFiles

####Description
Basically it loops through file1 to find key : numeric_value pairs and store them in an associative array. It then loops through file2 to print out the json elements and calculate deltas. Missing values in file1 are printed here and a second key numericValue associative array is mad. A third loop then searches through the first associative array to fine missing values in file2. 

As long as there is no more than one key : value pair per line in the json files and the key is unique (i.e. doesn't depend on the structure of the higher order json objects), the script should work fine. It is tolerant of order permutations, new or different fields, and missing lines but depends on file2 being valid json.