ARG REVISION
ARG GH_MATRIX_OS
ARG GH_MATRIX_ARCH
ARG GH_MATRIX_SSL
ARG IMPLEMENTATION_NAME
ARG CPU_CORES_NUM

FROM ubuntu:jammy as img_ssl1
ONBUILD ENV SSL_LIB_NAME=libssl1.1
FROM debian:oldstable as img_ssl3
ONBUILD ENV SSL_LIB_NAME=libssl3

FROM img_${GH_MATRIX_SSL}

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt upgrade -y

RUN apt install -y sudo build-essential openjdk-11-jdk locales wget cmake gperf ccache maven \
    libssl-dev ${SSL_LIB_NAME} zlib1g-dev zlib1g

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG "en_US.UTF-8"
ENV JAVA_TOOL_OPTIONS "-Dfile.encoding=UTF8"

ADD implementations /usr/src/tdlight-java-natives/implementations
ADD scripts /usr/src/tdlight-java-natives/scripts
ADD src /usr/src/tdlight-java-natives/src

WORKDIR /usr/src/tdlight-java-natives/

RUN /bin/bash /usr/src/tdlight-java-natives/scripts/continuous-integration/docker/build-natives.sh

#WORKDIR /usr/src/tdlight-java-natives/generated/
#RUN echo "aaaa" > test.txt

ENTRYPOINT [ "/bin/bash" ]
