#!/bin/bash -ex
# Ubuntu 20.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture arm64
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
echo "# tdlight multiarch" > /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-12-dev:*" "libc++abi-12-dev:*" "libc++1-12:*" "libc++abi1-12:*" || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-12-dev:arm64 libc++abi-12-dev:arm64 libc++1-12:arm64 libc++abi1-12:arm64
cp --remove-destination \
  /usr/lib/llvm-12/lib/{libc++abi.so,libc++abi.so.1.0,libc++.so,libc++.so.1.0} \
  /usr/lib/aarch64-linux-gnu/ || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install clang-12 libc++-12-dev libc++abi-12-dev libc++1-12 libc++abi1-12
# End libc++ packages bugfix

# Add arm64 common files
apt-get download libclang-common-12-dev:arm64
dpkg-deb -xv libclang-common-12-dev_*_arm64.deb /


# Install dependencies
apt-get --assume-yes install libssl-dev:arm64 zlib1g-dev:arm64 openjdk-8-jdk-headless:arm64 libgcc-9-dev:arm64 libc6-dev:arm64 libunwind-dev:arm64
