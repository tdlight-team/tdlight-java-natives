#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armv6 | armv7 | ppc64le>
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

# Print details
echo "Configuring td..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "Build type: ${BUILD_TYPE}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/td_build/ ] && rm -r ./generated/td_build/

# Create missing folders
echo "Creating missing folders..."
[ -d ./generated/td_build/ ] || mkdir ./generated/td_build/

# Configure cmake
echo "Configuring CMake..."
cd ./generated/td_build/
export CMAKE_EXTRA_ARGUMENTS_TD;
if [[ "$IMPLEMENTATION_NAME" = "tdlight" ]]; then
  CMAKE_EXTRA_ARGUMENTS_TD="-DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TEST=ON -DTD_SKIP_TG_CLI=ON"
else
  CMAKE_EXTRA_ARGUMENTS_TD=""
fi
if [[ -z "$CROSS_BUILD_DEPS_DIR" ]]; then
 # shellcheck disable=SC2089
 CMAKE_EXTRA_ARGUMENTS_TD="${CMAKE_EXTRA_ARGUMENTS_TD} -DCMAKE_TOOLCHAIN_FILE=${CROSS_BUILD_DEPS_DIR}/toolchain.cmake"
fi
INSTALL_PREFIX="$(realpath -m ../td_bin/)"
INSTALL_BINDIR="$(realpath -m ../td_bin/bin)"
echo "Install prefix: $INSTALL_PREFIX"
echo "Install bindir: $INSTALL_BINDIR"
# shellcheck disable=SC2086
cmake "-DCMAKE_BUILD_TYPE=${BUILD_TYPE}" \
 -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_PREFIX" \
 -DCMAKE_INSTALL_BINDIR:PATH="$INSTALL_BINDIR" \
 -DTD_ENABLE_JNI=ON \
 ${CMAKE_EXTRA_ARGUMENTS_TD} \
 ${CMAKE_EXTRA_ARGUMENTS} \
 ../implementation

echo "Done."
exit 0
