#!/bin/bash -e
# This script compiles tdlight/tdlib api for your platform.
# Fill the variables with your system details.
#
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armv6 | armv7 | ppc64le>
#   OPERATING_SYSTEM_NAME_SHORT = <win | linux | osx>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
#   CMAKE_EXTRA_ARGUMENTS = <args>
#   REVISION = <revision>

cd ../core

./generate_tdapi_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./generate_tdapi_java_file.sh
./build_generated_tdapi_maven_project.sh

echo "Done."
exit 0
