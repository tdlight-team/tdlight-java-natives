FROM debian:buster-backports AS ssl1_debian
WORKDIR /build
SHELL ["/bin/bash", "-exc"]

ARG REVISION="1.0.0.0-SNAPSHOT"
# amd64, i386, ppc64el, riscv64, armhf, arm64
ARG ARCH_DEBIAN
# x86_64, i386, powerpc64le, riscv64, arm, aarch64
ARG ARCH_TRIPLE
# gnu, gnueabihf (armhf)
ARG TRIPLE_GNU
ARG NATIVE="false"
ARG SCCACHE_GHA_ENABLED=off
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

# Check for mandatory build arguments
RUN : "${ARCH_DEBIAN:?Build argument needs to be set and non-empty.}"
RUN : "${ARCH_TRIPLE:?Build argument needs to be set and non-empty.}"
RUN : "${TRIPLE_GNU:?Build argument needs to be set and non-empty.}"

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

ENV DEBIAN_FRONTEND=noninteractive
COPY .docker ./.docker
# Install sccache to greatly speedup builds in the CI
RUN --mount=type=cache,target=/opt/sccache,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked --mount=type=cache,target=/var/cache/sccache2,sharing=locked .docker/install-sccache.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
--mount=type=cache,target=/var/lib/apt,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked <<"EOF"
dpkg --add-architecture ${ARCH_DEBIAN}
apt-get --assume-yes update
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends openjdk-11-jdk-headless
if [[ "$NATIVE" != "true" ]]; then
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp libssl-dev:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp libssl1.1:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp zlib1g-dev:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp zlib1g:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp openjdk-11-jre-headless:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/downloadthis.sh /var/cache/apt/downloaded_tmp openjdk-11-jdk-headless:${ARCH_DEBIAN} /root/cross-build-pkgs/
    ./.docker/SymlinkPrefix.javash "/root/cross-build-pkgs/" "/" "./"
fi
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends \
  g++ gcc libstdc++-8-dev zlib1g-dev libssl-dev gperf \
  tree git maven php-cli php-readline make cmake

if [[ "$NATIVE" != "true" ]]; then
    apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends \
      g++-8-${ARCH_TRIPLE/_/-}-linux-${TRIPLE_GNU} gcc-8-${ARCH_TRIPLE/_/-}-linux-${TRIPLE_GNU} \
      libatomic1-${ARCH_DEBIAN}-cross libc6-dev-${ARCH_DEBIAN}-cross libgcc-8-dev-${ARCH_DEBIAN}-cross libstdc++-8-dev-${ARCH_DEBIAN}-cross
fi

EOF

FROM ssl1_debian AS build
SHELL ["/bin/bash", "-exc"]
ARG REVISION="1.0.0.0-SNAPSHOT"
ARG ARCH_DEBIAN
ARG ARCH_TRIPLE
ARG TRIPLE_GNU
ARG NATIVE=false
ARG SCCACHE_GHA_ENABLED=off
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

ENV TOOLCHAIN_FILE="toolchain.cmake"
ENV SCCACHE_DIR=/var/cache/sccache2

# Use c++11
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS}"

ENV CMAKE_C_FLAGS="${CMAKE_C_FLAGS}"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti"
ENV CMAKE_SHARED_LINKER_FLAGS="${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--exclude-libs,ALL"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -flto -O3"
ENV CCACHE=/opt/sccache/sccache
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY --link . ./

COPY <<EOF ./toolchain_native.cmake
set(CMAKE_CROSSCOMPILING FALSE)
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR $ARCH_TRIPLE)
set(TARGET_TRIPLE $ARCH_TRIPLE-linux-$TRIPLE_GNU)

set(CMAKE_C_COMPILER /usr/bin/gcc-8)
set(CMAKE_CXX_COMPILER /usr/bin/g++-8)
set(CMAKE_AR "/usr/bin/gcc-ar-8" CACHE FILEPATH "" FORCE)

