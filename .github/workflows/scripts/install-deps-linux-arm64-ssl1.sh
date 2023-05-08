#!/bin/bash -ex
# Ubuntu 20.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture arm64
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove libc++-10-dev libc++abi-10-dev
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-10-dev:arm64 libc++abi-10-dev:arm64
cp --remove-destination /usr/lib/llvm-10/lib/libc++.so.1.0 /usr/lib/aarch64-linux-gnu/
cp --remove-destination /usr/lib/llvm-10/lib/libc++abi.so.1.0 /usr/lib/aarch64-linux-gnu/
cp --remove-destination /usr/lib/llvm-10/lib/libc++abi.so /usr/lib/aarch64-linux-gnu/
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-10-dev libc++abi-10-dev
# End libc++ packages bugfix

# Install dependencies
apt-get --assume-yes install libssl-dev:arm64 zlib1g-dev:arm64 openjdk-8-jdk-headless:arm64 libgcc-9-dev:arm64 libc6-dev:arm64
