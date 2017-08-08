#!/bin/bash

set -e

pkg_name=ddb_signals
plugin=signals.so
version=1.0

function clean {
    rm -f .pkg-stamp $pkg_name-*.tar.gz
}

if [ "$1" == "--clean" ]; then
    clean
    exit 0
fi

test -e $plugin

file_info=$(file $plugin)

if echo $file_info | grep 'Intel 80386' > /dev/null; then
    arch=x86
elif echo $file_info | grep 'x86-64' > /dev/null; then
    arch=x86_64
else
    arch=unknown
fi

clean
tar czf $pkg_name-$version-$arch.tar.gz $plugin LICENSE
touch .pkg-stamp
