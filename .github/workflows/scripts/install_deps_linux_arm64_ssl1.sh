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
apt-get --assume-yes autoremove libc++-10-dev libc++abi-10-dev libc++1-10 libc++abi1-10 || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-10-dev:arm64 libc++abi-10-dev:arm64
rm -r \
  /usr/lib/aarch64-linux-gnu/libc++abi.so \
  /usr/lib/aarch64-linux-gnu/libc++abi.so.1.0 \
  /usr/lib/aarch64-linux-gnu/libc++.so.1.0
mv -t /usr/lib/aarch64-linux-gnu/ \
  /usr/lib/llvm-14/lib/libc++abi.so \
  /usr/lib/llvm-14/lib/libc++abi.so.1.0 \
  /usr/lib/llvm-14/lib/libc++.so.1.0
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-10-dev libc++abi-10-dev
# End libc++ packages bugfix

# Add arm64 common files
apt-get download libclang-common-10-dev:arm64
dpkg-deb -xv libclang-common-10-dev_*_arm64.deb /


# Install dependencies
apt-get --assume-yes install libssl-dev:arm64 zlib1g-dev:arm64 openjdk-8-jdk-headless:arm64 libgcc-9-dev:arm64 libc6-dev:arm64 libunwind-dev:arm64
