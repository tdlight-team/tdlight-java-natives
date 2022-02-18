#!/bin/bash -e
# This script compiles tdlight/tdlib api for your platform.
# Fill the variables with your system details.
#
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armhf | ppc64le>
#   OPERATING_SYSTEM_NAME_SHORT = <win | linux | osx>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
#   CMAKE_EXTRA_ARGUMENTS = <args>
#   REVISION = <revision>
# OPTIONAL ENVIRONMENT VARIABLES:
#   CROSS_BUILD_DEPS_DIR = <args>

cd ../core

source ./setup-variables.sh
./install-dependencies.sh

./generate_td_tools.sh
./configure_td.sh

API_TYPE=legacy ./generate_tdapi_maven_project.sh
API_TYPE=legacy ./generate_tdapi_java_file.sh
API_TYPE=legacy ./build_generated_tdapi_maven_project.sh

API_TYPE=sealed ./generate_tdapi_maven_project.sh
API_TYPE=sealed ./generate_tdapi_java_file.sh
API_TYPE=sealed ./build_generated_tdapi_maven_project.sh

echo "Done."
exit 0
