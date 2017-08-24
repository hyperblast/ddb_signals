#!/bin/bash

set -ve

cd "$(dirname $0)/.."

if [ "$CC" = "gcc" ]; then
    export CC=gcc-6
    export CFLAGS="$CFLAGS -Wno-unused-result"
fi

rm -rf build/release

VERBOSE=1 RELEASE=1 WERROR=1 make pkg
