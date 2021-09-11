#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armv6 | armv7 | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>

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

source ./setup-variables.sh

cd ../../

# Print details
echo "Generating maven project..."
echo "Current directory: $(pwd)"
echo "Operating system: ${OPERATING_SYSTEM_NAME}"
echo "Architecture: ${CPU_ARCHITECTURE_NAME}"
echo "Td implementation: ${IMPLEMENTATION_NAME}"

# Delete old data
echo "Deleting old data..."
[ -d ./generated/ ] && rm -r ./generated/

# Create missing folders
echo "Creating missing folders..."
[ -d ./generated/ ] || mkdir ./generated/
[ -d ./generated/src/main ] || mkdir -p ./generated/src/main

# Generate pom.xml
echo "Generating pom.xml..."
sed -f "src/main/replacements/replace-${OPERATING_SYSTEM_NAME}-${CPU_ARCHITECTURE_NAME}-${IMPLEMENTATION_NAME}.sed" src/main/tdapi-project-src/pom.template.xml > generated/pom.xml

# Copy source files
echo "Copying source files..."
[ -d ./src/main/tdapi-java ] && cp -r ./src/main/tdapi-java ./generated/src/main/java
[ -d ./src/main/tdapi-resources ] && cp -r ./src/main/tdapi-resources ./generated/src/main/resources

echo "Done."
exit 0
