#!/bin/bash

set -ve

cd "$(dirname $0)/.."

is_gcc=

if [ "$CC" = "gcc" ]; then
    export CC=gcc-6
    export CFLAGS="$CFLAGS -Wno-unused-result"
    is_gcc=1
fi

rm -rf build/release

VERBOSE=1 RELEASE=1 WERROR=1 make pkg

if [ -n $is_gcc ] && [ "$TRAVIS_BRANCH" = master ] && [ "$TRAVIS_PULL_REQUEST" = false ]; then
    scripts/upload.sh
fi
