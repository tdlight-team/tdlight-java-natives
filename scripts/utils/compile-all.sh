#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   OPERATING_SYSTEM_NAME = <windows | linux | osx>
#   CPU_ARCHITECTURE_NAME = <amd64 | aarch64 | 386 | armv6 | armv7 | ppc64le>
#   IMPLEMENTATION_NAME = <tdlib | tdlight>
#   CPU_CORES = "-- -j<cores>" or "-m" on Windows
#   CMAKE_EXTRA_ARGUMENTS = <args>
#   REVISION = <revision>

cd ../core

./generate_maven_project.sh
./generate_td_tools.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh

echo "Done."
exit 0
