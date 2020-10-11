#!/bin/bash -e
# REQUIRED PARAMETERS:
# REVISION = <revision>

# Check variables correctness
if [ -z "${REVISION}" ]; then
	echo "Missing parameter: REVISION"
	exit 1
fi

cd ../generated

mvn -B -Drevision=${REVISION} deploy

echo "Done."
exit 0
