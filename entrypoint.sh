#!/bin/bash
set -e

USER=$(whoami)

cleanup() {
  echo ">>> Backing up /home/$USER ..."
  /data-sync.sh
  echo ">>> Done."
}

# Sync existing data into user home
sudo chown -R $USER:$USER /data
rsync -a /data/ /home/$USER

# Set up SSH
sudo chown -R $USER:root /etc/ssh/$USER
sudo service ssh start

# Start Docker
sudo service docker start

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

