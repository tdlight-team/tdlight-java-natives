#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture i386
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-15-dev:*" "libc++abi-15-dev:*" "libc++1-15:*" "libc++abi1-15:*" "libunwind-15-dev:*" "libunwind-15:*" || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-15-dev:i386 libc++abi-15-dev:i386 libc++1-15:i386 libc++abi1-15:i386 libunwind-15-dev:i386 libunwind-15:i386
cp --remove-destination \
  /usr/lib/llvm-15/lib/{libc++abi.so,libc++abi.so.1.0,libc++.so,libc++.so.1.0,libunwind.so.1.0} \
  /usr/lib/aarch64-linux-gnu/ || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install clang-15 libc++-15-dev libc++abi-15-dev libc++1-15 libc++abi1-15 libunwind-15-dev libunwind-15
# End libc++ packages bugfix

# Add i386 common files
apt-get download libclang-common-15-dev:i386
dpkg-deb -xv libclang-common-15-dev_*_i386.deb /


# Install dependencies
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libssl-dev:i386 zlib1g-dev:i386 openjdk-17-jdk-headless:i386 libgcc-12-dev:i386 libc6-dev:i386
