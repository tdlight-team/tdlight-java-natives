#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | s390x | armhf | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   BUILD_TYPE = <Debug | Release | RelWithDebInfo | MinSizeRel>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   CMAKE_EXTRA_ARGUMENTS = <args>

# Check variables correctness
if [ -z "${OPERATING_SYSTEM_NAME}" ]; then
	echo "Missing parameter: OPERATING_SYSTEM_NAME"
	exit 1
fi
if [ -z "${CPU_ARCHITECTURE_NAME}" ]; then
	echo "Missing parameter: CPU_ARCHITECTURE_NAME"
	exit 1
fi
if [ -z "${IMPLEMENTATION_NAME}" ]; then
	echo "Missing parameter: IMPLEMENTATION_NAME"
	exit 1
fi
if [ -z "${BUILD_TYPE}" ]; then
	echo "Missing parameter: BUILD_TYPE"
	exit 1
fi
if [ -z "${CPU_CORES}" ]; then
	echo "Missing parameter: CPU_CORES"
	exit 1
fi

source ./setup-variables.sh

cd ../../
ROOT_DIR="$(pwd)"

# Print details
echo "Installing dependencies..."
echo "Current directory: $ROOT_DIR"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "Build type: ${BUILD_TYPE}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

CROSS_OPENJDK_PATH=""
fix_jdk_path() {
  # Setup OpenJDK path
  CROSS_OPENJDK_PATH="$(find "$CROSS_BUILD_DEPS_DIR/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)"
}

check_jdk_existance() {
  if [[ ! -d "$CROSS_OPENJDK_PATH" ]]; then
    echo "Can't find cross OpenJDK at location $CROSS_OPENJDK_PATH"
    exit 1
  fi
}

