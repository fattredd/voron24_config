#!/usr/bin/env bash

set -e

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

use_existing=0
if [ $# -ne 1 ]; then
  use_existing=1
  if ! ls /tmp/calibration_data_*.csv &> /dev/null; then
      echo "No calibration data found"
      echo "Run: SHAPER_CALIBRATE"
      exit 1
  fi
fi

file="${cur_dir}/shaper_last_run.txt"
echo "Calibration data:" | tee ${file}
echo "Last run: $(date)" | tee -a ${file}
echo -e "\nFiles:" | tee -a ${file}
if [ $use_existing -eq 0 ]; then
  echo "Using existing calibration data" | tee -a ${file}
else
  ls /tmp/calibration_data_*.csv >> ${file}
  cat /tmp/calibration_data_x_*.csv > ${cur_dir}/shaper_calibration_data_x.csv
  cat /tmp/calibration_data_y_*.csv > ${cur_dir}/shaper_calibration_data_y.csv
fi

# --max_smoothing=0.2
echo -e "\nX axis:" | tee -a ${file}
~/klipper/scripts/calibrate_shaper.py ${cur_dir}/shaper_calibration_data_x.csv -o ${cur_dir}/shaper_calibrate_x.png | tee -a ${file}

echo -e "\nY axis:" | tee -a ${file}
~/klipper/scripts/calibrate_shaper.py ${cur_dir}/shaper_calibration_data_y.csv -o ${cur_dir}/shaper_calibrate_y.png | tee -a ${file}


if [ $use_existing -eq 0 ]; then
  rm /tmp/calibration_data_*.csv
fi
