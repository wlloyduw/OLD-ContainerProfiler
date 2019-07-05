# Test Dockerfile contents:
FROM ubuntu
RUN apt-get -y update
RUN apt-get install -y postgresql postgresql-contrib
RUN apt-get install -y bc
RUN /etc/init.d/postgresql start
#RUN pgbench -i -p 5432 -d postgres
COPY entrypoint_test.sh /
ENTRYPOINT ["/entrypoint_test.sh"]
CMD ["6000"]

