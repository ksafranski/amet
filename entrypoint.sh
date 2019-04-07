#!/bin/sh
set -e

sudo service docker start
sudo service ssh start

exec "$@"

