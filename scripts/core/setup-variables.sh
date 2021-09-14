#!/bin/bash -e

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
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "armv6" ]]; then
	export CPU_ARCH_JAVA="armv6"
	export CPU_ARCH_DPKG="armhf"
	export CPU_ARCH_CMAKE="arm"
	export CLANG_TRIPLE="arm-linux-gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "armv7" ]]; then
	export CPU_ARCH_JAVA="armv7"
	export CPU_ARCH_DPKG="armhf"
	export CPU_ARCH_CMAKE="arm"
	export CLANG_TRIPLE="arm-linux-gnueabihf"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "386" ]]; then
	export CPU_ARCH_JAVA="386"
	export CPU_ARCH_DPKG="i386"
	export CPU_ARCH_CMAKE="i386"
	export CLANG_TRIPLE="i386-linux-gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "amd64" ]]; then
	export CPU_ARCH_JAVA="amd64"
	export CPU_ARCH_DPKG="amd64"
	export CPU_ARCH_CMAKE="x86_64"
	export CLANG_TRIPLE="x86_64-linux-gnu"
	export CPU_CORES_NUM="2"
elif [[ "$CPU_ARCHITECTURE_NAME" == "ppc64le" ]]; then
	export CPU_ARCH_JAVA="ppc64le"
	export CPU_ARCH_DPKG="ppc64el"
	export CPU_ARCH_CMAKE="ppc64el"
	export CLANG_TRIPLE="powerpc64-linux-gnu"
	export CPU_CORES_NUM="2"
else
	echo "Unrecognized cpu arch: $CPU_ARCHITECTURE_NAME"
	exit 1
fi

unset CROSS_BUILD_DEPS_DIR
export CROSS_BUILD_DEPS_DIR
if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	if [[ "$CPU_ARCHITECTURE_NAME" == "aarch64" ]]; then
		export CMAKE_EXTRA_ARGUMENTS="$CMAKE_EXTRA_ARGUMENTS"
	else
		export CMAKE_EXTRA_ARGUMENTS="$CMAKE_EXTRA_ARGUMENTS -DOPENSSL_USE_STATIC_LIBS=ON -DCMAKE_FIND_LIBRARY_SUFFIXES=\".a\""
	fi

	if [[ "$CPU_ARCHITECTURE_NAME" == "386" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armv6" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armv7" ]]; then
		export CMAKE_EXE_LINKER_FLAGS="$CMAKE_EXE_LINKER_FLAGS -latomic"
		export LDFLAGS="$LDFLAGS -latomic"
		export CXXFLAGS="$CXXFLAGS -latomic"
	fi

	export CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
	export CC="gcc"
	export CXX="g++"

	export CROSS_CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
	export CROSS_CC="${CPU_ARCH_CMAKE}-linux-gnu-gcc"
	export CROSS_CXX="${CPU_ARCH_CMAKE}-linux-gnu-g++"

  CROSS_BUILD_DEPS_DIR="$(realpath "../../")/.cache/tdlib-build-cross-${CPU_ARCH_DPKG}/"
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