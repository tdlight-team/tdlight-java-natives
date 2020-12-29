#!/bin/bash -e
set -e
cd ./scripts/core/
./generate_tdapi_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./generate_tdapi_java_file.sh
./build_generated_tdapi_maven_project.sh

echo "Done."
exit 0
