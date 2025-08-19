#!/bin/bash

BASE_PORT=50100
MAX_TRIES=100
HOSTNAME=$(hostname)
SERVER="instance-1"

# Figure out how many instances of this script are running. We just need 1,
# this instance is part of the count.
PID=$$
PARENT_PID=$(ps -o ppid= -p $PID)
SCRIPT_NAME=$(basename "$0")
PROCESS=$(ps -ef | grep "$SCRIPT_NAME" | grep -v " $PID " | grep -v " $PARENT_PID " | grep -v "grep")
#echo "PID=$PID PARENT_PID=$PARENT_PID SCRIPT_NAME=$SCRIPT_NAME"

if $(echo "$PROCESS" | grep -q "$SCRIPT_NAME"); then
  PROCESS_NUM=$(echo '$PROCESS' | awk '{print $2}')
  echo $(date) "Already running as $PROCESS_NUM"
else
  echo $(date) "starting"
  for (( i=0; i<MAX_TRIES; i++ )); do
    PORT=$(( BASE_PORT + i ))
    echo "$(date) Attempting with port $PORT"
    ssh -R "$PORT:localhost:22" "$SERVER" -o ExitOnForwardFailure=yes "echo $PORT > $HOSTNAME.port; sleep 1000000" # sleep 600
  done
  echo $(date) "terminated"
fi
