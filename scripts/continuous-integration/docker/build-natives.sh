#!/bin/bash -e
source ./scripts/continuous-integration/docker/setup-platform-variables.sh

export JAVA_HOME
JAVA_HOME="$(find "/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)/"
export JAVA_INCLUDE_PATH="$JAVA_HOME/include"

cd scripts/core
source ./setup-variables.sh
./install-dependencies.sh
./generate_maven_project.sh
./generate_td_tools.sh
./configure_td.sh
./compile_td.sh
./compile_tdjni.sh
./build_generated_maven_project.sh
