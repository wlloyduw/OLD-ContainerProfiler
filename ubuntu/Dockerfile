From  ubuntu:18.04
RUN apt-get -y update \
    && apt-get install -y jq bc util-linux \
    && rm -rf /var/lib/apt/lists/*
COPY rudataall.sh /usr/local/bin
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
