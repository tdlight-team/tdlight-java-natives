#!/bin/bash -e
cd ../generated

mvn -B deploy

echo "Done."
exit 0
