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
echo "Compiling tdjni..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"
echo "CPU cores count: ${CPU_CORES}"
echo "CMake extra arguments: '${CMAKE_EXTRA_ARGUMENTS}'"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/tdjni_build/ ] && rm -r ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] && rm -r ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] && rm -r ./generated/tdjni_docs/
[ -d ./generated/src/main/jni-cpp-src/ ] && rm -r ./generated/src/main/jni-cpp-src/
[ -d ./generated/src/main/jni-java-src/ ] && rm -r ./generated/src/main/jni-java-src/

# Create missing folders
echo "Creating missing folders..."
[ -d ./generated/tdjni_build/ ] || mkdir ./generated/tdjni_build/
[ -d ./generated/tdjni_bin/ ] || mkdir ./generated/tdjni_bin/
[ -d ./generated/tdjni_docs/ ] || mkdir ./generated/tdjni_docs/

# Copy source files
echo "Copying source files..."
cp -r ./src/main/jni-cpp-src/common/. ./generated/src/main/jni-cpp-src
cp -r ./src/main/jni-cpp-src/${IMPLEMENTATION_NAME}/. ./generated/src/main/jni-cpp-src
cp -r ./src/main/jni-java-src ./generated/src/main/jni-java-src
cp ./generated/src/main/java/it/tdlight/jni/TdApi.java ./generated/src/main/jni-java-src/it/tdlight/jni/TdApi.java

# Configure cmake
echo "Configuring CMake..."
cd ./generated/tdjni_build/
cmake \
 -DCMAKE_BUILD_TYPE=Release \
 -DTD_GENERATED_BINARIES_DIR=$(realpath -m ../td_tools/td/generate/) \
 -DTD_SRC_DIR=$(realpath -m ../implementation/) \
 -DTDNATIVES_BIN_DIR=$(realpath -m ../tdjni_bin/) \
 -DTDNATIVES_DOCS_BIN_DIR=$(realpath -m ../tdjni_docs/) \
 -DTd_DIR=$(realpath -m ../td_bin/lib/cmake/Td/) \
 -DJAVA_SRC_DIR=$(realpath -m ../src/main/jni-java-src/) \
 -DTDNATIVES_CPP_SRC_DIR:PATH=$(realpath -m ../src/main/jni-cpp-src/) \
 -DOPENSSL_USE_STATIC_LIBS=True \
 ${CMAKE_EXTRA_ARGUMENTS} \
 $(realpath -m ../src/main/jni-cpp-src/)

# Build
echo "Compiling ${IMPLEMENTATION_NAME} jni..."
cmake --build . --target install --config Release ${CPU_CORES}
cd ..

# Copy to resources
echo "Copying to resources..."
[ -d  ./src/main/resources/libs/${OPERATING_SYSTEM_NAME_SHORT}/${CPU_ARCHITECTURE_NAME}/ ] || mkdir -p ./src/main/resources/libs/${OPERATING_SYSTEM_NAME_SHORT}/${CPU_ARCHITECTURE_NAME}/
if [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
	cp ./tdjni_bin/tdjni.dll ./src/main/resources/libs/${OPERATING_SYSTEM_NAME_SHORT}/${CPU_ARCHITECTURE_NAME}/tdjni.dll
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
	cp ./tdjni_bin/libtdjni.dylib ./src/main/resources/libs/${OPERATING_SYSTEM_NAME_SHORT}/${CPU_ARCHITECTURE_NAME}/tdjni.dylib
elif [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	cp ./tdjni_bin/libtdjni.so ./src/main/resources/libs/${OPERATING_SYSTEM_NAME_SHORT}/${CPU_ARCHITECTURE_NAME}/tdjni.so
fi

echo "Done."
exit 0
