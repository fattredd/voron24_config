#!/usr/bin/env bash

set -e

mv ~/klipper/data1 ~/klipper/data2 ~/klipper/data3 ~/cartographer-klipper/

pushd ~/cartographer-klipper &> /dev/null
  ~/klippy-env/bin/python tempcalib.py
