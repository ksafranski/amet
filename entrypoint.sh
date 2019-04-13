#!/bin/bash
set -e
set -x

USER=$(whoami)
syncFreq=${DEV_SYNC_FREQ:-900}

cleanup() {
  /homesync.sh -d /home/$USER -p
}

# ON FIRST RUN ONLY
if [ "$$" -eq 1 ]; then
  # Sync existing data into user home if this is the first run
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
fi

# pre-eval the env vars
CMD=$(eval echo $@)

# Run the command
echo ">>> Executing: $CMD"
${CMD} &

# Wait for the signal
wait $!

