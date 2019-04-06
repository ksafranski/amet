#!/bin/sh
sudo service docker start
code-server /home/$DEV_USERNAME/workspace \
            -p 3000 \
            -d /home/$DEV_USERNAME/code-server \
            --password=$DEV_PASSWORD