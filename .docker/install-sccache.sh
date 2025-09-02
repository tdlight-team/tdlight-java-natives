#!/bin/bash -ex
if [ ! -f /opt/sccache/sccache ]; then
  apt-get --assume-yes update
  apt-get --assume-yes install wget
  wget https://github.com/mozilla/sccache/releases/download/v0.10.0/sccache-dist-v0.10.0-x86_64-unknown-linux-musl.tar.gz
  tar xzf sccache-dist-v0.10.0-x86_64-unknown-linux-musl.tar.gz
  rm sccache-dist-v0.10.0-x86_64-unknown-linux-musl.tar.gz
  mkdir -p /opt/sccache/
  mv sccache-dist-v0.10.0-x86_64-unknown-linux-musl/sccache /opt/sccache/sccache
  rm -r sccache-dist-v0.10.0-x86_64-unknown-linux-musl
  chmod +x /opt/sccache/sccache
fi
