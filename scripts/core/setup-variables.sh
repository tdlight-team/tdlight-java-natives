#!/bin/bash -e

if [[ "$CORE_VARIABLES_SET" == "YES" ]]; then
  exit 0
fi

echo "====== Setup variables ======"
if [[ "$OPERATING_SYSTEM_NAME" != "osx" ]]; then
  echo "Current root directory:"
  realpath "."
fi
echo "============================="

# ====== CPU Architecture Variables
if [[ "$CPU_ARCHITECTURE_NAME" == "aarch64" ]]; then
	export CPU_ARCH_JAVA="arm64"
	export CPU_ARCH_DPKG="arm64"
	export CPU_ARCH_CMAKE="aarch64"
	export CLANG_TRIPLE="aarch64-linux-gnu"
	export CPU_COMPILATION_TOOL="gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "armhf" ]]; then
	export CPU_ARCH_JAVA="armhf"
	export CPU_ARCH_DPKG="armhf"
	export CPU_ARCH_CMAKE="arm"
	export CLANG_TRIPLE="arm-linux-gnueabihf"
	export CPU_COMPILATION_TOOL="gnueabihf"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "s390x" ]]; then
	export CPU_ARCH_JAVA="s390x"
	export CPU_ARCH_DPKG="s390x"
	export CPU_ARCH_CMAKE="s390x"
	export CLANG_TRIPLE="s390x-linux-gnu"
	export CPU_COMPILATION_TOOL="gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "386" ]]; then
	export CPU_ARCH_JAVA="386"
	export CPU_ARCH_DPKG="i386"
	export CPU_ARCH_CMAKE="i386"
	export CLANG_TRIPLE="i386-linux-gnu"
	export CPU_COMPILATION_TOOL="gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "amd64" ]]; then
	export CPU_ARCH_JAVA="amd64"
	export CPU_ARCH_DPKG="amd64"
	export CPU_ARCH_CMAKE="x86_64"
	export CLANG_TRIPLE="x86_64-linux-gnu"
	export CPU_COMPILATION_TOOL="gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "ppc64le" ]]; then
	export CPU_ARCH_JAVA="ppc64le"
	export CPU_ARCH_DPKG="ppc64el"
	export CPU_ARCH_CMAKE="ppc64el"
	export CLANG_TRIPLE="powerpc64-linux-gnu"
	export CPU_COMPILATION_TOOL="gnu"
	export CPU_CORES_NUM="2"
else
	echo "Unrecognized cpu arch: $CPU_ARCHITECTURE_NAME"
	exit 1
fi

unset CROSS_BUILD_DEPS_DIR
if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	if [[ "$CPU_ARCHITECTURE_NAME" == "aarch64" ]]; then
		export CMAKE_EXTRA_ARGUMENTS="$CMAKE_EXTRA_ARGUMENTS"
	else
		export CMAKE_EXTRA_ARGUMENTS="$CMAKE_EXTRA_ARGUMENTS -DOPENSSL_USE_STATIC_LIBS=ON -DCMAKE_FIND_LIBRARY_SUFFIXES=\".a\""
	fi

	if [[ "$CPU_ARCHITECTURE_NAME" == "386" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armhf" ]]; then
		export CMAKE_EXE_LINKER_FLAGS="$CMAKE_EXE_LINKER_FLAGS -latomic"
		export LDFLAGS="$LDFLAGS -latomic"
		export CXXFLAGS="$CXXFLAGS -latomic"
	fi

	export CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
	export CC="gcc"
	export CXX="g++"

	export CROSS_CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
	export CROSS_CC="${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-gcc"
	export CROSS_CXX="${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-g++"

  CROSS_BUILD_DEPS_DIR="$(realpath "../../")/.cache/tdlib-build-cross-${CPU_ARCH_DPKG}/"
  export CROSS_BUILD_DEPS_DIR
fi

# ====== Print variables
echo "========= Variables ========="
echo "Variables"
echo "CPU_ARCH_JAVA=${CPU_ARCH_JAVA}"
echo "CPU_ARCH_DPKG=${CPU_ARCH_DPKG}"
echo "CPU_ARCH_CMAKE=${CPU_ARCH_CMAKE}"
echo "CLANG_TRIPLE=${CLANG_TRIPLE}"
echo "CC=${CC}"
echo "CXX=${CXX}"
echo "CXXFLAGS=${CXXFLAGS}"
echo "CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}"
echo "CMAKE_EXTRA_ARGUMENTS=${CMAKE_EXTRA_ARGUMENTS}"
echo "CROSS_BUILD_DEPS_DIR=${CROSS_BUILD_DEPS_DIR}"
echo "============================="

export CORE_VARIABLES_SET="YES"
