FROM debian:bookworm-backports AS ssl3_debian
WORKDIR /build
SHELL ["/bin/bash", "-exc"]

ARG REVISION="1.0.0.0-SNAPSHOT"
# amd64, i386, ppc64el, riscv64, armhf, arm64
ARG ARCH_DEBIAN
# x86_64, i386, powerpc64le, riscv64, arm, aarch64
ARG ARCH_TRIPLE
# gnu, gnueabihf (armhf)
ARG TRIPLE_GNU
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

export LLVMLIBS_NATIVE="libc++-14-dev libc++abi-14-dev libunwind-14-dev libunwind-14 libclang-rt-14-dev"
export LLVMLIBS_TARGET="libc++-14-dev:${ARCH_DEBIAN} libc++abi-14-dev:${ARCH_DEBIAN} libunwind-14-dev:${ARCH_DEBIAN} libunwind-14:${ARCH_DEBIAN} libclang-rt-14-dev:${ARCH_DEBIAN}"

apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends $LLVMLIBS_TARGET
find /usr/lib/ -path "*-linux-*" -lname "*llvm*" -print0 | xargs -0 -I{} sh -c 'cp --remove-destination $(realpath "{}") "{}"'

apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends git \
  zlib1g-dev libssl-dev gperf g++ \
  php-cli make cmake llvm-14 clang-14 lld-14 \
  libgcc-11-dev libclang-common-14-dev \
  git maven php-readline ca-certificates-java \
  openjdk-17-jdk-headless libssl-dev:${ARCH_DEBIAN} zlib1g-dev:${ARCH_DEBIAN} \
  libgcc-11-dev:${ARCH_DEBIAN} libc6-dev:${ARCH_DEBIAN} $LLVMLIBS_NATIVE
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install --no-install-recommends openjdk-17-jdk-headless:${ARCH_DEBIAN}
EOF

FROM ssl3_debian AS build
SHELL ["/bin/bash", "-exc"]
ARG REVISION="1.0.0.0-SNAPSHOT"
ARG ARCH_DEBIAN
ARG ARCH_TRIPLE
ARG TRIPLE_GNU
ARG SCCACHE_GHA_ENABLED=off
ARG ACTIONS_CACHE_URL
ARG ACTIONS_RUNTIME_TOKEN

ENV TOOLCHAIN_FILE="toolchain.cmake"
ENV SCCACHE_DIR=/var/cache/sccache2

# machine-specific flags
ENV HOST_CMAKE_C_COMPILER="/usr/bin/clang-14"
ENV HOST_CMAKE_CXX_COMPILER="/usr/bin/clang++-14"
ENV HOST_CMAKE_C_FLAGS="-fuse-ld=lld"
ENV HOST_CMAKE_CXX_FLAGS="${HOST_CMAKE_C_FLAGS} -stdlib=libc++"
ENV HOST_CMAKE_EXE_LINKER_FLAGS="-lc++ -lc++abi -fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind"

# Use c++11
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++14"

ENV CC="/usr/bin/gcc-8"
ENV CXX="/usr/bin/g++-8"
ENV CMAKE_C_FLAGS="${CMAKE_C_FLAGS}"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti"
ENV CMAKE_SHARED_LINKER_FLAGS="${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--exclude-libs,ALL"
ENV CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -flto=thin -O3"
ENV CCACHE=/opt/sccache/sccache
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

COPY --link . ./

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
cd implementations/tdlight/td_tools_build
CXXFLAGS="-stdlib=libc++" CC="$HOST_CMAKE_C_COMPILER" CXX="$HOST_CMAKE_CXX_COMPILER" cmake \
  -DCMAKE_C_COMPILER="${HOST_CMAKE_C_COMPILER}" \
  -DCMAKE_CXX_COMPILER="${HOST_CMAKE_CXX_COMPILER}" \
  -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} ${HOST_CMAKE_C_FLAGS}" \
  -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} ${HOST_CMAKE_CXX_FLAGS}" \
  -DCMAKE_EXE_LINKER_FLAGS="${CMAKE_EXE_LINKER_FLAGS} ${HOST_CMAKE_EXE_LINKER_FLAGS}" \
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
EOF

RUN --mount=type=cache,target=/root/.m2 <<"EOF"
./implementations/tdlight/td_tools_build/td/generate/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./natives/src/main/java" "it/tdlight/jni"
EOF

COPY <<EOF ./toolchain.cmake
set(CMAKE_CROSSCOMPILING TRUE)
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR $ARCH_TRIPLE)
set(TARGET_TRIPLE $ARCH_TRIPLE-linux-$TRIPLE_GNU)

