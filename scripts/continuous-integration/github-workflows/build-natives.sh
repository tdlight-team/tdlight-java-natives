#!/bin/bash -e
set -e
cd ./scripts/core/
./generate_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
