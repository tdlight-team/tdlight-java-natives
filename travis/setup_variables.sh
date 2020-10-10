#!/bin/bash -e
set -e

# ====== Variables
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/javax.crypto=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED"
if [ "$TRAVIS_CPU_ARCH" = "arm64" ]; then
    export CPU_ARCHITECTURE_NAME="aarch64"
    export CPU_CORES="2"
else
    CPU_ARCHITECTURE_NAME="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_CPU_ARCH}")"
    export CPU_ARCHITECTURE_NAME;
    export CPU_CORES="2"
fi
OPERATING_SYSTEM_NAME="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_OS_NAME}")"
export OPERATING_SYSTEM_NAME
if [ "$OPERATING_SYSTEM_NAME" = "windows" ]; then
	export OPERATING_SYSTEM_NAME_SHORT="win"
else
	export OPERATING_SYSTEM_NAME_SHORT=$OPERATING_SYSTEM_NAME
fi

# ====== OS Variables
if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
  export PATH="$PATH:/c/tools/php74:/c/PHP:/c/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64:/c/Program Files/OpenJDK/openjdk-11.0.8_10/bin:/c/Program Files/CMake/bin:/c/ProgramData/chocolatey/bin:/c/Program Files/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/maven/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/base64/tools:/c/Program Files/NASM"
  export JAVA_HOME="/c/Program Files/OpenJDK/openjdk-11.0.8_10"
  export VCPKG_DIR=$TRAVIS_BUILD_DIR/vcpkg
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  PATH="$PATH:$(/usr/libexec/java_home -v 14)"
  export PATH
  JAVA_HOME="$(/usr/libexec/java_home -v 14)"
  export JAVA_HOME
  JAVA_INCLUDE_PATH="$(/usr/libexec/java_home -v 14)/include"
  export JAVA_INCLUDE_PATH
elif [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  TRAVIS_CPU_ARCH_JAVA="$(tr '[:upper:]' '[:lower:]'<<<"${TRAVIS_CPU_ARCH}")"
  export TRAVIS_CPU_ARCH_JAVA
  export PATH="$PATH:/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA/bin"
  export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA"
  export JAVA_INCLUDE_PATH="/usr/lib/jvm/java-11-openjdk-$TRAVIS_CPU_ARCH_JAVA/include"
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
echo "VCPKG_DIR=${VCPKG_DIR}"
echo "MAVEN_OPTS=${MAVEN_OPTS}"
echo "TRAVIS_CPU_ARCH=${TRAVIS_CPU_ARCH}"
echo "TRAVIS_CPU_ARCH_JAVA=${TRAVIS_CPU_ARCH_JAVA}"
echo "TRAVIS_CPU_ARCH_STANDARD=${TRAVIS_CPU_ARCH_STANDARD}"
echo "TRAVIS_OS_NAME=${TRAVIS_OS_NAME}"
echo "TRAVIS_OS_NAME_STANDARD=${TRAVIS_OS_NAME_STANDARD}"
echo "TRAVIS_OS_NAME_SHORT=${TRAVIS_OS_NAME_SHORT}"
echo "SRC_TDJNI_LIBNAME=${SRC_TDJNI_LIBNAME}"
echo "DEST_TDJNI_LIBNAME=${DEST_TDJNI_LIBNAME}"
