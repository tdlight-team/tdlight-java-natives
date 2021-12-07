#!/bin/bash -e
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   REVISION = <revision>
# OTHER ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy|sealed>

# Check variables correctness
if [ -z "${REVISION}" ]; then
	echo "Missing parameter: REVISION"
	exit 1
fi

source ./setup-variables.sh
FALLBACK_API_TYPE="sealed"

cd ../../generated

mvn -B -DrevisionNumber="${REVISION}" "-D${API_TYPE:-${FALLBACK_API_TYPE}}" -DrevisionSuffix="" clean deploy

echo "Done."
exit 0
