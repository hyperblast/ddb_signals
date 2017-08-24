#!/bin/bash

set -ve

cd "$(dirname $0)/.."

upload_artifacts=

if [ "$CC" = "gcc" ]; then
    export CC=gcc-6
    export CFLAGS="$CFLAGS -Wno-unused-result"
    upload_artifacts=1
fi

rm -rf build/release

VERBOSE=1 RELEASE=1 WERROR=1 make pkg

if [ -n "$upload_artifacts" ]; then
    scripts/upload.sh
fi
