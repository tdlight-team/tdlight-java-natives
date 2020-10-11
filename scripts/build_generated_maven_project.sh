#!/bin/bash -e
cd ../generated

rm ./src/main/java/it/tdlight/jni/TdApi.java
mvn clean package

echo "Done."
exit 0
