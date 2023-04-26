#!/bin/bash -e
set -e

if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	echo "==Linux===="
	sudo apt-get update
	sudo apt-get install -y make gperf \
		ccache python3 python3-pip php-cli \
		build-essential gcc-multilib g++-multilib

elif [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
	echo "==OSX======"
	brew update
	brew install gperf cmake openssl coreutils
	brew install openjdk
	brew install freetype gd libtiff
elif [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	echo "==Windows=="
	#choco install visualstudio2019buildtools --version=16.10.4.0 --allow-downgrade --package-parameters "--passive"
	#choco install visualstudio2019-workload-vctools
	choco install base64
	choco install gperf
	choco install strawberryperl
else
	echo "Unrecognized os: $OPERATING_SYSTEM_NAME"
	exit 1
fi

cd ./scripts/core/
./install-dependencies.sh
cd ../../
