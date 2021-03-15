FROM ubuntu:groovy

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y
RUN apt install -y make git zlib1g-dev libssl-dev gperf cmake clang-10 libc++-10-dev libc++abi-10-dev ccache maven python3 python3-pip php7.4-cli openjdk-15-jdk

WORKDIR /usr/src/tdlight-java-natives/scripts/utils

ADD implementations /usr/src/tdlight-java-natives/implementations
ADD scripts /usr/src/tdlight-java-natives/scripts
ADD src /usr/src/tdlight-java-natives/src

RUN ./compile-natives-package.sh

ENTRYPOINT [ "/bin/bash" ]
