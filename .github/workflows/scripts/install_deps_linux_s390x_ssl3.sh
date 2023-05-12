#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture s390x
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
echo "# tdlight multiarch" > /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-15-dev:*" "libc++abi-15-dev:*" "libc++1-15:*" "libc++abi1-15:*" "libunwind-15-dev:*" "libunwind-15:*" || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-15-dev:s390x libc++abi-15-dev:s390x libc++1-15:s390x libc++abi1-15:s390x libunwind-15-dev:s390x libunwind-15:s390x
cp --remove-destination \
  /usr/lib/llvm-15/lib/{libc++abi.so,libc++abi.so.1.0,libc++.so,libc++.so.1.0,libunwind.so.1.0} \
  /usr/lib/aarch64-linux-gnu/ || true
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install clang-15 libc++-15-dev libc++abi-15-dev libc++1-15 libc++abi1-15 libunwind-15-dev libunwind-15
# End libc++ packages bugfix

# Add s390x common files
apt-get download libclang-common-15-dev:s390x
dpkg-deb -xv libclang-common-15-dev_*_s390x.deb /


# Install dependencies
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libssl-dev:s390x zlib1g-dev:s390x openjdk-17-jdk-headless:s390x libgcc-12-dev:s390x libc6-dev:s390x
