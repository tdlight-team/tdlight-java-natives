#!/bin/bash -ex
REVISION="${REVISION:-1.0.0.0-SNAPSHOT}"

#export CC="ccache /usr/bin/clang"
#export CXX="ccache /usr/bin/clang++"

# Create missing dirs
rm -rf implementations/tdlight/build api/target-legacy api/target api/.ci-friendly-pom.xml implementations/tdlight/td/generate/auto
mkdir -p implementations/tdlight/build/java/it/tdlight/jni api/src/main/java-legacy/it/tdlight/jni api/src/main/java-sealed/it/tdlight/jni

# Build tdlib tools
cd implementations/tdlight/build
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE="" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O0 -DNDEBUG" \
  -DTD_ENABLE_LTO=OFF \
  -DTD_ENABLE_JNI=ON \
  ..
cmake --build . --target prepare_cross_compiling --config Release --parallel "$(nproc)"
cmake --build . --target td_generate_java_api --config Release --parallel "$(nproc)"
cd ../../../

# Generate TdApi.java
TEMP_TDAPI_FILE_PATH="./implementations/tdlight/build/java/it/tdlight/jni/TdApi.java"
./implementations/tdlight/build/td/generate/td_generate_java_api TdApi "./implementations/tdlight/td/generate/auto/tlo/td_api.tlo" "./implementations/tdlight/build/java" "it/tdlight/jni"
php ./implementations/tdlight/td/generate/JavadocTlDocumentationGenerator.php "./implementations/tdlight/td/generate/scheme/td_api.tl" "$TEMP_TDAPI_FILE_PATH"
java ./tdlib-serializer/transform.java --source "$TEMP_TDAPI_FILE_PATH" --output "./api/src/main/java-legacy/it/tdlight/jni/TdApi.java" --java17 false --overwrite true --headers ./tdlib-serializer/headers.txt
java ./tdlib-serializer/transform.java --source "$TEMP_TDAPI_FILE_PATH" --output "./api/src/main/java-sealed/it/tdlight/jni/TdApi.java" --java17 true --overwrite true --headers ./tdlib-serializer/headers.txt

# Generate java package
echo "Building legacy package"
mvn -f api/pom.xml package -Dlegacy=true -Drevision="$REVISION"
echo "Building standard package"
mvn -f api/pom.xml package -Drevision="$REVISION"
