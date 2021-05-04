#!/bin/bash -e
set -e
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/sun.nio.ch=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/javax.crypto=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED"

echo "MATRIX_OS: $GH_MATRIX_OS"
echo "MATRIX_ARCH: $GH_MATRIX_ARCH"

if [ "$GH_MATRIX_OS" == "macos-10.15" ]; then
	export PCRE="E"
else
	export PCRE="r"
fi

export GH_CPU_ARCH=$(echo $GH_MATRIX_ARCH | sed -$PCRE 's/^(linux\/|windows\/|macos\/)?(386|amd64|arm64|ppc64le|arm)(\/(v6|v7))?$/\2\4/g')
export GH_OS_NAME=$(echo $GH_MATRIX_ARCH | sed -$PCRE 's/^((linux)\/|(windows)\/|(macos)\/)?(386|amd64|arm64|ppc64le|arm)(\/(v6|v7))?$/\2\3\4/g')

if [[ -z "$GH_OS_NAME" ]]; then
	export GH_OS_NAME=$(echo $GH_MATRIX_OS | sed -$PCRE 's/^([^-]+).*$/\1/g')
fi

if [[ "$GH_CPU_ARCH" == "arm64" ]]; then
	export CPU_ARCHITECTURE_NAME="aarch64"
	export CPU_ARCH_JAVA="arm64"
	export CPU_CORES_NUM="2"
elif [[ "$GH_CPU_ARCH" == "armv6" ]]; then
	export CPU_ARCHITECTURE_NAME="armv6"
	export CPU_ARCH_JAVA="armv6"
	export CPU_CORES_NUM="2"
elif [[ "$GH_CPU_ARCH" == "armv7" ]]; then
	export CPU_ARCHITECTURE_NAME="armv7"
	export CPU_ARCH_JAVA="armv7"
	export CPU_CORES_NUM="2"
elif [[ "$GH_CPU_ARCH" == "386" ]]; then
	export CPU_ARCHITECTURE_NAME="386"
	export CPU_ARCH_JAVA="386"
	export CPU_CORES_NUM="2"
elif [[ "$GH_CPU_ARCH" == "amd64" ]]; then
	export CPU_ARCHITECTURE_NAME="amd64"
	export CPU_ARCH_JAVA="amd64"
	export CPU_CORES_NUM="2"
elif [[ "$GH_CPU_ARCH" == "ppc64le" ]]; then
	export CPU_ARCHITECTURE_NAME="ppc64le"
	export CPU_ARCH_JAVA="ppc64le"
	export CPU_CORES_NUM="2"
else
	echo "Unrecognized cpu arch: $GH_CPU_ARCH"
	exit 1
fi

if [[ "$GH_OS_NAME" == "windows" ]]; then
	export OPERATING_SYSTEM_NAME="windows"
	export OPERATING_SYSTEM_NAME_SHORT="win"
elif [[ "$GH_OS_NAME" == "macos" ]]; then
	export OPERATING_SYSTEM_NAME="osx"
	export OPERATING_SYSTEM_NAME_SHORT="osx"
elif [[ "$GH_OS_NAME" == "linux" ]]; then
	export OPERATING_SYSTEM_NAME="linux"
	export OPERATING_SYSTEM_NAME_SHORT="linux"
else
	echo "Unrecognized os name: $GH_OS_NAME"
	exit 1
fi

echo "====== Setup variables ======"
echo "Current root directory:"
echo "$(realpath .)"
echo "============================="

# ====== OS Variables
if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	export CMAKE_BUILD_TYPE=MinSizeRel
	export BUILD_TYPE=MinSizeRel
	export VCPKG_DIR="$(realpath .)/vcpkg"
	export CMAKE_EXTRA_ARGUMENTS="-A x64 -DCMAKE_TOOLCHAIN_FILE:FILEPATH=$VCPKG_DIR/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static -DOPENSSL_USE_STATIC_LIBS=ON"
	export PATH="/c/Python3:$PATH:/c/tools/php74:/c/PHP:/c/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64:/c/Program Files/OpenJDK/openjdk-11.0.8_10/bin:/c/Program Files/CMake/bin:/c/ProgramData/chocolatey/bin:/c/Program Files/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/maven/apache-maven-3.6.3/bin:/c/ProgramData/chocolatey/lib/base64/tools:/c/Program Files/NASM"
	export CPU_CORES=" -- -m"
elif [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
	export BUILD_TYPE=MinSizeRel
	export CMAKE_EXTRA_ARGUMENTS="-DOPENSSL_ROOT_DIR=/usr/local/opt/openssl/"
	export CPU_CORES=" -- -j${CPU_CORES_NUM}"
elif [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	export BUILD_TYPE=MinSizeRel
	if [[ "$CPU_ARCHITECTURE_NAME" == "aarch64" ]]; then
		export CMAKE_EXTRA_ARGUMENTS=""
	else
		export CMAKE_EXTRA_ARGUMENTS="-DOPENSSL_USE_STATIC_LIBS=ON -DCMAKE_FIND_LIBRARY_SUFFIXES=\".a\""
	fi

	if [[ "$CPU_ARCHITECTURE_NAME" == "386" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armv6" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armv7" ]]; then
		export CMAKE_EXE_LINKER_FLAGS="$CMAKE_EXE_LINKER_FLAGS -latomic"
		export LDFLAGS="$LDFLAGS -latomic"
		export CXXFLAGS="$CXXFLAGS -latomic"
	fi

	export CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
	export CC="/usr/bin/clang"
	export CXX="/usr/bin/clang++"

	export CPU_CORES=" -- -j${CPU_CORES_NUM}"
fi

# ====== Print variables
echo "REVISION=${REVISION}"
echo "BUILD_TYPE=${BUILD_TYPE}"
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
echo "GH_CPU_ARCH=${GH_CPU_ARCH}"
echo "CPU_ARCH_JAVA=${CPU_ARCH_JAVA}"
echo "CPU_ARCHITECTURE_NAME=${CPU_ARCHITECTURE_NAME}"
echo "CPU_CORES_NUM=${CPU_CORES_NUM}"
echo "CPU_CORES=${CPU_CORES}"
echo "GH_OS_NAME=${GH_OS_NAME}"
echo "GH_MATRIX_ARCH=${GH_MATRIX_ARCH}"
echo "OPERATING_SYSTEM_NAME=${OPERATING_SYSTEM_NAME}"
echo "OPERATING_SYSTEM_NAME_SHORT=${OPERATING_SYSTEM_NAME_SHORT}"
echo "SRC_TDJNI_LIBNAME=${SRC_TDJNI_LIBNAME}"
echo "DEST_TDJNI_LIBNAME=${DEST_TDJNI_LIBNAME}"
