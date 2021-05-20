# Varik Hoang <varikmp@uw.edu>
FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /data
COPY ./profiler .
COPY ./rudataall-psutil.py .
RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential gcc cmake libbz2-dev zlib1g-dev python3 python3-dev python3-setuptools python3-pip docker docker.io \
    && pip3 install psutil \
    && apt-get remove -y python3-pip python3-setuptools python3-dev zlib1g-dev libbz2-dev cmake gcc build-essential \
    && apt-get autoclean -y && apt-get autoremove -y --purge && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apk*
ENTRYPOINT ["./profiler"]
