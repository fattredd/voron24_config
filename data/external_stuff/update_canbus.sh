#!/usr/bin/env bash

set -e

# Updates CAN device firmware after a klipper update breaks things
cwd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Debugging commands

## Can bus interface
sudo ip link show can0
sudo ip -s -d link show can0
sudo ip link set can0 up

## Check can status
~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0
python3 ~/katapult/scripts/flashtool.py -q




# https://canbus.esoterical.online/toolhead_klipper_updating.html
sudo systemctl stop klipper.service || true
sudo ip link set can0 up

{
  pushd ~/klipper
  make clean
  cp $cwd/sb2209_can.config ./.config
  make
  popd
}


python3 ~/katapult/scripts/flashtool.py -i can0 -r -u 63ac923818e5

~/klippy-env/bin/python ~/klipper/scripts/canbus_query.py can0

python3 ~/katapult/scripts/flashtool.py -i can0 -f ~/klipper/out/klipper.bin -u 63ac923818e5

sudo systemctl start klipper.service || true
