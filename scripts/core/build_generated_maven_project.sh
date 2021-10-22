#!/bin/bash -e
cd ../../generated

[ -f ./src/main/java/it/tdlight/jni/TdApi.java ] && rm ./src/main/java/it/tdlight/jni/TdApi.java
mvn -B clean install

echo "Done."
exit 0
