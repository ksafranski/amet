#!/bin/sh

while getopts ":u:p:s:" opt; do
  case $opt in
    u) D_USERNAME="$OPTARG"
    ;;
    p) D_PASSWORD="$OPTARG"
    ;;
    s) D_SHELL="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

D_SHELL=${D_SHELL:-bash}

if [ -z "$D_USERNAME" ]; then echo "-u (username) is required" && exit 1; fi
if [ -z "$D_PASSWORD" ]; then echo "-p (password) is required" && exit 1; fi

# BUILD
docker build . -t dev --build-arg username=$D_USERNAME --build-arg password=$D_PASSWORD --build-arg shell=$SHELL

# RUN
docker run --privileged -it --rm \
  -v $PWD/dev-home:/home/$D_USERNAME \
  --hostname=$D_USERNAME-dev \
  --name=$D_USERNAME-dev \
  -p 8000-8100:8000-8100 \
  -p 3000:3000 \
  dev
