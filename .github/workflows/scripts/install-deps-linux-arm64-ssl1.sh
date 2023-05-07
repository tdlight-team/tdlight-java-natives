#!/bin/bash -ex
# Ubuntu 20.04

export DEBIAN_FRONTEND=noninteractive

dpkg --add-architecture arm64
sed 's/deb http/deb \[arch=amd64,i386\] http/' -i /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs) main universe restricted multiverse" >> /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs)-updates main universe restricted multiverse" >> /etc/apt/sources.list
echo "deb [arch=arm64] http://ports.ubuntu.com/ $(lsb_release -cs)-security main universe restricted multiverse" >> /etc/apt/sources.list

apt-get --assume-yes update
apt-get --assume-yes install libssl-dev:arm64 zlib1g-dev:arm64 openjdk-8-jdk-headless:arm64

