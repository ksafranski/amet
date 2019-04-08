#!/bin/sh
set -e

sudo chown -R $USER:root /etc/ssh/$USER
sudo service docker start
sudo service ssh start

exec "$@"

