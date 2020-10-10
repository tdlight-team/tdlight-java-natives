#!/bin/bash -e
# REQUIRED PARAMETERS:
# OPERATING_SYSTEM_NAME = <windows | linux | osx>
# CPU_ARCHITECTURE_NAME = <amd64 | aarch64>
# IMPLEMENTATION_NAME = <tdlib | tdlight>
# CPU_CORES = <cores>

./generate_maven_project.sh
./generate_td_tools.sh
./compile_td.sh
./generate_tdapi_java_file.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
