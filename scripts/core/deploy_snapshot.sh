#!/bin/bash -e
# OTHER ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy|sealed>

if [ -z "${API_TYPE}" ]; then
	cd ../../generated
else
	cd "../../generated-${API_TYPE}"
fi

FALLBACK_API_TYPE="sealed"

mvn -B "-D${API_TYPE:-${FALLBACK_API_TYPE}}" deploy

echo "Done."
exit 0
