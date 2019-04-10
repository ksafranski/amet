#!/bin/bash
set -e

echo "I AM PID $$"

USER=$(whoami)
syncFreq=${DEV_SYNC_FREQ:-900}

cleanup() {
  /homesync.sh -d /home/$USER -p
}

# Sync existing data into user home
sudo chown -R $USER:$USER /sync
rsync -a /sync/ /home/$USER

# Set up SSH
sudo chown -R $USER:root /etc/ssh/$USER
sudo service ssh start

# Start Docker
sudo service docker start

# Start sync service
/homesync.sh -d /home/$USER -l $syncFreq &

# Continue this script after a SIGTERM
trap 'cleanup' TERM

# Strip the "/bin/sh -c" off of $@ and pre-eval the env vars
shift 2
CMD=$(eval echo $@)

# Run the command
echo ">>> Executing: $CMD"
${CMD} &

# Wait for the signal
wait $!

