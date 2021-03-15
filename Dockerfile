FROM debian:bullseye

ARG REVISION
ARG GH_MATRIX_OS
ARG GH_MATRIX_ARCH
ARG IMPLEMENTATION_NAME

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt upgrade -y

RUN apt install -y sudo openjdk-11-jdk locales
#RUN apt install -y make git zlib1g-dev libssl-dev gperf cmake clang-10 libc++-10-dev libc++abi-10-dev ccache maven python3 python3-pip php7.4-cli openjdk-15-jdk

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

ADD implementations /usr/src/tdlight-java-natives/implementations
ADD scripts /usr/src/tdlight-java-natives/scripts
ADD src /usr/src/tdlight-java-natives/src

WORKDIR /usr/src/tdlight-java-natives/

RUN /bin/bash -c "export JAVA_HOME=\"/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep openjdk | head -n 1)/\"; export JAVA_INCLUDE_PATH=\"$JAVA_HOME/include\"; source ./scripts/continuous-integration/github-workflows/setup-variables.sh; source ./scripts/continuous-integration/github-workflows/install-dependencies.sh; source ./scripts/continuous-integration/github-workflows/build-natives.sh"

#WORKDIR /usr/src/tdlight-java-natives/generated/
#RUN echo "aaaa" > test.txt

ENTRYPOINT [ "/bin/bash" ]
