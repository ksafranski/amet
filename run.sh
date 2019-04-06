#!/bin/sh

USERNAME=$1
PASSWORD=$2
SHELL=${3:-bash}

# BUILD
docker build . -t dev --build-arg username=$USERNAME --build-arg password=$PASSWORD --build-arg shell=$SHELL

# RUN
docker run --privileged -it --rm \
  -v $PWD/dev-home:/home/$USERNAME \
  --hostname=$USERNAME-dev \
  --name=$USERNAME-dev \
  -p 8000-8100:8000-8100 \
  -p 3000:3000 \
  dev
