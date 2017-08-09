#!/bin/bash

set -e

if [ "$VERBOSE" != "" ]; then
    set -v
fi

cd "$(dirname $0)/.."

function clean {
    rm -rf deps
}

if [ "$1" == "--clean" ]; then
    clean
    exit 0
fi

clean

mkdir -p deps
cd deps

mkdir -p deadbeef
cd deadbeef

wget -nv -O deadbeef.h https://raw.githubusercontent.com/Alexey-Yakovenko/deadbeef/d3338642d00d29424d7fe4c55ab623f95fb590a6/deadbeef.h
echo 'a48537de33c87f83967c84f517e86950d3ecb2a6388b154a66e26f69b10fa56b  deadbeef.h' | sha256sum -c

cd ..
touch .stamp
