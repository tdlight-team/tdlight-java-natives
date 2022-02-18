#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | s390x | armhf | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   BUILD_TYPE = <Debug | Release | RelWithDebInfo | MinSizeRel>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   CMAKE_EXTRA_ARGUMENTS = <args>
# OPTIONAL ENVIRONMENT VARIABLES:
#   CROSS_BUILD_DEPS_DIR = <args>

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
echo "Cross build deps dir: '${CROSS_BUILD_DEPS_DIR}'"

if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	if [ -z "${CROSS_BUILD_DEPS_DIR}" ]; then

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

		fix_jdk_path
		check_jdk_existance

		# Create toolchain
		echo "Creating toolchain file..."
		cd "$ROOT_DIR"
		{
			echo "set(CMAKE_SYSTEM_PROCESSOR ${CPU_ARCH_LINUX})";
			echo "set(CMAKE_C_COMPILER ${CROSS_CC})";
			echo "set(CMAKE_C_COMPILER_TARGET ${CLANG_TRIPLE})";
			echo "set(CMAKE_CXX_COMPILER ${CROSS_CXX})";
			echo "set(CMAKE_CXX_COMPILER_TARGET ${CLANG_TRIPLE})";
			echo "set(CMAKE_ASM_COMPILER ${CROSS_CXX})";
			echo "set(CMAKE_ASM_COMPILER_TARGET ${CLANG_TRIPLE})";
			echo "set(CMAKE_LIBRARY_PATH \"$CROSS_BUILD_DEPS_DIR/\")";
			echo "include_directories(\"${CROSS_BUILD_DEPS_DIR}/usr/include/${CPU_ARCH_LINUX}-linux-${CPU_COMPILATION_TOOL}/\")";
			echo "SET(CMAKE_FIND_ROOT_PATH \"$CROSS_BUILD_DEPS_DIR\" \"$JAVA_HOME\" \"/\" \"$JAVA_HOME/include\")";
			echo "include_directories(\"${CROSS_OPENJDK_PATH}/include\")";
			echo "include_directories(\"${CROSS_OPENJDK_PATH}/include/linux\")";

			echo "SET(JAVA_HOME \"$JAVA_HOME/\")";
			echo "SET(JAVA_INCLUDE_PATH \"$JAVA_HOME/include\")";
			echo "SET(JAVA_AWT_INCLUDE_PATH \"$JAVA_HOME/include\")";
			echo "SET(JAVA_INCLUDE_PATH2 \"$JAVA_HOME/include/linux\")";

			echo "SET(JAVA_JVM_LIBRARY \"$CROSS_OPENJDK_PATH/lib/${JAVA_INSTALLATION_TYPE}/libjvm.so\")";
			echo "SET(JAVA_AWT_LIBRARY \"$CROSS_OPENJDK_PATH/lib/libawt.so\")";
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
	fi
fi;

echo "Done."
exit 0
