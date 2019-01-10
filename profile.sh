# RU profiling demonstration script
./rudataall.sh > rudata_all_1.json
sysbench --test=cpu --cpu-max-prime=200000 --max-requests=100 run
./rudataall.sh > rudata_all_2.json
./delta.sh rudata_all_1.json rudata_all_2.json | jq
#jq < rudata_delta.json
