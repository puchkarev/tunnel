#!/bin/bash

BASE_PORT=50100
MAX_TRIES=100
HOSTNAME=$(hostname)
SERVER="instance-1"
SCRIPT_NAME=$(basename "$0")
PID=$$

# --- Restart Logic ---
# If the first argument is "restart", kill any existing script and ssh tunnel processes.
if [ "$1" == "restart" ]; then
    echo "$(date) 'restart' command received. Killing old processes..."

    # Find and kill other running instances of this script (excluding the current one).
    SCRIPT_PIDS=$(ps -ef | grep "$SCRIPT_NAME" | grep -v grep | grep -v "$PID" | awk '{print $2}')
    if [ -n "$SCRIPT_PIDS" ]; then
        echo "$(date) Killing old script instances with PIDs: $SCRIPT_PIDS"
        kill $SCRIPT_PIDS
    fi

    # Give processes a moment to terminate before starting new ones.
    sleep 1
    echo "$(date) Old processes cleared. Starting new instance."
fi

SSH_PROCESS=$(ps -ef | grep ssh | grep "$SERVER" | grep -v grep | awk '{print $2}')
if [ -n "$SSH_PROCESS" ]; then
    echo $(date) "SSH process for $SERVER exists with PID: $SSH_PROCESS"
    exit 0
fi

echo $(date) "starting"
for (( i=0; i<MAX_TRIES; i++ )); do
  PORT=$(( BASE_PORT + i ))
  echo "$(date) Attempting with port $PORT"
  ssh -R "$PORT:localhost:22" "$SERVER" -o ExitOnForwardFailure=yes "echo $PORT > /home/pi/$HOSTNAME.port; sleep 1000000" # sleep 600
done
echo $(date) "terminated"
