FROM ubuntu
RUN apt-get update
#RUN apt-get install -y vim 
RUN apt-get install -y sysbench 
RUN apt-get install -y man jq bc
COPY rudataall.sh /root
COPY rudatadelta.sh /root
COPY delta.sh /root
COPY deltav2.sh /root
COPY profile.sh /root
RUN chmod u+x /root/*.sh
