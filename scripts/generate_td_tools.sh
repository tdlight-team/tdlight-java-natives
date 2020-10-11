#!/bin/bash -e
# REQUIRED PARAMETERS:
# OPERATING_SYSTEM_NAME = <windows | linux | osx>
# CPU_ARCHITECTURE_NAME = <amd64 | aarch64>
# IMPLEMENTATION_NAME = <tdlib | tdlight>
# CPU_CORES = <cores>
# CMAKE_EXTRA_ARGUMENTS = <args>

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

cd ../

# Print details
echo "Generating td tools..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/implementation/ ] && rm -r ./generated/implementation/
[ -d ./generated/td_tools/ ] && rm -r ./generated/td_tools/

# Copy implementation files
echo "Copying implementation files..."
cp -r implementations/${IMPLEMENTATION_NAME} ./generated/implementation

# Configure cmake
echo "Configuring CMake..."
mkdir ./generated/td_tools/
cd ./generated/td_tools/
cmake -DCMAKE_BUILD_TYPE=Release -DTD_ENABLE_JNI=ON ${CMAKE_EXTRA_ARGUMENTS} ../implementation/

# Run cmake to generate common tools
echo "Generating cross compilation tools..."
cmake --build . --target prepare_cross_compiling --config Release ${CPU_CORES}

# Run cmake to generate java tools
echo "Generating java tools..."
cmake --build . --target td_generate_java_api --config Release ${CPU_CORES}

echo "Generated executable '$(realpath -m ./td/generate/generate_common)'"
echo "Generated executable '$(realpath -m ./td/generate/td_generate_java_api)'"
echo "Generated executable '$(realpath -m ./td/generate/td_generate_json)'"
echo "Generated executable '$(realpath -m ../implementation/td/generate/JavadocTlDocumentationGenerator.php)'"
echo "Generated executable '$(realpath -m ../implementation/td/generate/TlDocumentationGenerator.php)'"
echo "Generated executable '$(realpath -m ../implementation/td/generate/scheme/td_api.tl)'"
echo "Generated executable '$(realpath -m ../implementation/td/generate/scheme/td_api.tlo)'"

echo "Done."
exit 0
