# kallisto index command with filename and its path
kallisto index -i /.nbdocker/kallisto/human_trans.kidx /.nbdocker/kallisto/human_trans.fa.gz &
# Run rudataall.sh till the kallisto process is running
while [ 1 ]; do
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
