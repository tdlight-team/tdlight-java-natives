#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armv6 | armv7 | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
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
if [ -z "${CPU_CORES}" ]; then
	echo "Missing parameter: CPU_CORES"
	exit 1
fi

cd ../../

# Print details
echo "Compiling td..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/td_build/ ] && rm -r ./generated/td_build/
[ -d ./generated/td_bin/ ] && rm -r ./generated/td_bin/

# Create missing folders
echo "Creating missing folders..."
[ -d ./generated/td_build/ ] || mkdir ./generated/td_build/
[ -d ./generated/td_bin/ ] || mkdir ./generated/td_bin/

# Configure cmake
echo "Configuring CMake..."
cd ./generated/td_build/
if [[ "$IMPLEMENTATION_NAME" = "tdlight" ]]; then
  export CMAKE_EXTRA_ARGUMENTS_TD="-DTD_SKIP_BENCHMARK=ON -DTD_SKIP_TEST=ON -DTD_SKIP_TG_CLI=ON"
else
  export CMAKE_EXTRA_ARGUMENTS_TD=""
fi
cmake -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX:PATH=$(realpath -m ../td_bin/) \
 -DTD_ENABLE_JNI=ON \
 ${CMAKE_EXTRA_ARGUMENTS_TD} \
 ${CMAKE_EXTRA_ARGUMENTS} \
 ../implementation

# Build
echo "Compiling ${IMPLEMENTATION_NAME} td..."
cmake --build . --target install --config Release ${CPU_CORES}


echo "Done."
exit 0
