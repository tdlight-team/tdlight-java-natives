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

source ./setup-variables.sh

cd ../../
JAVA_API_PACKAGE_PATH="it/tdlight/jni"
JAVA_LIB_PACKAGE_PATH="it/tdlight/tdnative"

# Print details
echo "Generating TdApi.java..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"
echo "JAVA_API_PACKAGE_PATH: '${JAVA_API_PACKAGE_PATH}'"
echo "JAVA_LIB_PACKAGE_PATH: '${JAVA_LIB_PACKAGE_PATH}'"

# Setup constants
if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	export PYTHON_EXECUTABLE="python"
else
	export PYTHON_EXECUTABLE="python3"
fi

# Delete old data
echo "Deleting old data..."
[ -d ./generated/tdjni_build/ ] && rm -r ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] && rm -r ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] && rm -r ./generated/tdjni_docs/
[ -f ./generated/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java ] && rm ./generated/src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java

# Create missing folders
echo "Creating missing folders..."
[ -d "./generated/src/main/java/${JAVA_API_PACKAGE_PATH}/" ] || mkdir -p "./generated/src/main/java/${JAVA_API_PACKAGE_PATH}/"
[ -d "./generated/src/main/java/${JAVA_LIB_PACKAGE_PATH}/" ] || mkdir -p "./generated/src/main/java/${JAVA_LIB_PACKAGE_PATH}/"
[ -d ./generated/tdjni_build/ ] || mkdir ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] || mkdir ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] || mkdir ./generated/tdjni_docs/

# Copy executables
echo "Copying executables..."
export TD_GENERATED_BINARIES_DIR;
if [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	TD_GENERATED_BINARIES_DIR="$(realpath -m ./generated/td_tools/td/generate/Release)"
else
	TD_GENERATED_BINARIES_DIR="$(realpath -m ./generated/td_tools/td/generate)"
fi
# Configure cmake
echo "Configuring CMake..."
cd ./generated/
echo "Telegram source path: '$(realpath -m ./implementation/)'"

# Run cmake to generate TdApi.java
echo "Generating TdApi.java..."
./td_tools/td/generate/td_generate_java_api TdApi "./implementation/td/generate/scheme/td_api.tlo" "./src/main/java" "$JAVA_API_PACKAGE_PATH"
php ./implementation/td/generate/JavadocTlDocumentationGenerator.php "./implementation/td/generate/scheme/td_api.tl" "./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java"

echo "Patching TdApi.java..."
${PYTHON_EXECUTABLE} ../scripts/core/tdlib-serializer "$(realpath -m  ./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java)" "$(realpath -m ./src/main/java/${JAVA_API_PACKAGE_PATH}/new_TdApi.java)" "$(realpath -m ../scripts/core/tdlib-serializer/headers.txt)"
rm ./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java
if [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
	unexpand --tabs=2 ./src/main/java/${JAVA_API_PACKAGE_PATH}/new_TdApi.java > ./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java
else
	unexpand -t 2 ./src/main/java/${JAVA_API_PACKAGE_PATH}/new_TdApi.java > ./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java
fi
rm ./src/main/java/${JAVA_API_PACKAGE_PATH}/new_TdApi.java

echo "Generated '$(realpath -m ./src/main/java/${JAVA_API_PACKAGE_PATH}/TdApi.java)'"

echo "Done."
exit 0
