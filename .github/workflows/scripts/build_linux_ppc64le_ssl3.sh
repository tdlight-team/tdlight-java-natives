#!/bin/bash -ex
# Ubuntu 22.04
REVISION="${REVISION:-1.0.0.0-SNAPSHOT}"
TOOLCHAIN_FILE="$(readlink -e ./.github/workflows/toolchains/toolchain_ppc64le.cmake)"

# Create missing dirs
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs

# machine-specific flags
HOST_CMAKE_C_COMPILER="/usr/bin/clang-14"
HOST_CMAKE_CXX_COMPILER="/usr/bin/clang++-14"
HOST_CMAKE_C_FLAGS="-fuse-ld=lld"
HOST_CMAKE_CXX_FLAGS="${HOST_CMAKE_C_FLAGS} -stdlib=libc++"
HOST_CMAKE_EXE_LINKER_FLAGS="-lc++ -lc++abi -fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind"

# ccache
CCACHE=$(which sccache || true)
if [[ -x "$CCACHE" ]]; then
  echo "found sccache: $CCACHE"
else
  echo "sccache not found"
  CCACHE=$(which ccache)
fi

# Build tdlib tools
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
  -DTD_ENABLE_JNI=ON \
  ..
cmake --build . --target prepare_cross_compiling "-j$(nproc)"
cmake --build . --target td_generate_java_api "-j$(nproc)"
cd ../../../

# Generate TdApi.java
./implementations/tdlight/td_tools_build/td/generate/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./natives/src/main/java" "it/tdlight/jni"


# Optimization flags
export CMAKE_C_FLAGS="${CMAKE_C_FLAGS}"
export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti"
export CMAKE_SHARED_LINKER_FLAGS="${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--exclude-libs,ALL"
export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -flto=thin -O3"

# Build tdlib
cd implementations/tdlight/build
INSTALL_PREFIX="$(readlink -e ./td_bin/)"
INSTALL_BINDIR="$(readlink -e ./td_bin/bin)"
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
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
  ..
cmake --build . --target install --config Release "-j$(nproc)"
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
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
  ../src/main/cpp
cmake --build . --target install --config Release "-j$(nproc)"
cd ..
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/libtdjni.so src/main/resources/META-INF/tdlightjni/libtdjni.linux_ppc64le_ssl3.so
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=linux_ppc64le_ssl3 package
