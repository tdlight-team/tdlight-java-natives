#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture armhf
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
sed 's/deb mirror/deb \[arch=amd64,i386\] mirror/' -i /etc/apt/sources.list
[ -d "/etc/apt/sources.list.d" ] && find /etc/apt/sources.list.d -name "*.list" -type f -exec sed 's/deb http/deb \[arch=amd64,i386\] http/' -i {} \;
echo "# tdlight multiarch" > /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list

aptitude -y update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-14-dev:*" "libc++abi-14-dev:*" "libc++1-14:*" "libc++abi1-14:*" "libunwind-14-dev:*" "libunwind-14:*" "libc6-dev" "gcc" "gcc-12" "libgcc-12-dev" "libgfortran-12-dev" "libasan8" "libtsan2" "g++-12" "gfortran-12" "libgfortran-12-dev" "libstdc++-12-dev" || true
aptitude -y -o Dpkg::Options::="--force-overwrite" install libc++-14-dev:armhf libc++abi-14-dev:armhf libunwind-14-dev:armhf libunwind-14:armhf
# shellcheck disable=SC2016
find /usr/lib/ -path "*-linux-*" -lname "*llvm*" -print0 | xargs -0 -I{} sh -c 'cp --remove-destination $(realpath "{}") "{}"'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libunwind.so.1" "{}/libunwind.so" || true'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libc++.so.1" "{}/libc++.so" || true'
aptitude -y -o Dpkg::Options::="--force-overwrite" install clang-14 libc++-14-dev libc++abi-14-dev libunwind-14-dev libunwind-14 zlib1g-dev
# End libc++ packages bugfix

# Add armhf common files
apt-get download libclang-common-14-dev:armhf
dpkg-deb -xv libclang-common-14-dev_*_armhf.deb /


# Install dependencies
aptitude -y install libssl-dev:armhf zlib1g-dev:armhf openjdk-17-jdk-headless:armhf libgcc-12-dev:armhf libc6-dev:armhf