set(CMAKE_C_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_ASM_COMPILER_TARGET \${TARGET_TRIPLE})

set(CMAKE_INCLUDE_PATH /usr/include/\${TARGET_TRIPLE} /usr/include)
set(CMAKE_LIBRARY_PATH /usr/lib/\${TARGET_TRIPLE} /lib/\${TARGET_TRIPLE})
set(CMAKE_PROGRAM_PATH /usr/bin/\${TARGET_TRIPLE})

# Set various compiler flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_CXX_FLAGS_INIT "-flto -fno-fat-lto-objects")

if(EXISTS "/usr/lib/jvm/java-11-openjdk-amd64")
  SET(JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64")
else()
  SET(JAVA_HOME "/usr/lib/jvm/default-java")
endif()
SET(JAVA_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_AWT_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_INCLUDE_PATH2 "\${JAVA_HOME}/include/linux")
SET(JAVA_CROSS_HOME "/usr/lib/jvm/java-11-openjdk-$ARCH_DEBIAN")
SET(JAVA_JVM_LIBRARY "\${JAVA_CROSS_HOME}/lib/server/libjvm.so")
SET(JAVA_AWT_LIBRARY "\${JAVA_CROSS_HOME}/lib/libawt.so")
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
export TOOLCHAIN_ARGS; if [[ "$NATIVE" == "true" ]]; then TOOLCHAIN_ARGS="toolchain_native.cmake"; else TOOLCHAIN_ARGS="toolchain.cmake"; fi
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
cd implementations/tdlight/td_tools_build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_C_FLAGS_RELEASE="" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O0 -DNDEBUG" \
  -DTD_ENABLE_LTO=OFF \
  -DTD_ENABLE_JNI=ON \
  -DJAVA_AWT_LIBRARY=/dev/null \
  -DJAVA_AWT_INCLUDE_PATH=/dev/null \
  -DCMAKE_TOOLCHAIN_FILE="../../../toolchain_native.cmake" \
  ..
cmake --build . --target prepare_cross_compiling --parallel "$(nproc)"
cmake --build . --target td_generate_java_api --parallel "$(nproc)"
cd ../../../
EOF

RUN <<"EOF"
./implementations/tdlight/td_tools_build/td/generate/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./natives/src/main/java" "it/tdlight/jni"
EOF

COPY <<EOF ./toolchain.cmake
set(CMAKE_CROSSCOMPILING TRUE)
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR $ARCH_TRIPLE)
set(TARGET_TRIPLE $ARCH_TRIPLE-linux-$TRIPLE_GNU)

set(CMAKE_C_COMPILER /usr/bin/\${TARGET_TRIPLE}-gcc-8)
set(CMAKE_CXX_COMPILER /usr/bin/\${TARGET_TRIPLE}-g++-8)
set(CMAKE_AR "/usr/bin/\${TARGET_TRIPLE}-gcc-ar-8" CACHE FILEPATH "" FORCE)

set(CMAKE_C_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_ASM_COMPILER_TARGET \${TARGET_TRIPLE})

set(CMAKE_INCLUDE_PATH /usr/include/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/include/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/include)
set(CMAKE_LIBRARY_PATH /usr/lib/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/lib/\${TARGET_TRIPLE} /root/cross-build-pkgs/lib/\${TARGET_TRIPLE})
set(CMAKE_PROGRAM_PATH /usr/bin/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/bin/\${TARGET_TRIPLE})

# Set various compiler flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-flto -fno-fat-lto-objects")
set(CMAKE_CXX_FLAGS_INIT "-flto -fno-fat-lto-objects")

set(CMAKE_SYSROOT /root/cross-build-pkgs)

