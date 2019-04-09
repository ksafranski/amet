#!/bin/sh
set -e

USER=$(whoami)

sudo chown -R $USER:$USER /data

# Sync existing data into user home
rsync -a /data/ /home/$USER

sudo chown -R $USER:root /etc/ssh/$USER
sudo service docker start
sudo service ssh start
/data-sync.sh &

exec "$@"

