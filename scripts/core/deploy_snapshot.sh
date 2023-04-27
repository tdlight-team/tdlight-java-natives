#!/bin/bash -e
# OTHER ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy|sealed>
#   SSL_TYPE = <ssl1|ssl3>

if [ -z "${API_TYPE}" ]; then
	cd ../../generated
else
	cd "../../generated-${API_TYPE}"
fi

FALLBACK_API_TYPE="sealed"
FALLBACK_SSL_TYPE="ssl1"
SAFE_VERSION_NAME="v4_0_0"
REVISION_SUFFIX="-SNAPSHOT"
USE_SSL3="False"
if [ "${SSL_TYPE:-${FALLBACK_SSL_TYPE}}" != "ssl1" ]; then
  USE_SSL3="True"
fi
REVISION_MVN="4.0.0${REVISION_SUFFIX}"

mvn -B -Drevision="${REVISION_MVN}" -Dssl3=${USE_SSL3} -DsafeVersionName="${SAFE_VERSION_NAME}" "-D${API_TYPE:-${FALLBACK_API_TYPE}}" deploy

echo "Done."
exit 0
