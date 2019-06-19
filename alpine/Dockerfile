From alpine:3.9.2
RUN apk add jq bash bc util-linux
COPY rudataall.sh /usr/local/bin
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
