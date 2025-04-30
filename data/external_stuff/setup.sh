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

# Easy access to printer data not in this repo
mkdir -p ${cur_dir}/../_printer_data/
function symlink_printer_data {
    ln -sf ${HOME}/printer_data/$1 ${cur_dir}/../_printer_data/$1
}
symlink_printer_data backup
symlink_printer_data gcodes
symlink_printer_data logs
symlink_printer_data misc
symlink_printer_data octoeverywhere-store
symlink_printer_data systemd
