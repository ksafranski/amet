#!/bin/bash
set -e
set -x

USER=$(whoami)
GROUP=$(id -gn)
syncFreq=${DEV_SYNC_FREQ:-900}

cleanup() {
  /homesync.sh -d /home/$USER -p
}

# ON FIRST RUN ONLY
if [ "$$" -eq 1 ]; then
  # Check if we're doing an active sync
  if [ -d "/sync" ]; then  
    # Sync existing data into user home if this is the first run
    sudo chown -R $USER:$GROUP /sync
    rsync -a /sync/ /home/$USER

    # Start sync service
    /homesync.sh -d /home/$USER -l $syncFreq &

    # Continue this script after a SIGTERM
    trap 'cleanup' TERM
  fi

  # Start Docker
  sudo service docker start

  # Set up SSH
  sudo chown -R $USER:root /etc/ssh/$USER
  sudo service ssh start
fi

# pre-eval the env vars
CMD=$(eval echo $@)

# Run the command
echo ">>> Executing: $CMD"
${CMD} &

# Wait for the signal
wait $!

