#!/bin/bash -ex
# Ubuntu 22.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture ppc64el
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
sed 's/deb mirror/deb \[arch=amd64,i386\] mirror/' -i /etc/apt/sources.list
[ -d "/etc/apt/sources.list.d" ] && find /etc/apt/sources.list.d -name "*.list" -type f -exec sed 's/deb http/deb \[arch=amd64,i386\] http/' -i {} \;
echo "# tdlight multiarch" > /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list
echo "deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list.d/tdlight-multiarch.list

apt-get --assume-yes update

# Install and bypass a bug in the cross-platform libc++ packages
apt-get --assume-yes autoremove "libc++-14-dev:*" "libc++abi-14-dev:*" "libc++1-14:*" "libc++abi1-14:*" "libunwind-14-dev:*" "libunwind-14:*" "libc6-dev" "gcc" "gcc-12" "libgcc-12-dev" "libgfortran-12-dev" "libasan8" "libtsan2" || true
aptitude -y -o Dpkg::Options::="--force-overwrite" install libc++-14-dev:ppc64el libc++abi-14-dev:ppc64el libunwind-14-dev:ppc64el libunwind-14:ppc64el
# shellcheck disable=SC2016
find /usr/lib/ -path "*-linux-*" -lname "*llvm*" -print0 | xargs -0 -I{} sh -c 'cp --remove-destination $(realpath "{}") "{}"'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libunwind.so.1" "{}/libunwind.so" || true'
find /usr/lib/ -maxdepth 1 -path "*-linux-*" -type d -print0 | xargs -0 -I{} sh -c 'ln -s "{}/libc++.so.1" "{}/libc++.so" || true'
aptitude -y -o Dpkg::Options::="--force-overwrite" install clang-14 libc++-14-dev libc++abi-14-dev libunwind-14-dev libunwind-14
# End libc++ packages bugfix

# Add ppc64le common files
apt-get download libclang-common-14-dev:ppc64el
dpkg-deb -xv libclang-common-14-dev_*_ppc64el.deb /


# Install dependencies
aptitude -y -o Dpkg::Options::="--force-overwrite" install libssl-dev:ppc64el zlib1g-dev:ppc64el openjdk-17-jdk-headless:ppc64el libgcc-12-dev:ppc64el libc6-dev:ppc64el
