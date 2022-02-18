#!/bin/bash -e

if [[ "$CORE_VARIABLES_SET" != "YES" ]]; then
  echo "====== Setup variables ======"
  if [[ "$OPERATING_SYSTEM_NAME" != "osx" ]]; then
    echo "Current root directory:"
    realpath "."
  fi
  echo "============================="

  # ====== CPU Architecture Variables
  if [[ "$CPU_ARCHITECTURE_NAME" == "aarch64" ]]; then
    export CPU_ARCH_JAVA="arm64"
    export CPU_ARCH_JAVA_INTERNAL="aarch64"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="arm64"
    export CPU_ARCH_CMAKE="aarch64"
    export CPU_ARCH_LINUX="aarch64"
    export CLANG_TRIPLE="aarch64-linux-gnu"
    export CPU_COMPILATION_TOOL="gnu"
  elif [[ "$CPU_ARCHITECTURE_NAME" == "armhf" ]]; then
    export CPU_ARCH_JAVA="armhf"
    export CPU_ARCH_JAVA_INTERNAL="arm"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="armhf"
    export CPU_ARCH_CMAKE="arm"
    export CPU_ARCH_LINUX="arm"
    export CLANG_TRIPLE="arm-linux-gnueabihf"
    export CPU_COMPILATION_TOOL="gnueabihf"
  elif [[ "$CPU_ARCHITECTURE_NAME" == "s390x" ]]; then
    export CPU_ARCH_JAVA="s390x"
    export CPU_ARCH_JAVA_INTERNAL="s390x"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="s390x"
    export CPU_ARCH_CMAKE="s390x"
    export CPU_ARCH_LINUX="s390x"
    export CLANG_TRIPLE="s390x-linux-gnu"
    export CPU_COMPILATION_TOOL="gnu"
  elif [[ "$CPU_ARCHITECTURE_NAME" == "386" ]]; then
    export CPU_ARCH_JAVA="386"
    export CPU_ARCH_JAVA_INTERNAL="i386"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="i386"
    export CPU_ARCH_CMAKE="i686"
    export CPU_ARCH_LINUX="i386"
    export CLANG_TRIPLE="i386-linux-gnu"
    export CPU_COMPILATION_TOOL="gnu"
  elif [[ "$CPU_ARCHITECTURE_NAME" == "amd64" ]]; then
    export CPU_ARCH_JAVA="amd64"
    export CPU_ARCH_JAVA_INTERNAL="amd64"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="amd64"
    export CPU_ARCH_CMAKE="x86_64"
    export CPU_ARCH_LINUX="x86_64"
    export CLANG_TRIPLE="x86_64-linux-gnu"
    export CPU_COMPILATION_TOOL="gnu"
  elif [[ "$CPU_ARCHITECTURE_NAME" == "ppc64le" ]]; then
    export CPU_ARCH_JAVA="ppc64le"
    export CPU_ARCH_JAVA_INTERNAL="ppc64le"
    export JAVA_INSTALLATION_TYPE="server"
    export CPU_ARCH_DPKG="ppc64el"
    export CPU_ARCH_CMAKE="powerpc64le"
    export CPU_ARCH_LINUX="powerpc64le"
    export CLANG_TRIPLE="powerpc64-linux-gnu"
    export CPU_COMPILATION_TOOL="gnu"
  else
    echo "Unrecognized cpu arch: $CPU_ARCHITECTURE_NAME"
    exit 1
  fi

  export CPU_CORES_NUM="2"

  unset CROSS_BUILD_DEPS_DIR
  if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
    export CMAKE_EXTRA_ARGUMENTS_TDJNI="${CMAKE_EXTRA_ARGUMENTS_TDJNI} -DOPENSSL_USE_STATIC_LIBS=True"
  elif [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
    export CMAKE_EXTRA_ARGUMENTS_TDJNI="${CMAKE_EXTRA_ARGUMENTS_TDJNI} -DOPENSSL_USE_STATIC_LIBS=True"
  elif [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
    if [[ "$CPU_ARCHITECTURE_NAME" == "386" ]] || [[ "$CPU_ARCHITECTURE_NAME" == "armhf" ]]; then
      export CMAKE_EXE_LINKER_FLAGS="$CMAKE_EXE_LINKER_FLAGS -latomic"
      export LDFLAGS="$LDFLAGS -latomic"
      export CXXFLAGS="$CXXFLAGS -latomic"
    fi

    export CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    export CC="gcc"
    export CXX="g++"

    export CROSS_CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    if [[ "${CPU_ARCH_CMAKE}" == "x86_64" && "${CPU_COMPILATION_TOOL}" == "gnu" ]]; then
      export CROSS_CC="gcc"
      export CROSS_CXX="g++"
    else
      export CROSS_CC="${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-gcc"
      export CROSS_CXX="${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-g++"
    fi

    CROSS_BUILD_DEPS_DIR="$(realpath "../../")/.cache/tdlib-build-cross-${CPU_ARCH_DPKG}"
    export CROSS_BUILD_DEPS_DIR
  fi

  export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

  # ====== Print variables
  echo "========= Variables ========="
  echo "Variables"
  echo "JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS}"
  echo "CPU_ARCH_JAVA=${CPU_ARCH_JAVA}"
  echo "CPU_ARCH_JAVA_INTERNAL=${CPU_ARCH_JAVA_INTERNAL}"
  echo "JAVA_INSTALLATION_TYPE=${JAVA_INSTALLATION_TYPE}"
  echo "CPU_ARCH_DPKG=${CPU_ARCH_DPKG}"
  echo "CPU_ARCH_CMAKE=${CPU_ARCH_CMAKE}"
  echo "CPU_ARCH_LINUX=${CPU_ARCH_LINUX}"
  echo "CLANG_TRIPLE=${CLANG_TRIPLE}"
  echo "CPU_COMPILATION_TOOL=${CPU_COMPILATION_TOOL}"
  echo "CC=${CC}"
  echo "CXX=${CXX}"
  echo "CXXFLAGS=${CXXFLAGS}"
  echo "CMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}"
  echo "CMAKE_EXTRA_ARGUMENTS=${CMAKE_EXTRA_ARGUMENTS}"
  echo "CROSS_BUILD_DEPS_DIR=${CROSS_BUILD_DEPS_DIR}"
  echo "============================="

  export CORE_VARIABLES_SET="YES"
fi
