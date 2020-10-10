#!/bin/bash -e
set -e
if [ "$TRAVIS_CPU_ARCH" = "arm64" ]; then
  while true; do free -h ; sleep 2; done &
fi

source ./travis/setup_variables.sh

SCRIPTS_DIR=$(realpath ./scripts/)

cd ${SCRIPTS_DIR}
./generate_maven_project.sh
cd ${SCRIPTS_DIR}
./generate_td_tools.sh
cd ${SCRIPTS_DIR}
./compile_td.sh
cd ${SCRIPTS_DIR}
./generate_tdapi_java_file.sh
cd ${SCRIPTS_DIR}
./compile_tdjni.sh
cd ${SCRIPTS_DIR}
./build_generated_maven_project.sh

echo "Done."
exit 0
