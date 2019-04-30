#Test Dockerfile contents:
FROM ubuntu
RUN apt-get update
RUN apt-get install -y stress-ng
RUN apt-get install -y sysbench
Run apt-get install -y vim
Run apt-get install -y man jq bc
COPY entrypoint_test.sh /
ENTRYPOINT ["/entrypoint_test.sh", "6000"]


