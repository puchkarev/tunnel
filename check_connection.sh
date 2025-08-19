#!/bin/bash

# Define the server to ping and the number of attempts
SERVER="8.8.8.8"
COUNT=4

# Define the minimum required uptime in seconds (1 hour = 3600 seconds)
REQUIRED_UPTIME=3600

# Get the current system uptime in seconds
UPTIME_SECONDS=$(cut -d. -f1 /proc/uptime)

# Check if uptime is less than the required amount
if [ "$UPTIME_SECONDS" -lt "$REQUIRED_UPTIME" ]; then
  echo "Current uptime: $(($UPTIME_SECONDS / 60)) minutes."
  exit 0
fi

# Use 'ping' with -c for count and -W for timeout
ping -c $COUNT -W 1 $SERVER &>/dev/null

# Check the exit code of the ping command
if [ $? -ne 0 ]; then
  # Ping failed, so perform a reboot
  echo "Ping to $SERVER failed. Rebooting now..."
  sudo reboot
else
  # Ping succeeded
  echo "Ping to $SERVER was successful."
fi
