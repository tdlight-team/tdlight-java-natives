#!/bin/bash -e
set -e
cd ./scripts/
source ./generate_maven_project.sh
source ./generate_td_tools.sh
source ./compile_td.sh
source ./compile_tdjni.sh
source ./build_generated_maven_project.sh

echo "Done."
exit 0
