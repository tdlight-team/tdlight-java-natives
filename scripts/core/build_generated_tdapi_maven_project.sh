#!/bin/bash -e
cd ../../generated

mvn -B clean install

echo "Done."
exit 0
