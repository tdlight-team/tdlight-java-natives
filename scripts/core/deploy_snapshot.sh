#!/bin/bash -e
cd ../../generated

mvn -B -q deploy

echo "Done."
exit 0
