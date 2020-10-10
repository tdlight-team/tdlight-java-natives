#!/bin/bash -e
set -e

source ./travis/setup_variables.sh

cd ./scripts/

git config user.email \"jenkins@mchv.eu\"
git config user.name \"Jenkins\"

./deploy_release.sh

echo "Build success"
exit 0
