#!/bin/bash -e
export JAVA_HOME
JAVA_HOME="/usr/lib/jvm/$(find "/usr/lib/jvm/" -maxdepth 1 -type d -iname "java*jdk*" | head -n 1)/"
export JAVA_INCLUDE_PATH="$JAVA_HOME/include"
source ./scripts/continuous-integration/github-workflows/setup-variables.sh
# Check variables correctness
if [ -z "${CPU_ARCH_DPKG}" ]; then
	echo "Missing parameter: CPU_ARCH_DPKG"
	exit 1
fi
source ./scripts/continuous-integration/github-workflows/install-dependencies.sh
sudo apt install -y "crossbuild-essential-${CPU_ARCH_DPKG}"
source ./scripts/continuous-integration/github-workflows/build-natives.sh
