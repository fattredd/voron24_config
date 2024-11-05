#!/usr/bin/env bash

set -e

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

moonraker_url="~/printer_data/comms/klippy.sock" #"http://127.0.0.1"

mesh_name="default"
if [ $# -gt 0 ]; then
  mesh_name="$@"
fi

if ! [ -d "${cur_dir}/mesh.venv" ]; then
  python3 -m venv "${cur_dir}/mesh.venv"
  source "${cur_dir}/mesh.venv/bin/activate"
  pip install matplotlib numpy websockets &> /dev/null
else
  source "${cur_dir}/mesh.venv/bin/activate"
fi

file="${cur_dir}/mesh_last_run.txt"
echo "Mesh data:" | tee ${file}
echo "Last run: $(date)" | tee -a ${file}
echo -e "Mesh name: ${mesh_name}" | tee -a ${file}

echo -e "\nplot output: $(date)" | tee -a ${file}
~/klipper/scripts/graph_mesh.py plot \
    -p "${mesh_name}" \
    -o "${cur_dir}/mesh_${mesh_name}.png" \
    meshz "${moonraker_url}" 2>&1 | tee -a ${file}


echo -e "\nanalyze output: $(date)" | tee -a ${file}
~/klipper/scripts/graph_mesh.py analyze "${moonraker_url}" 2>&1 | tee -a ${file}
