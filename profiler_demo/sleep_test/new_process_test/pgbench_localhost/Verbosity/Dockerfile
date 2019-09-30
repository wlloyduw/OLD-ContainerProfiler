# Test Dockerfile contents:
FROM ubuntu
RUN apt-get -y update
RUN apt-get install -y postgresql postgresql-contrib
RUN apt-get install -y bc
COPY entrypoint_test.sh /
ENTRYPOINT ["/entrypoint_test.sh"]
CMD ["6000"]

