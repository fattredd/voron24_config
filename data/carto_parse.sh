#!/usr/bin/env bash

set -e

mv /tmp/data* ~/cartographer-klipper/

pushd ~/cartographer-klipper &> /dev/null
  ~/klippy-env/bin/python tempcalib.py
