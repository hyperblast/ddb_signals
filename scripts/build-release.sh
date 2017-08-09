#!/bin/bash

set -e

if [ -n "$VERBOSE" ]; then
    set -v
fi

cd "$(dirname $0)/.."

function build {
    CFLAGS="-O2 -Werror $CFLAGS_EXTRA" make clean pkg
    mkdir -p build/release
    cp build/pkg/*.tar.gz build/release
}

CFLAGS_EXTRA= build
CFLAGS_EXTRA=-m32 build
