#!/bin/bash -ex
if [ ! -f /opt/sccache/sccache ]; then
  apt-get --assume-yes update
  apt-get --assume-yes install wget
  wget https://github.com/mozilla/sccache/releases/download/v0.5.4/sccache-v0.5.4-x86_64-unknown-linux-musl.tar.gz
  tar xzf sccache-v0.5.4-x86_64-unknown-linux-musl.tar.gz
  rm sccache-v0.5.4-x86_64-unknown-linux-musl.tar.gz
  mkdir -p /opt/sccache/
  mv sccache-v0.5.4-x86_64-unknown-linux-musl/sccache /opt/sccache/sccache
  rm -r sccache-v0.5.4-x86_64-unknown-linux-musl
  chmod +x /opt/sccache/sccache
fi
