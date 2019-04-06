#!/bin/sh
set -e

sudo service docker start
code-server /home/$DEV_USERNAME/workspace \
            -p 3000 \
            -d /home/$DEV_USERNAME/code-server \
            --password=$DEV_PASSWORD > /var/log/code-server/exec.log 2>&1 &

exec "$@"

