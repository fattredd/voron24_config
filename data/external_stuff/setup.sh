#!/usr/bin/env bash

set -e

# This directory is where I store files that need to be symlinked into various
# other directories that we don't own

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# KlipperScreen
ln -sf ${cur_dir}/light-on.svg ~/KlipperScreen/styles/z-bolt/images/light-on.svg

# Klipper CPU Affinity
sudo mkdir -p /etc/systemd/system.conf.d/
sudo mkdir -p /etc/systemd/system/klipper.service.d
sudo ln -sf ${cur_dir}/cpuaffinity.conf /etc/systemd/system.conf.d/cpuaffinity.conf
sudo ln -sf ${cur_dir}/override.conf /etc/systemd/system/klipper.service.d/override.conf
