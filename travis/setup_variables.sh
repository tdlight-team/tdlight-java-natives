#!/bin/bash -e
set -e

# ====== Variables
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/javax.crypto=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED"
if [ "$TRAVIS_CPU_ARCH" = "arm64" ]; then
    export CPU_ARCHITECTURE_NAME="aarch64"
    export CPU_CORES_NUM="2"
else
    CPU_ARCHITECTURE_NAME="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_CPU_ARCH}")"
    export CPU_ARCHITECTURE_NAME;
    export CPU_CORES_NUM="2"
fi
OPERATING_SYSTEM_NAME="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_OS_NAME}")"
export OPERATING_SYSTEM_NAME
if [ "$OPERATING_SYSTEM_NAME" = "windows" ]; then
	export OPERATING_SYSTEM_NAME_SHORT="win"
else
	export OPERATING_SYSTEM_NAME_SHORT=$OPERATING_SYSTEM_NAME
fi

echo "====== Setup variables ======"
echo "Current root directory:"
echo "$(realpath .)"
echo "============================="

# ====== OS Variables
if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
  export VCPKG_DIR="$(realpath .)/vcpkg"
  export CMAKE_EXTRA_ARGUMENTS="-A x64 -DCMAKE_TOOLCHAIN_FILE:FILEPATH=$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON"
  export PATH="$PATH:/c/tools/php74:/c/PHP:/c/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64:/c/Program Files/OpenJDK/openjdk-11.0.8_10/bin:/c/Program Files/CMake/bin:/c/ProgramData/chocolatey/bin:/c/Program Files/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/maven/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/base64/tools:/c/Program Files/NASM"
  export JAVA_HOME="/c/Program Files/OpenJDK/openjdk-11.0.8_10"
  export CPU_CORES=" -- -m"
  export CMAKE_BUILD_TYPE=Release
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  export CMAKE_EXTRA_ARGUMENTS=""
  export PATH="$PATH:$(/usr/libexec/java_home -v 14)"
  export JAVA_HOME="$(/usr/libexec/java_home -v 14)"
  export JAVA_INCLUDE_PATH="$(/usr/libexec/java_home -v 14)/include"
  export CPU_CORES=" -- -j${CPU_CORES_NUM}"
  export CXXFLAGS="-stdlib=libstdc++"
elif [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  export CMAKE_EXTRA_ARGUMENTS=""
  export TRAVIS_CPU_ARCH_JAVA="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_CPU_ARCH}")"
  export PATH="$PATH:/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA/bin"
  export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA"
  export JAVA_INCLUDE_PATH="/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA/include"
  export CPU_CORES=" -- -j${CPU_CORES_NUM}"
  export CXXFLAGS="-stdlib=libc++"
  export CFLAGS="-stdlib=libc++"
  export CC="/usr/bin/clang-10"
  export CXX="/usr/bin/clang++-10"
fi

# ====== Print variables
echo "TD_SRC_DIR=${TD_SRC_DIR}"
echo "TD_BIN_DIR=${TD_BIN_DIR}"
echo "TDNATIVES_BIN_DIR=${TDNATIVES_BIN_DIR}"
echo "TDNATIVES_CPP_SRC_DIR=${TDNATIVES_CPP_SRC_DIR}"
echo "TDNATIVES_DOCS_BIN_DIR=${TDNATIVES_DOCS_BIN_DIR}"
echo "TD_BUILD_DIR=${TD_BUILD_DIR}"
echo "TDNATIVES_CPP_BUILD_DIR=${TDNATIVES_CPP_BUILD_DIR}"
echo "JAVA_SRC_DIR=${JAVA_SRC_DIR}"
echo "TDLIB_SERIALIZER_DIR=${TDLIB_SERIALIZER_DIR}"
echo "PATH=${PATH}"
echo "JAVA_HOME=${JAVA_HOME}"
echo "JAVA_INCLUDE_PATH=${JAVA_INCLUDE_PATH}"
echo "CMAKE_EXTRA_ARGUMENTS=${CMAKE_EXTRA_ARGUMENTS}"
echo "VCPKG_DIR=${VCPKG_DIR}"
echo "MAVEN_OPTS=${MAVEN_OPTS}"
echo "TRAVIS_CPU_ARCH=${TRAVIS_CPU_ARCH}"
echo "TRAVIS_CPU_ARCH_JAVA=${TRAVIS_CPU_ARCH_JAVA}"
echo "CPU_ARCHITECTURE_NAME=${CPU_ARCHITECTURE_NAME}"
echo "CPU_CORES_NUM=${CPU_CORES_NUM}"
echo "CPU_CORES=${CPU_CORES}"
echo "TRAVIS_OS_NAME=${TRAVIS_OS_NAME}"
echo "OPERATING_SYSTEM_NAME=${OPERATING_SYSTEM_NAME}"
echo "OPERATING_SYSTEM_NAME_SHORT=${OPERATING_SYSTEM_NAME}"
echo "SRC_TDJNI_LIBNAME=${SRC_TDJNI_LIBNAME}"
echo "DEST_TDJNI_LIBNAME=${DEST_TDJNI_LIBNAME}"
