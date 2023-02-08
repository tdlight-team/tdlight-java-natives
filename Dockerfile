ARG GH_MATRIX_SSL

FROM debian:buster as img_ssl1
ONBUILD ENV SSL_LIB_NAME=libssl1.1
FROM debian:bookworm as img_ssl3
ONBUILD ENV SSL_LIB_NAME=libssl3

FROM img_${GH_MATRIX_SSL} AS build
ARG REVISION
ARG GH_MATRIX_OS
ARG GH_MATRIX_ARCH
ARG GH_MATRIX_SSL
ARG IMPLEMENTATION_NAME
ARG CPU_CORES_NUM

ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LANG "en_US.UTF-8"
ENV JAVA_TOOL_OPTIONS "-Dfile.encoding=UTF8"
ENV CROSS_BUILD_DEPS_DIR "/var/cache/crossbuild-deps"

ADD implementations /usr/src/tdlight-java-natives/implementations
ADD scripts /usr/src/tdlight-java-natives/scripts
ADD src /usr/src/tdlight-java-natives/src

WORKDIR /usr/src/tdlight-java-natives/

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/crossbuild-deps,type=cache,sharing=locked \
    /bin/bash /usr/src/tdlight-java-natives/scripts/continuous-integration/docker/install-dependencies.sh
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    --mount=target=/var/cache/crossbuild-deps,type=cache,sharing=locked \
    /bin/bash /usr/src/tdlight-java-natives/scripts/continuous-integration/docker/build-natives.sh

#WORKDIR /usr/src/tdlight-java-natives/generated/
#RUN echo "aaaa" > test.txt

ENTRYPOINT [ "/bin/bash" ]
