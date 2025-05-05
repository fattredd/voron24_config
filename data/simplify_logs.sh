#!/usr/bin/env bash

# Given a log file, this script will extract the relevant lines and save them to a new file.

set -e

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd "$cur_dir" > /dev/null
log_file="$1"

if [ -z "$log_file" ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

log_path="${HOME}/printer_data/logs/${log_file}"
if [ ! -f "$log_path" ]; then
    echo "Log file not found: $log_path"
    exit 1
fi

# Create a virtenv
venv_name=".venv"
if ! [ -d "${cur_dir}/${venv_name}" ]; then
  python3 -m venv "${cur_dir}/${venv_name}"
  source "${cur_dir}/${venv_name}/bin/activate"
  pip install --upgrade pip &> /dev/null
  pip install matplotlib &> /dev/null
else
  source "${cur_dir}/${venv_name}/bin/activate"
fi

# Create a new file to store the simplified logs
mkdir -p "_simple_logs"
base_newfile="_simple_logs/${log_file%.log}"


# Use klipper's log parsing tools to extract relevant info
~/klipper/scripts/graphstats.py  "$log_path" -o "${base_newfile}_loadgraph.png"
~/klipper/scripts/graphstats.py  "$log_path" -f -o "${base_newfile}_loadgraph_f.png"
~/klipper/scripts/graphstats.py  "$log_path" -s -o "${base_newfile}_loadgraph_s.png"
~/klipper/scripts/graphstats.py  "$log_path" -m EBB -o "${base_newfile}_loadgraph_EBB.png"
~/klipper/scripts/graphstats.py  "$log_path" -m rpi -o "${base_newfile}_loadgraph_rpi.png"
~/klipper/scripts/graphstats.py  "$log_path" -m scanner -o "${base_newfile}_loadgraph_scanner.png"

debug_log_file="${base_newfile}_klipper.log"
~/klipper/scripts/logextract.py "$log_path" > "$debug_log_file"


simplified_log_file="${base_newfile}_simplified.log"
echo "Creating simplified log file: $simplified_log_file"
cp "$log_path" "$simplified_log_file"

# Remove the klipper config
config_start="===== Config file ====="
config_end="======================="
sed -i '
        /^'"$config_start"'$/,/^'"$config_end"'$/ d;
        3i ======================\n=== CONFIG REMOVED ===\n======================
       ' "$simplified_log_file"

# Make a note of timeouts
sed -i '/^Timeout with/i === TIMEOUT===' "$simplified_log_file"
