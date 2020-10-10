#!/bin/bash -e
source ./travis/setup_variables.sh

cd ./scripts/

./generate_maven_project.sh
./generate_td_tools.sh
./compile_td.sh
./generate_tdapi_java_file.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
