#!/bin/bash -e
# REQUIRED PARAMETERS:
# OPERATING_SYSTEM_NAME = <windows | linux | osx>
# CPU_ARCHITECTURE_NAME = <amd64 | aarch64>
# IMPLEMENTATION_NAME = <tdlib | tdlight>
# CPU_CORES = <cores>

source ./generate_maven_project.sh
source ./generate_td_tools.sh
source ./compile_td.sh
source ./compile_tdjni.sh
source ./build_generated_maven_project.sh

echo "Done."
exit 0
