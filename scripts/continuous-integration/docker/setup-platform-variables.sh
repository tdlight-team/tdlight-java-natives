#!/bin/bash -e
source ./scripts/continuous-integration/github-workflows/setup-variables.sh

export JAVA_HOME
JAVA_HOME="$(find "/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)/"
export JAVA_INCLUDE_PATH="$JAVA_HOME/include"

