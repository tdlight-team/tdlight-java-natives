#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture i386
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-14-dev:*" "libc++abi-14-dev:*" "libc++1-14:*" "libc++abi1-14:*" "libunwind-14-dev:*" "libunwind-14:*" || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-14-dev:i386 libc++abi-14-dev:i386 libc++1-14:i386 libc++abi1-14:i386 libunwind-14-dev:i386 libunwind-14:i386
# shellcheck disable=SC2016
find /usr/lib/ -path "*-linux-*" -lname "*llvm*" -print0 | xargs -0 -I{} sh -c 'cp --remove-destination $(realpath "{}") "{}"'
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install clang-14 libc++-14-dev libc++abi-14-dev libc++1-14 libc++abi1-14 libunwind-14-dev libunwind-14
# End libc++ packages bugfix

# Add i386 common files
apt-get download libclang-common-14-dev:i386
dpkg-deb -xv libclang-common-14-dev_*_i386.deb /


# Install dependencies
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libssl-dev:i386 zlib1g-dev:i386 openjdk-17-jdk-headless:i386 libgcc-12-dev:i386 libc6-dev:i386
