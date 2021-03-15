#!/bin/bash -e
cd ../../generated

mvn -B -q clean package

echo "Done."
exit 0
