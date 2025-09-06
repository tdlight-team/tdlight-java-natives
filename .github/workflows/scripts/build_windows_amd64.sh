#!/bin/bash -ex

# Change working directory
DEPLOY_DIR="$(pwd)"
cp -r . /c/tmp_tdlight
cd /c/tmp_tdlight

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
export VCPKG_DIR="$VCPKG_ROOT"

echo "CMAKE_TOOLCHAIN_FILE=$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake"

echo "VCPKG_DIR:"
tree $VCPKG_DIR
echo "Tmp tdlight dir:"
tree /c/tmp_tdlight

# Build tdlib tools
cd implementations/tdlight/td_tools_build
cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
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
INSTALL_PREFIX="$(readlink -e ./td_bin/)"
INSTALL_BINDIR="$(readlink -e ./td_bin/bin)"
cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
  -DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TG_CLI=ON \
  -DTD_ENABLE_LTO=ON \
  -DTD_ENABLE_JNI=ON \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
  -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
  ..
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ../../../

cd natives/build
cmake \
  -DCMAKE_C_COMPILER_LAUNCHER="$CCACHE" \
  -DCMAKE_CXX_COMPILER_LAUNCHER="$CCACHE" \
  -DOPENSSL_USE_STATIC_LIBS=True \
  -A x64 -DCMAKE_TOOLCHAIN_FILE="$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake" -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON \
  -DTD_GENERATED_BINARIES_DIR="$(readlink -e ../../implementations/tdlight/td_tools_build/td/generate/Release)" \
  -DTD_SRC_DIR="$(readlink -e ../../implementations/tdlight)" \
  -DTD_ENABLE_LTO=ON \
  -DTDNATIVES_BIN_DIR="$(readlink -e ../tdjni_bin/)" \
  -DTDNATIVES_DOCS_BIN_DIR="$(readlink -e ../tdjni_docs/)" \
  -DTd_DIR:PATH="$(readlink -e ../../implementations/tdlight/build/td_bin/lib/cmake/Td)" \
  -DJAVA_SRC_DIR="$(readlink -e ../src/main/java)" \
  -DTDNATIVES_CPP_SRC_DIR="$(readlink -e ../src/main/cpp)" \
  ../src/main/cpp
cmake --build . --target install --config Release --parallel "$(nproc)"
cd ..
mkdir -p src/main/resources/META-INF/tdlightjni/
mv tdjni_bin/tdjni.dll src/main/resources/META-INF/tdlightjni/tdjni.windows_amd64.dll
mvn -B -f pom.xml -Drevision="$REVISION" -Dnative.type.classifier=windows_amd64 package

# Restore original working directory
cp -r "../natives/" "$DEPLOY_DIR/"
cd "$DEPLOY_DIR"
