#!/bin/bash -ex
export PREV="$(pwd)"
in=(${2//:/ })
tmpdir="$1/${in[1]:-"default"}/`cat /etc/os-release | md5sum --binary | awk '{ print $1 }'`"
mkdir -p "$tmpdir"
cd "$tmpdir"
apt-get download "$2"
filename="$(find . -type f -name "${in[0]}_*_${in[1]:-"amd64"}.deb" | sort | tail -n1)"
dpkg -x "$filename" "$3"
cd "$PREV"
