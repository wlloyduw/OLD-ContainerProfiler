#!/bin/bash
#produces delta.json and missing.txt
../deltav2.sh rudata_all_1_missing.json rudata_all_2_missing.json 2>missing.txt 1>delta.json
