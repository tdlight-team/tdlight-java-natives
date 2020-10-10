#!/bin/bash -e
set -e
if [ "$TRAVIS_CPU_ARCH" = "arm64" ]; then
  while true; do free -h ; sleep 2; done &
fi

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
