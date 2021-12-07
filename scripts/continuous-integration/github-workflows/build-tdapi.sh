#!/bin/bash -e
set -e
cd ./scripts/core/
API_TYPE=legacy ./generate_tdapi_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
API_TYPE=legacy ./generate_tdapi_java_file.sh
API_TYPE=legacy ./build_generated_tdapi_maven_project.sh

API_TYPE=sealed ./generate_tdapi_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
API_TYPE=sealed ./generate_tdapi_java_file.sh
API_TYPE=sealed ./build_generated_tdapi_maven_project.sh

echo "Done."
exit 0
