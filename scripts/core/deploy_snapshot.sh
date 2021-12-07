#!/bin/bash -e
# OTHER ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy|sealed>

cd ../../generated

FALLBACK_API_TYPE="sealed"

mvn -B "-D${API_TYPE:-${FALLBACK_API_TYPE}}" deploy

echo "Done."
exit 0
