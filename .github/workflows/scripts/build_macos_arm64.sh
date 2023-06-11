#!/bin/bash -ex
# MacOS 12
REVISION="${REVISION:-1.0.0.0-SNAPSHOT}"

# Create missing dirs
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs

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
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl/ \
  -DCMAKE_C_FLAGS_RELEASE="" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O0 -DNDEBUG" \
  -DTD_ENABLE_LTO=OFF \
  -DTD_ENABLE_JNI=ON \
  ..
cmake --build . --target prepare_cross_compiling --parallel "$(nproc)"
cmake --build . --target td_generate_java_api --parallel "$(nproc)"
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
INSTALL_PREFIX="$(realpath -e ./td_bin/)"
INSTALL_BINDIR="$(realpath -e ./td_bin/bin)"
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -DOPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl/ \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TEST=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
  -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
  ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../

cd natives/build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -DTD_GENERATED_BINARIES_DIR="$(realpath -e ../../implementations/tdlight/td_tools_build/td/generate)" \
  -DTD_SRC_DIR="$(realpath -e ../../implementations/tdlight)" \
  -DTD_ENABLE_LTO=ON \
  -DTDNATIVES_BIN_DIR="$(realpath -e ../tdjni_bin/)" \
  -DTDNATIVES_DOCS_BIN_DIR="$(realpath -e ../tdjni_docs/)" \
  -DTd_DIR:PATH="$(realpath -e ../../implementations/tdlight/build/td_bin/lib/cmake/Td)" \
  -DJAVA_SRC_DIR="$(realpath -e ../src/main/java)" \
  -DTDNATIVES_CPP_SRC_DIR="$(realpath -e ../src/main/cpp)" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ..
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/libtdjni.dylib src/main/resources/META-INF/tdlightjni/libtdjni.macos_arm64.dylib
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=macos_arm64 package
