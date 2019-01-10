# kallisto quant command with bootstrap = 30 and thread = 8
kallisto quant -i /.nbdocker/kallisto/human_trans.kidx -b 30 --bias -t 8 -o /.nbdocker/kallisto/SRR493366  /.nbdocker/kallisto/SRR493366_1.fastq.gz /.nbdocker/kallisto/SRR493366_2.fastq.gz &
while [ 1 ]; do
  # Run rudataall.sh till the kallisto process is running
  PID=$(pgrep -x "kallisto" 2>/dev/null)
  if kill -0 $PID > /dev/null; then
    today=`date '+%Y_%m_%d__%H_%M_%S'`;
    file_name="$today.json"
    /.nbdocker/kallisto/rudataall.sh > $file_name
    sleep 1
  else
    break
  fi
done
