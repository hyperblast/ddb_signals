#!/bin/bash

set -e

if [ -n "$VERBOSE" ]; then
    set -v
fi

cd "$(dirname $0)/.."

function build {
    CFLAGS="$CFLAGS -O2 -Werror" make clean pkg
    mkdir -p build/release
    cp build/pkg/*.tar.gz build/release
}

CFLAGS= build
CFLAGS=-m32 build
