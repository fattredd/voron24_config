#!/usr/bin/env bash

set -e

# This directory is where I store files that need to be symlinked into various
# other directories that we don't own

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Custom boot splash
{
  # https://docs.vorondesign.com/community/howto/samwiseg0/voron_rpi_bootscreen.html

  mkdir -p ${cur_dir}/z_backups/

  if grep -q '^disable_splash=1$' /boot/firmware/config.txt; then
    echo "Boot splash already set"
  else
    echo "Adding boot splash"
    cp /boot/firmware/config.txt ${cur_dir}/z_backups/config.txt
    sudo sed -i '/disable_splash=/d' /boot/firmware/config.txt
    echo "disable_splash=1" | sudo tee -a /boot/firmware/config.txt
  fi

  if grep -q -E 'logo.nologo consoleblank=0 loglevel=1 quiet vt.global_cursor_default=0' /boot/firmware/cmdline.txt; then
    echo "Boot splash already set"
  else
    echo "Adding boot splash"
    cp /boot/firmware/cmdline.txt ${cur_dir}/z_backups/cmdline.txt
    sudo sed -i '
                  s/logo\.nologo//g
                  s/consoleblank=.//g
                  s/loglevel=.//g
                  s/quiet//g
                  s/vt\.global_cursor_default=.//g
                  s/  */ /g
                ' /boot/firmware/cmdline.txt
    sudo sed -i 's/ *$/ logo.nologo consoleblank=0 loglevel=1 quiet vt.global_cursor_default=0/' /boot/firmware/cmdline.txt
  fi

  if [ "$(sudo systemctl is-enabled getty@tty3)" = "enabled" ]; then
    echo "Disabling getty on tty3"
    sudo systemctl disable getty@tty3
  else
    echo "getty on tty3 already disabled"
  fi

  if command fbi >/dev/null 2>&1; then
    echo "fbi already installed"
  else
    echo "Installing fbi"
    sudo apt-get install -y fbi
  fi

  if sudo systemctl is-enabled splashscreen &> /dev/null; then
    echo "Splashscreen service already enabled"
  else
    echo "Enabling splashscreen service"
    sudo ln -sf ${cur_dir}/splashscreen.service /etc/systemd/system/splashscreen.service
    sudo systemctl daemon-reload
    sudo systemctl enable splashscreen
  fi

  if [ -f /home/ash/boot-image.png ]; then
    echo "Boot image already set"
  else
    echo "Setting boot image"
    # Font is "Play"
    sudo ln -sf ${cur_dir}/boot-image.png /home/ash/boot-image.png
  fi
}

# KlipperScreen
ln -sf ${cur_dir}/light-on.svg ~/KlipperScreen/styles/z-bolt/images/light-on.svg

# Klipper CPU Affinity
sudo mkdir -p /etc/systemd/system.conf.d/
sudo mkdir -p /etc/systemd/system/klipper.service.d
sudo ln -sf ${cur_dir}/cpuaffinity.conf /etc/systemd/system.conf.d/cpuaffinity.conf
sudo ln -sf ${cur_dir}/override.conf /etc/systemd/system/klipper.service.d/override.conf

# Disable usb suspend
sudo ln -sf ${cur_dir}/disable-usb-autosuspend.conf /etc/modprobe.d/disable-usb-autosuspend.conf

# Easy access to printer data not in this repo
# mkdir -p ${cur_dir}/../_printer_data/
# function symlink_printer_data {
#     ln -sf ${HOME}/printer_data/$1 ${cur_dir}/../_printer_data/$1
# }
# symlink_printer_data backup
# symlink_printer_data gcodes
# symlink_printer_data logs
# symlink_printer_data misc
# symlink_printer_data octoeverywhere-store
# symlink_printer_data systemd

# Setup deps for cartographer scripts (these are probably mostly already installed)
{
  ~/klippy-env/bin/pip install pandas
  ~/klippy-env/bin/pip install matplotlib
  sudo apt-get install -y libopenblas-dev
  ~/klippy-env/bin/pip install -v numpy
  ~/klippy-env/bin/pip install scipy
}
