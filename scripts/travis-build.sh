#!/bin/bash

set -ve

cd "$(dirname $0)/.."

if [ "$CC" = "gcc" ]; then
    export CC=gcc-6
    export CFLAGS="$CFLAGS -Wno-unused-result"
fi

VERBOSE=1 CFLAGS="$CFLAGS -O2 -Werror" make pkg
