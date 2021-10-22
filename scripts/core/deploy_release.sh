#!/bin/bash -e
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   REVISION = <revision>

# Check variables correctness
if [ -z "${REVISION}" ]; then
	echo "Missing parameter: REVISION"
	exit 1
fi

source ./setup-variables.sh

cd ../../generated

mvn -B -DrevisionNumber="${REVISION}" -DrevisionSuffix="" clean deploy

echo "Done."
exit 0