# This must be set or compiler checks fail when linking
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if(EXISTS "/usr/lib/jvm/java-11-openjdk-amd64")
  SET(JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64")
else()
  SET(JAVA_HOME "/usr/lib/jvm/default-java")
endif()
SET(JAVA_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_AWT_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_INCLUDE_PATH2 "\${JAVA_HOME}/include/linux")
SET(JAVA_CROSS_HOME "/root/cross-build-pkgs/usr/lib/jvm/java-11-openjdk-$ARCH_DEBIAN")
SET(JAVA_JVM_LIBRARY "\${JAVA_CROSS_HOME}/lib/server/libjvm.so")
SET(JAVA_AWT_LIBRARY "\${JAVA_CROSS_HOME}/lib/libawt.so")

if("$ARCH_DEBIAN" STREQUAL "armhf" OR "$ARCH_DEBIAN" STREQUAL "arm64")
    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_WIN32_THREADS_INIT 0)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
endif()
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
export TOOLCHAIN_ARGS; if [[ "$NATIVE" == "true" ]]; then TOOLCHAIN_ARGS="toolchain_native.cmake"; else TOOLCHAIN_ARGS="toolchain.cmake"; fi
cd implementations/tdlight/build
export INSTALL_PREFIX="$(readlink -e ./td_bin/)"
export INSTALL_BINDIR="$(readlink -e ./td_bin/bin)"
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TEST=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
  -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
  -DJAVA_AWT_LIBRARY=/dev/null \
  -DJAVA_AWT_INCLUDE_PATH=/dev/null \
  -DCMAKE_TOOLCHAIN_FILE="../../../$TOOLCHAIN_ARGS" \
   ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
export TOOLCHAIN_ARGS; if [[ "$NATIVE" == "true" ]]; then TOOLCHAIN_ARGS="toolchain_native.cmake"; else TOOLCHAIN_ARGS="toolchain.cmake"; fi
cd natives/build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DTD_GENERATED_BINARIES_DIR="$(readlink -e ../../implementations/tdlight/td_tools_build/td/generate)" \
  -DTD_SRC_DIR="$(readlink -e ../../implementations/tdlight)" \
  -DTDNATIVES_BIN_DIR="$(readlink -e ../tdjni_bin/)" \
  -DTDNATIVES_DOCS_BIN_DIR="$(readlink -e ../tdjni_docs/)" \
  -DTd_DIR:PATH="$(readlink -e ../../implementations/tdlight/build/td_bin/lib/cmake/Td)" \
  -DJAVA_SRC_DIR="$(readlink -e ../src/main/java)" \
  -DTDNATIVES_CPP_SRC_DIR="$(readlink -e ../src/main/cpp)" \
  -DJAVA_AWT_LIBRARY=/dev/null \
  -DJAVA_AWT_INCLUDE_PATH=/dev/null \
  -DCMAKE_TOOLCHAIN_FILE="../../$TOOLCHAIN_ARGS" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ..
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/libtdjni.so src/main/resources/META-INF/tdlightjni/libtdjni.linux_${ARCH_DEBIAN}_gnu_ssl1.so
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=linux_${ARCH_DEBIAN}_gnu_ssl1 package
EOF

FROM debian:buster-backports AS maven
SHELL ["/bin/bash", "-exc"]
WORKDIR /source
COPY --from=build /build/natives /source/natives
ENTRYPOINT ["/bin/true"]

FROM debian:buster-backports
ARG REVISION="1.0.0.0-SNAPSHOT"
ARG ARCH_DEBIAN
ARG ARCH_TRIPLE
ARG TRIPLE_GNU
ARG NATIVE=off
WORKDIR /out
COPY --from=build /build/natives natives
COPY --from=build /build/natives/src/main/resources/META-INF/tdlightjni/libtdjni.linux_${ARCH_DEBIAN}_gnu_ssl1.so libtdjni.so
COPY --from=build /build/natives/target-linux_${ARCH_DEBIAN}_gnu_ssl1/tdlight-natives-${REVISION}-linux_${ARCH_DEBIAN}_gnu_ssl1.jar tdlight-natives.jar
USER 65534:65534
ENTRYPOINT ["/bin/true"]
