#!/usr/bin/env bash

set -e

# This directory is where I store files that need to be symlinked into various
# other directories that we don't own

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# KlipperScreen
ln -s $(cur_dir)/light-on.svg ~/KlipperScreen/styles/z-bolt/images/light-on.svg