if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
  fix_jdk_path
  if [[ ! -f "$CROSS_BUILD_DEPS_DIR/ok-012" ]]; then
    rm -rf "$CROSS_BUILD_DEPS_DIR" || true
    mkdir -p "$CROSS_BUILD_DEPS_DIR"
    cd "$CROSS_BUILD_DEPS_DIR"
    # LibZ-Dev
    wget "http://ftp.debian.org/debian/pool/main/z/zlib/zlib1g-dev_1.2.11.dfsg-1_${CPU_ARCH_DPKG}.deb" -O zlib1g-dev.deb
    ZLIB1G_DEV_DEB=zlib1g-dev.deb
    dpkg -x "$ZLIB1G_DEV_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$ZLIB1G_DEV_DEB"
    # LibZ
    wget "http://ftp.debian.org/debian/pool/main/z/zlib/zlib1g_1.2.11.dfsg-1_${CPU_ARCH_DPKG}.deb" -O zlib1g.deb
    ZLIB1G_DEB=zlib1g.deb
    dpkg -x "$ZLIB1G_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$ZLIB1G_DEB"
    # LibSSL-Dev
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl-dev_1.1.1d-0+deb10u7_${CPU_ARCH_DPKG}.deb" -O libssl-dev.deb
    LIBSSL_DEV_DEB=libssl-dev.deb
    dpkg -x "$LIBSSL_DEV_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$LIBSSL_DEV_DEB"
    # LibSSL
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1d-0+deb10u7_${CPU_ARCH_DPKG}.deb" -O libssl.deb
    LIBSSL_DEB=libssl.deb
    dpkg -x "$LIBSSL_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$LIBSSL_DEB"
    # Java Common
    wget "http://ftp.debian.org/debian/pool/main/j/java-common/java-common_0.71_all.deb" -O java-common.deb
    JC_DEB=java-common.deb
    dpkg -x "$JC_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$JC_DEB"
    # OpenJDK-JRE-Headless
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-11/openjdk-11-jre-headless_11.0.12+7-2~deb10u1_${CPU_ARCH_DPKG}.deb" -O jdk-11-jre-headless.deb
    OJDKRH_DEB=jdk-11-jre-headless.deb
    dpkg -x "$OJDKRH_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$OJDKRH_DEB"
    # OpenJDK-JRE
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-11/openjdk-11-jre_11.0.12+7-2~deb10u1_${CPU_ARCH_DPKG}.deb" -O jdk-11-jre.deb
    OJDKR_DEB=jdk-11-jre.deb
    dpkg -x "$OJDKR_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$OJDKR_DEB"
    # OpenJDK-JDK
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-11/openjdk-11-jdk-headless_11.0.12+7-2~deb10u1_${CPU_ARCH_DPKG}.deb" -O jdk-11-jdk-headless.deb
    OJDKJ_DEB=jdk-11-jdk-headless.deb
    dpkg -x "$OJDKJ_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$OJDKJ_DEB"
    # OpenJDK-GUI
    wget "http://security.debian.org/debian-security/pool/updates/main/o/openjdk-11/openjdk-11-jdk_11.0.12+7-2~deb10u1_${CPU_ARCH_DPKG}.deb" -O jdk-11-jdk.deb
    OJDKG_DEB=jdk-11-jdk.deb
    dpkg -x "$OJDKG_DEB" "$CROSS_BUILD_DEPS_DIR"
    rm "$OJDKG_DEB"

    # Fix symlinks
    find "$CROSS_BUILD_DEPS_DIR" -lname "/*" \
        -exec  sh -c "ln -sf \"\`echo \"$CROSS_BUILD_DEPS_DIR\$(readlink \$0)\"\`\" \"\$0\"" {} \;

    # Check if openjdk is found
    fix_jdk_path
    check_jdk_existance

    touch "$CROSS_BUILD_DEPS_DIR/ok-012"
  fi

  check_jdk_existance

  # Create toolchain
  echo "Creating toolchain file..."
  cd "$ROOT_DIR"
  {
    echo "set(CMAKE_SYSTEM_PROCESSOR ${CPU_ARCH_LINUX})";
    echo "set(CMAKE_C_COMPILER ${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-gcc)";
    echo "set(CMAKE_C_COMPILER_TARGET ${CLANG_TRIPLE})";
    echo "set(CMAKE_CXX_COMPILER ${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-g++)";
    echo "set(CMAKE_CXX_COMPILER_TARGET ${CLANG_TRIPLE})";
    echo "set(CMAKE_ASM_COMPILER ${CPU_ARCH_CMAKE}-linux-${CPU_COMPILATION_TOOL}-g++)";
    echo "set(CMAKE_ASM_COMPILER_TARGET ${CLANG_TRIPLE})";
    echo "set(CMAKE_LIBRARY_PATH \"$CROSS_BUILD_DEPS_DIR/\")";
    echo "include_directories(\"${CROSS_BUILD_DEPS_DIR}/usr/include/${CPU_ARCH_LINUX}-linux-${CPU_COMPILATION_TOOL}/\")";
    echo "SET(CMAKE_FIND_ROOT_PATH \"$CROSS_BUILD_DEPS_DIR\" \"$JAVA_HOME\" \"/\" \"/usr/lib/jvm/java-11-openjdk-amd64/include\")";
    echo "include_directories(\"${CROSS_OPENJDK_PATH}/include\")";
    echo "include_directories(\"${CROSS_OPENJDK_PATH}/include/linux\")";

    echo "SET(JAVA_HOME \"/usr/lib/jvm/java-11-openjdk-amd64/\")";
    echo "SET(JAVA_INCLUDE_PATH \"/usr/lib/jvm/java-11-openjdk-amd64/include\")";
    echo "SET(JAVA_AWT_INCLUDE_PATH \"/usr/lib/jvm/java-11-openjdk-amd64/include\")";
    echo "SET(JAVA_INCLUDE_PATH2 \"/usr/lib/jvm/java-11-openjdk-amd64/include/linux\")";
    #echo "SET(JAVA_JVM_LIBRARY \"/usr/lib/jvm/java-11-openjdk-amd64/jre/lib/amd64/${JAVA_INSTALLATION_TYPE}/libjvm.so\")";
    #echo "SET(JAVA_AWT_LIBRARY \"/usr/lib/jvm/java-11-openjdk-amd64/jre/lib/amd64/libawt.so\")";

    #echo "SET(JAVA_HOME \"$CROSS_OPENJDK_PATH\")";
    #echo "SET(JAVA_INCLUDE_PATH \"$CROSS_OPENJDK_PATH/include\")";
    #echo "SET(JAVA_INCLUDE_PATH2 \"$CROSS_OPENJDK_PATH/include/linux\")";
    echo "SET(JAVA_JVM_LIBRARY \"$CROSS_OPENJDK_PATH/jre/lib/${CPU_ARCH_JAVA_INTERNAL}/${JAVA_INSTALLATION_TYPE}/libjvm.so\")";
    echo "SET(JAVA_AWT_LIBRARY \"$CROSS_OPENJDK_PATH/jre/lib/${CPU_ARCH_JAVA_INTERNAL}/libawt.so\")";
    #echo "SET(JNI_INCLUDE_DIRS \"$CROSS_OPENJDK_PATH/include\" \"$CROSS_OPENJDK_PATH/include/linux\")";
    #echo "SET(Java_JAR_EXECUTABLE \"$CROSS_OPENJDK_PATH/bin/java\")";
    #echo "SET(Java_JAVAC_EXECUTABLE \"$CROSS_OPENJDK_PATH/bin/javac\")";
    #echo "SET(Java_JAVADOC_EXECUTABLE \"$CROSS_OPENJDK_PATH/bin/javadoc\")";
    #echo "SET(JNI_LIBRARIES \"$CROSS_OPENJDK_PATH/jre/lib/${CPU_ARCH_JAVA_INTERNAL}/${JAVA_INSTALLATION_TYPE}/libjvm.so\" \"$CROSS_OPENJDK_PATH/jre/lib/${CPU_ARCH_JAVA_INTERNAL}/libawt.so\")";
    #echo "SET(JNI_FOUND True)";
    #echo "MESSAGE(STATUS \"JNI INCLUDE DIRS: \${JNI_INCLUDE_DIRS}\")";
    #echo "MESSAGE(STATUS \"JNI LIBS: \${JNI_LIBRARIES}\")";
    cat <<EOF
SET(CMAKE_SYSTEM_NAME Linux)

# Use our definitions for compiler tools
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories only
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF
   if [[ ${CPU_ARCHITECTURE_NAME} == "aarch64" || ${CPU_ARCHITECTURE_NAME} == "armhf" ]]; then
     cat <<EOF
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)
EOF
    fi
  } > "$CROSS_BUILD_DEPS_DIR/toolchain.cmake"

fi;

echo "Done."
exit 0
