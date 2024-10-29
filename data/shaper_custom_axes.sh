#!/usr/bin/env bash

set -e

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if ! ls /tmp/raw_data_axis*.csv &> /dev/null; then
    echo "No raw_data_axis data found"
    echo "Run:"
    echo "TEST_RESONANCES AXIS=1,1 OUTPUT=raw_data"
    echo "TEST_RESONANCES AXIS=1,-1 OUTPUT=raw_data"
    exit 1
fi

~/klipper/scripts/graph_accelerometer.py -c /tmp/raw_data_axis*.csv -o  ${cur_dir}/resonances.png
