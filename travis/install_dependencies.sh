#!/bin/bash -e
set -e

# ====== Setup environment variables
source ./travis/setup_variables.sh

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  echo "==Linux===="
elif [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  echo "==OSX======"
elif [[ "$TRAVIS_OS_NAME" == "windows" ]]; then
  echo "==Windows=="
  choco install ccache
  choco install visualstudio2019buildtools --version=16.7.0.0 --package-parameters "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
  choco install openjdk11 --version=11.0.8.10
  choco install maven --version=3.6.3
  choco install base64
  choco install gperf
  choco install strawberryperl
  choco install nasm
  choco install php --version=7.4.9 --package-parameters='"/ThreadSafe ""/InstallDir:C:\PHP"""'
  choco install python3 --params "/InstallDir:C:\Python3"

  git clone --depth=1 https://github.com/tdlight-team/windows-amd64-prebuilt-libraries.git windowsenv
  mv windowsenv/vcpkg $VCPKG_DIR
else
  echo "Unrecognized os: $TRAVIS_OS_NAME"
  exit 1
fi
 
