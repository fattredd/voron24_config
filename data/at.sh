#!/usr/bin/env bash

# Schedule the print queue to start at a given time

set -e
set -o pipefail

if [ -z "$1" ]; then
  start_time="6:30"
else
  start_time="$1"
fi

MOONRAKER_URL="http://localhost:7125"
STATUS_ENDPOINT="/printer/objects/query?print_stats"
QUEUE_ENDPOINT="/server/job_queue/start"

check_status() {
    RESPONSE=$(curl -s -X GET "${MOONRAKER_URL}${STATUS_ENDPOINT}")

    # Check if the 'state' field in 'print_stats' is 'printing' or 'paused'
    # If it's anything else (like 'standby', 'complete', 'error'), we consider the bed 'clear'
    PRINT_STATE=$(echo "$RESPONSE" | jq -r '.result.status.print_stats.state')

    if [[ "$PRINT_STATE" == "printing" ]] || [[ "$PRINT_STATE" == "paused" ]]; then
        echo "CURRENTLY PRINTING: Print state is '$PRINT_STATE'. Aborting script."
        return 1 # Bed not clear
    else
        echo "BED IS CLEAR: Print state is '$PRINT_STATE'. Proceeding to check queue."
        return 0 # Bed is clear
    fi
}

echo "Creating a job to start the queue at ${start_time}"

# Start the queue
echo curl -X POST
     ${MOONRAKER_URL}${QUEUE_ENDPOINT} \
     | at "${start_time}"
