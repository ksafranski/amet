#!/bin/sh
set -e

USER=$(whoami)

sudo chown -R $USER:$USER /data

# Sync existing data into user home
rsync -a /data/ /home/$USER

cat /tmp/data-sync-cron | crontab -
sudo chown -R $USER:root /etc/ssh/$USER
sudo service cron start
sudo service docker start
sudo service ssh start

exec "$@"

