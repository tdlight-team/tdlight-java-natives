#!/bin/bash -e
set -e

if [[ "$OPERATING_SYSTEM_NAME" == "linux" ]]; then
	echo "==Linux===="
	sudo apt-get update
	sudo apt-get install -y make git zlib1g-dev libssl-dev gperf cmake \
		ccache maven python3 python3-pip php-cli \
		clang libc++-dev libc++abi-dev

elif [[ "$OPERATING_SYSTEM_NAME" == "osx" ]]; then
	echo "==OSX======"
	export PYTHON=36
	brew install swig;
	#curl -LO https://raw.githubusercontent.com/GiovanniBussi/macports-ci/master/macports-ci;
	#source ./macports-ci install;
	#yes | sudo port install python$PYTHON;
	#yes | sudo port install py$PYTHON-pip;
	#sudo port select --set python3 python$PYTHON;
	#sudo port select --set pip pip$PYTHON;
	#pip install pyinstaller --user;
	#export PATH=$PATH:$(python3 -c "import site; print(site.USER_BASE)")/bin;
	brew install gperf openssl coreutils

	## Precompile .tlo files because of a bug in travis/macOs
	#cd ./implementations/tdlight/td/generate/tl-parser/
	#echo "Configuring tl-parser"
	#./configure
	#echo "Compiling tl-parser"
	#make
	#cd ..
	#echo "Running tl-parser on mtproto_api"
	#./tl-parser/bin/tl-parser -v -e scheme/mtproto_api.tlo scheme/mtproto_api.tl
	#echo "Running tl-parser on secret_api"
	#./tl-parser/bin/tl-parser -v -e scheme/secret_api.tlo scheme/secret_api.tl
	#echo "Running tl-parser on telegram_api"
	#./tl-parser/bin/tl-parser -v -e scheme/telegram_api.tlo scheme/telegram_api.tl
	#echo "Running tl-parser on td_api"
	#./tl-parser/bin/tl-parser -v -e scheme/td_api.tlo scheme/td_api.tl
	#echo "Done .tlo"
elif [[ "$OPERATING_SYSTEM_NAME" == "windows" ]]; then
	echo "==Windows=="
	choco install ccache
	choco install make
	#choco install windows-sdk-10.1
	choco install visualstudio2019buildtools --version=16.7.0.0 --package-parameters "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
	#choco install openjdk11 --version=11.0.8.10
	choco install maven --version=3.6.3 --allow-downgrade
	choco install base64
	choco install gperf
	choco install strawberryperl
	choco install nasm
	#choco install php --version=7.4.9 --package-parameters='"/ThreadSafe ""/InstallDir:C:\PHP"""'
	#choco install python3 --params "/InstallDir:C:\Python3"

	[ -d ./windowsenv/ ] && $(yes | rm -rf ./windowsenv/)
	[ -d $VCPKG_DIR ] && $(yes | rm -rf $VCPKG_DIR)
	git clone --depth=1 https://github.com/tdlight-team/windows-amd64-prebuilt-libraries.git windowsenv
	mv windowsenv/vcpkg $VCPKG_DIR
	cd $VCPKG_DIR
	./vcpkg integrate install
else
	echo "Unrecognized os: $OPERATING_SYSTEM_NAME"
	exit 1
fi
