#!/bin/bash -ex

# Change working directory
DEPLOY_DIR="$(pwd)"
BUILD_DIR="/c/tmp_tdlight"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r . "$BUILD_DIR"
cd "$BUILD_DIR"
BUILD_DIR="$(pwd)"

# Windows 2019
REVISION="${REVISION:-1.0.0.0-SNAPSHOT}"

# Create missing dirs
rm -rf implementations/tdlight/td_tools_build implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs
mkdir -p implementations/tdlight/build  implementations/tdlight/build/td_bin/bin implementations/tdlight/td_tools_build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni natives/src/main/java/it/tdlight/jni natives/build natives/tdjni_bin natives/tdjni_docs

# ccache
CCACHE=$(which sccache || true)
if [[ -x "$CCACHE" ]]; then
  CCACHE="sccache"
  echo "found sccache: $CCACHE"
else
  echo "sccache not found"
  CCACHE="ccache"
fi

# Fix path
export PATH="$PATH:/c/Python3:$PATH:/c/tools/php74:/c/PHP:/c/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64:/c/Program Files/OpenJDK/openjdk-11.0.8_10/bin:/c/Program Files/CMake/bin:/c/ProgramData/chocolatey/bin:/c/Program Files/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/maven/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/base64/tools:/c/Program Files/NASM"
export VCPKG_DIR="$(readlink -e ./.vcpkg)"

echo "CMAKE_TOOLCHAIN_FILE=$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake"

# Build tdlib tools
cd implementations/tdlight/td_tools_build
cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DZLIB_USE_STATIC_LIBS=True \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
  -DOPENSSL_ROOT_DIR="$VCPKG_DIR/installed/x64-windows-static" \
  -DCMAKE_C_FLAGS_RELEASE="" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O0 -DNDEBUG" \
  -DTD_ENABLE_LTO=OFF \
  -DTD_ENABLE_JNI=ON \
  ..
cmake --build . --target prepare_cross_compiling --config Release --parallel "$(nproc)"
cmake --build . --target td_generate_java_api --config Release --parallel "$(nproc)"
cd ../../../

# Generate TdApi.java
./implementations/tdlight/td_tools_build/td/generate/Release/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./natives/src/main/java" "it/tdlight/jni"



# Optimization flags
export CMAKE_C_FLAGS="${CMAKE_C_FLAGS}"
export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti"
export CMAKE_SHARED_LINKER_FLAGS="${CMAKE_SHARED_LINKER_FLAGS} -Wl,--gc-sections -Wl,--exclude-libs,ALL"
export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -flto=thin -O3"

# Build tdlib
cd implementations/tdlight/build
INSTALL_PREFIX="$BUILD_DIR/implementations/tdlight/build/td_bin"
mkdir -p "$INSTALL_PREFIX"
INSTALL_PREFIX="$(readlink -e "$INSTALL_PREFIX")"
INSTALL_BINDIR="$INSTALL_PREFIX/bin"
mkdir -p "$INSTALL_BINDIR"
INSTALL_BINDIR="$(readlink -e "$INSTALL_BINDIR")"
cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DZLIB_USE_STATIC_LIBS=True \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
  -DOPENSSL_ROOT_DIR="$VCPKG_DIR/installed/x64-windows-static" \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$(cygpath -m "$INSTALL_PREFIX")" \
  -DCMAKE_INSTALL_BINDIR:PATH="$(cygpath -m "$INSTALL_BINDIR")" \
  ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../

cd natives/build
TD_GENERATED_BINARIES_DIR="$(cygpath -m "$BUILD_DIR/implementations/tdlight/td_tools_build/td/generate/Release")"
TD_SRC_DIR="$(cygpath -m "$BUILD_DIR/implementations/tdlight")"
TDNATIVES_BIN_DIR="$(cygpath -m "$BUILD_DIR/natives/tdjni_bin")"
TDNATIVES_DOCS_BIN_DIR="$(cygpath -m "$BUILD_DIR/natives/tdjni_docs")"
Td_DIR="$(cygpath -m "$INSTALL_PREFIX/lib/cmake/Td")"
JAVA_SRC_DIR="$(cygpath -m "$BUILD_DIR/natives/src/main/java")"
TDNATIVES_CPP_SRC_DIR="$(cygpath -m "$BUILD_DIR/natives/src/main/cpp")"
WIN_VCPKG_DIR="$(cygpath -m "$VCPKG_DIR")"

cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DZLIB_USE_STATIC_LIBS=True \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$WIN_VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
  -DOPENSSL_ROOT_DIR="$WIN_VCPKG_DIR/installed/x64-windows-static" \
  -DTD_GENERATED_BINARIES_DIR="$TD_GENERATED_BINARIES_DIR" \
  -DTD_SRC_DIR="$TD_SRC_DIR" \
  -DTD_ENABLE_LTO=ON \
  -DTDNATIVES_BIN_DIR="$TDNATIVES_BIN_DIR" \
  -DTDNATIVES_DOCS_BIN_DIR="$TDNATIVES_DOCS_BIN_DIR" \
  -DTd_DIR:PATH="$Td_DIR" \
  -DCMAKE_PREFIX_PATH="$(cygpath -m "$INSTALL_PREFIX")" \
  -DJAVA_SRC_DIR="$JAVA_SRC_DIR" \
  -DTDNATIVES_CPP_SRC_DIR="$TDNATIVES_CPP_SRC_DIR" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ..
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/tdjni.dll src/main/resources/META-INF/tdlightjni/tdjni.windows_amd64.dll
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=windows_amd64 package

# Restore original working directory
cp -r "../natives/" "$DEPLOY_DIR/"
cd "$DEPLOY_DIR"
