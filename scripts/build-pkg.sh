#!/bin/bash

set -e

if [ -n "$VERBOSE" ]; then
    set -v
fi

source "$(dirname $0)/config.sh"
cd "$(dirname $0)/.."

if [ -n "$RELEASE" ]; then
    config=release
else
    config=debug
fi

root_dir=$(pwd)
build_dir=$root_dir/build/$config/plugin
pkg_dir=$root_dir/build/$config/pkg

function clean {
    rm -rf "$pkg_dir"
}

if [ "$1" == "--clean" ]; then
    clean
    exit 0
fi

test -e "$build_dir/$plugin_file"
file_info=$(file "$build_dir/$plugin_file")

if echo $file_info | grep 'Intel 80386' > /dev/null; then
    arch=x86
elif echo $file_info | grep 'x86-64' > /dev/null; then
    arch=x86_64
else
    arch=unknown
fi

git_rev=$(git rev-parse --short HEAD)

clean

mkdir -p "$pkg_dir"
tar czf "$pkg_dir/$pkg_name-$pkg_version-$git_rev-$arch.tar.gz" -C $build_dir $plugin_file -C $root_dir LICENSE
