FROM debian:buster-backports AS ssl1_debian
WORKDIR /build
SHELL ["/bin/bash", "-exc"]

ARG REVISION="1.0.0.0-SNAPSHOT"
ARG SCCACHE_GHA_ENABLED=off
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

ENV DEBIAN_FRONTEND=noninteractive
COPY .docker ./.docker
# Install sccache to greatly speedup builds in the CI
RUN --mount=type=cache,target=/opt/sccache,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked --mount=type=cache,target=/var/cache/sccache,sharing=locked .docker/install-sccache.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
--mount=type=cache,target=/var/lib/apt,sharing=locked \
--mount=type=cache,target=/var/cache/sccache,sharing=locked <<"EOF"
apt-get --assume-yes update
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends \
  openjdk-11-jdk-headless \
  g++-8 gcc-8 zlib1g-dev libssl-dev gperf \
  tree git maven php-cli php-readline make cmake

EOF

FROM ssl1_debian AS build
SHELL ["/bin/bash", "-exc"]
ARG REVISION="1.0.0.0-SNAPSHOT"
ARG SCCACHE_GHA_ENABLED=off
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

ENV TOOLCHAIN_FILE="toolchain.cmake"
ENV SCCACHE_DIR=/var/cache/sccache

# machine-specific flags
ENV HOST_CMAKE_C_COMPILER="/usr/bin/gcc-8"
ENV HOST_CMAKE_CXX_COMPILER="/usr/bin/g++-8"
ENV HOST_CMAKE_C_FLAGS=""
ENV HOST_CMAKE_CXX_FLAGS="${HOST_CMAKE_C_FLAGS}"
ENV HOST_CMAKE_EXE_LINKER_FLAGS=""

# Use c++11
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++14"

ENV CMAKE_C_FLAGS="${CMAKE_C_FLAGS}"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti"
ENV CMAKE_SHARED_LINKER_FLAGS="${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--exclude-libs,ALL"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -O3"
ENV CCACHE=/opt/sccache/sccache
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY --link . ./

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
cd implementations/tdlight/td_tools_build
CC="$HOST_CMAKE_C_COMPILER" CXX="$HOST_CMAKE_CXX_COMPILER" cmake \
  -DCMAKE_C_COMPILER="${HOST_CMAKE_C_COMPILER}" \
  -DCMAKE_CXX_COMPILER="${HOST_CMAKE_CXX_COMPILER}" \
  -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} ${HOST_CMAKE_C_FLAGS}" \
  -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} ${HOST_CMAKE_CXX_FLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${CMAKE_EXE_LINKER_FLAGS} ${HOST_CMAKE_EXE_LINKER_FLAGS}" \
  -DJAVA_AWT_LIBRARY="/dev/null" \
  -DJAVA_AWT_INCLUDE_PATH="/dev/null" \
  \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_C_FLAGS_RELEASE="" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O0 -DNDEBUG" \
  -DTD_ENABLE_LTO=OFF \
  -DTD_ENABLE_JNI=ON ..
cmake --build . --target prepare_cross_compiling --parallel "$(nproc)"
cmake --build . --target td_generate_java_api --parallel "$(nproc)"
cd ../../../

./implementations/tdlight/td_tools_build/td/generate/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./natives/src/main/java" "it/tdlight/jni"
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
cd implementations/tdlight/build
export INSTALL_PREFIX="$(readlink -e ./td_bin/)"
export INSTALL_BINDIR="$(readlink -e ./td_bin/bin)"
cmake \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TEST=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
  -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
  -DCMAKE_TOOLCHAIN_FILE="../../../${TOOLCHAIN_FILE}" ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../

cd natives/build
cmake \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DTD_GENERATED_BINARIES_DIR="$(readlink -e ../../implementations/tdlight/td_tools_build/td/generate)" \
  -DTD_SRC_DIR="$(readlink -e ../../implementations/tdlight)" \
  -DTD_ENABLE_LTO=ON \
  -DTDNATIVES_BIN_DIR="$(readlink -e ../tdjni_bin/)" \
  -DTDNATIVES_DOCS_BIN_DIR="$(readlink -e ../tdjni_docs/)" \
  -DTd_DIR:PATH="$(readlink -e ../../implementations/tdlight/build/td_bin/lib/cmake/Td)" \
  -DJAVA_SRC_DIR="$(readlink -e ../src/main/java)" \
  -DTDNATIVES_CPP_SRC_DIR="$(readlink -e ../src/main/cpp)" \
  -DCMAKE_TOOLCHAIN_FILE="../../${TOOLCHAIN_FILE}" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ..
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/libtdjni.so src/main/resources/META-INF/tdlightjni/libtdjni.linux_amd64_gnu_ssl1.so
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=linux_amd64_gnu_ssl1 package
EOF

FROM debian:buster-backports AS maven
SHELL ["/bin/bash", "-exc"]
WORKDIR /source
COPY --from=build /build/natives /source/natives
ENTRYPOINT ["/bin/true"]

FROM debian:buster-backports
ARG REVISION="1.0.0.0-SNAPSHOT"
WORKDIR /out
COPY --from=build /build/natives natives
COPY --from=build /build/natives/src/main/resources/META-INF/tdlightjni/libtdjni.linux_amd64_gnu_ssl1.so libtdjni.so
COPY --from=build /build/natives/target-linux_amd64_gnu_ssl1/tdlight-natives-${REVISION}-linux_amd64_gnu_ssl1.jar tdlight-natives.jar
USER 65534:65534
ENTRYPOINT ["/bin/true"]
