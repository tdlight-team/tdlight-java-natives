#!/bin/bash -e
cd ../../generated

[ -f ./src/main/java/it/tdlight/jni/TdApi.java ] && rm ./src/main/java/it/tdlight/jni/TdApi.java
mvn clean package

echo "Done."
exit 0
