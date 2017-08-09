#!/bin/bash

set -e

if [ "$VERBOSE" != "" ]; then
    set -v
fi

cd "$(dirname $0)/.."

root_dir=$(pwd)
build_dir=$root_dir/build
pkg_dir=$build_dir/pkg

pkg_name=ddb_signals
plugin=signals.so
version=1.0

function clean {
    rm -rf "$pkg_dir"
}

if [ "$1" == "--clean" ]; then
    clean
    exit 0
fi

test -e "$build_dir/$plugin"
file_info=$(file "$build_dir/$plugin")

if echo $file_info | grep 'Intel 80386' > /dev/null; then
    arch=x86
elif echo $file_info | grep 'x86-64' > /dev/null; then
    arch=x86_64
else
    arch=unknown
fi

clean

mkdir -p "$pkg_dir"
tar czf "$pkg_dir/$pkg_name-$version-$arch.tar.gz" -C $build_dir $plugin -C $root_dir LICENSE
touch "$pkg_dir/.stamp"
