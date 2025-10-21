#!/usr/bin/env bash

# Flash the latest firmware to mcus
#
# KCONFIG files come from:
# https://slawi.eu/posts/klipper_make_config/

set -e

octopus_canbus_id=6d264f2caf31
octopus_serial_path="/dev/serial/by-id/usb-katapult_stm32f446xx_360018000650535556323420-if00"


sudo systemctl stop klipper

# Flash mcu rpi
pushd "~/klipper" &>/dev/null
  make clean
  make KCONFIG_CONFIG=config-raspi-process
  make flash
popd &>/dev/null

# Flash mcu octopus
pushd "~/klipper" &>/dev/null
  python3 ~/katapult/scripts/flashtool.py -i can0 -r -u "${octopus_canbus_id}" # put mcu into bootloader mode

  make clean
  make KCONFIG_CONFIG=config-octopus-canbus
  python3 ~/katapult/scripts/flashtool.py -f ~/klipper/out/klipper.bin -d "${octopus_serial_path}"
popd &>/dev/null

sudo systemctl start klipper
