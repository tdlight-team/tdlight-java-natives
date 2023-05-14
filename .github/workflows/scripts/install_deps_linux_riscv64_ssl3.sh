#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture riscv64
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
echo "# tdlight multiarch" > /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-14-dev:*" "libc++abi-14-dev:*" "libc++1-14:*" "libc++abi1-14:*" "libunwind-14-dev:*" "libunwind-14:*" || true

apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libc++-14-dev:riscv64 libc++abi-14-dev:riscv64 libc++1-14:riscv64 libc++abi1-14:riscv64 libunwind-14-dev:riscv64 libunwind-14:riscv64 libatomic1:riscv64  libgcc-s1:riscv64
# shellcheck disable=SC2016
find /usr/lib/ -path "*-linux-*" -lname "*llvm*" -print0 | xargs -0 -I{} sh -c 'cp --remove-destination $(realpath "{}") "{}"'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libunwind.so.1" "{}/libunwind.so" || true'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libc++.so.1" "{}/libc++.so" || true'
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install clang-14 libc++-14-dev libc++abi-14-dev libc++1-14 libc++abi1-14 libunwind-14-dev libunwind-14
# End libc++ packages bugfix

# Add riscv64 common files
apt-get download libclang-common-14-dev:riscv64
dpkg-deb -xv libclang-common-14-dev_*_riscv64.deb /


# Install dependencies
#
#I don't know why this command fails in github actions only with risc-v:
#Reading package lists...
#Building dependency tree...
#Reading state information...
#Some packages could not be installed. This may mean that you have
#requested an impossible situation or if you are using the unstable
#distribution that some required packages have not yet been created
#or been moved out of Incoming.
#The following information may help to resolve the situation:
#
#The following packages have unmet dependencies:
# libgcc-12-dev:riscv64 : Depends: libgomp1:riscv64 (>= 12.1.0-2ubuntu1~22.04) but it is not going to be installed
#                         Depends: libasan8:riscv64 (>= 12.1.0-2ubuntu1~22.04) but it is not going to be installed
# libselinux1:riscv64 : Depends: libpcre2-8-0:riscv64 (>= 10.22) but it is not going to be installed
#E: Unable to correct problems, you have held broken packages.
apt-get --assume-yes -o Dpkg::Options::="--force-overwrite" install libssl-dev:riscv64 zlib1g-dev:riscv64 openjdk-17-jdk-headless:riscv64 libgcc-12-dev:riscv64 libc6-dev:riscv64 libstdc++6:riscv64
