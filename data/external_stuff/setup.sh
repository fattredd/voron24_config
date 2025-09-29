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

{
  # Fix USB suspend issues
  echo Y | sudo tee /sys/module/usbcore/parameters/old_scheme_first
  echo -1 | sudo tee /sys/module/usbcore/parameters/autosuspend
}

# This will not currently work due to the way we Z-home. To make it work,
# we'll need to place Z endstops on the gantry itself and home to max Z
# {
#   # power loss recovery
#   # https://github.com/ankurv2k6/klipper-plr
#   chmod 644 ${cur_dir}/power_loss_recovery.py
#   ln -sf ${cur_dir}/power_loss_recovery.py ~/klipper/klippy/extras/power_loss_recovery.py
# }


{ # Canbus bridge setup
  #https://canbus.esoterical.online/can_adapter/BigTreeTech%20U2C%20v2.1/README.htmlq
  cd ~/
  wget https://github.com/Esoterical/voron_canbus/raw/main/can_adapter/BigTreeTech%20U2C%20v2.1/G0B1_U2C_V2.bin

  # Put the canbus adapter into DFU mode
  # Hold the BOOT button while plugging it in
  sudo dfu-util -l | grep 'Internal Flash' || ( echo "Please put the canbus adapter into DFU mode by shorting the two pins on the back while plugging it in" && exit 1 )
  # Flash the firmware
  sudo dfu-util -D ~/G0B1_U2C_V2.bin -a 0 -s 0x08000000:leave

  # Replug the canbus adapter and check it's there
  #
}

{
  # Canbus setup
  #sudo ln -sf ${cur_dir}/can0 /etc/network/interfaces.d/can0
  # ~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
  sudo systemctl enable systemd-networkd
  sudo systemctl start systemd-networkd
  sudo systemctl disable systemd-networkd-wait-online.service
  echo -e 'SUBSYSTEM=="net", ACTION=="change|add", KERNEL=="can*"  ATTR{tx_queue_len}="128"' | sudo tee /etc/udev/rules.d/10-can.rules > /dev/null
  # cat /etc/udev/rules.d/10-can.rules
  sudo udevadm control --reload-rules && sudo udevadm trigger
  echo -e "[Match]\nName=can*\n\n[CAN]\nBitRate=1M\n#RestartSec=0.1s\n\n[Link]\nRequiredForOnline=no" | sudo tee /etc/systemd/network/25-can.network > /dev/null
  # cat /etc/systemd/network/25-can.network
  sudo systemctl restart systemd-networkd
  sleep 2
  ip link show can0
  sudo ip link set can0 up
  sleep 2
  ip -details link show can0
  ~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
}