if(EXISTS "/usr/bin/clang-14")
  set(CMAKE_C_COMPILER /usr/bin/clang-14)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++-14)
  set(CMAKE_ASM_COMPILER /usr/bin/clang-14)
  set(CMAKE_AR "/usr/bin/llvm-ar-14" CACHE FILEPATH "" FORCE)
elseif(EXISTS "/usr/bin/clang-12")
  set(CMAKE_C_COMPILER /usr/bin/clang-12)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++-12)
  set(CMAKE_ASM_COMPILER /usr/bin/clang-12)
  set(CMAKE_AR "/usr/bin/llvm-ar-12" CACHE FILEPATH "" FORCE)
elseif(EXISTS "/usr/bin/clang-9")
  set(CMAKE_C_COMPILER /usr/bin/clang-9)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++-9)
  set(CMAKE_ASM_COMPILER /usr/bin/clang-9)
  set(CMAKE_AR "/usr/bin/llvm-ar-9" CACHE FILEPATH "" FORCE)
else()
  set(CMAKE_C_COMPILER /usr/bin/clang)
  set(CMAKE_CXX_COMPILER /usr/bin/clang++)
  set(CMAKE_ASM_COMPILER /usr/bin/clang)
  set(CMAKE_AR "/usr/bin/llvm-ar" CACHE FILEPATH "" FORCE)
endif()

set(CMAKE_C_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_CXX_COMPILER_TARGET \${TARGET_TRIPLE})
set(CMAKE_ASM_COMPILER_TARGET \${TARGET_TRIPLE})

set(CMAKE_INCLUDE_PATH /usr/include/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/include/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/include)
set(CMAKE_LIBRARY_PATH /usr/lib/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/lib/\${TARGET_TRIPLE} /root/cross-build-pkgs/lib/\${TARGET_TRIPLE})
set(CMAKE_PROGRAM_PATH /usr/bin/\${TARGET_TRIPLE} /root/cross-build-pkgs/usr/bin/\${TARGET_TRIPLE})

# Set various compiler flags
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind")
set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ -std=c++14")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

# Use our definitions for compiler tools
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# This must be set or compiler checks fail when linking
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if(EXISTS "/usr/lib/jvm/java-17-openjdk-amd64")
  SET(JAVA_HOME "/usr/lib/jvm/java-17-openjdk-amd64")
else()
  SET(JAVA_HOME "/usr/lib/jvm/default-java")
endif()
SET(JAVA_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_AWT_INCLUDE_PATH "\${JAVA_HOME}/include")
SET(JAVA_INCLUDE_PATH2 "\${JAVA_HOME}/include/linux")
SET(JAVA_CROSS_HOME "/usr/lib/jvm/java-17-openjdk-$ARCH_DEBIAN")
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
cd implementations/tdlight/build
export INSTALL_PREFIX="$(readlink -e ./td_bin/)"
export INSTALL_BINDIR="$(readlink -e ./td_bin/bin)"
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
  -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
  -DCMAKE_TOOLCHAIN_FILE="../../../${TOOLCHAIN_FILE}" ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
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
  -DCMAKE_TOOLCHAIN_FILE="../../${TOOLCHAIN_FILE}" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../
EOF

RUN --mount=type=cache,target=/opt/sccache,sharing=locked \
--mount=type=cache,target=/var/cache/sccache2,sharing=locked \
--mount=type=cache,target=/root/.m2 <<"EOF"
cd natives
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/libtdjni.so src/main/resources/META-INF/tdlightjni/libtdjni.linux_${ARCH_DEBIAN}_clang_ssl3.so
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=linux_${ARCH_DEBIAN}_clang_ssl3 package
cd ..
EOF

FROM debian:bookworm-backports AS maven
SHELL ["/bin/bash", "-exc"]
WORKDIR /source
COPY --from=build /build/natives /source/natives
ENTRYPOINT ["/bin/true"]

FROM debian:bookworm-backports
ARG REVISION="1.0.0.0-SNAPSHOT"
ARG ARCH_DEBIAN
ARG ARCH_TRIPLE
ARG TRIPLE_GNU
WORKDIR /out
COPY --from=build /build/natives natives
COPY --from=build /build/natives/src/main/resources/META-INF/tdlightjni/libtdjni.linux_${ARCH_DEBIAN}_clang_ssl3.so libtdjni.so
COPY --from=build /build/natives/target-linux_${ARCH_DEBIAN}_clang_ssl3/tdlight-natives-${REVISION}-linux_${ARCH_DEBIAN}_clang_ssl3.jar tdlight-natives.jar
USER 65534:65534
ENTRYPOINT ["/bin/true"]
