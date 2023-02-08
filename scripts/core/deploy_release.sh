#!/bin/bash -e
# OTHER REQUIRED ENVIRONMENT VARIABLES:
#   REVISION = <revision>
# OTHER ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy|sealed>
#   SSL_TYPE = <ssl1|ssl3>

# Check variables correctness
if [ -z "${REVISION}" ]; then
	echo "Missing parameter: REVISION"
	exit 1
fi

source ./setup-variables.sh
FALLBACK_API_TYPE="sealed"
FALLBACK_SSL_TYPE="ssl1"
SAFE_VERSION_NAME="v4_0_${REVISION}"
REVISION_SUFFIX=""
if [ "${SSL_TYPE:-${FALLBACK_SSL_TYPE}}" != "ssl1" ]; then
  REVISION_SUFFIX="-${SSL_TYPE}${REVISION_SUFFIX}"
fi
REVISION_MVN="4.0.${REVISION}${REVISION_SUFFIX}"

if [ -z "${API_TYPE}" ]; then
	cd ../../generated
else
	cd "../../generated-${API_TYPE}"
fi

mvn -B -Drevision="${REVISION_MVN}" -DsafeVersionName="${SAFE_VERSION_NAME}" "-D${API_TYPE:-${FALLBACK_API_TYPE}}" clean deploy

echo "Done."
exit 0
