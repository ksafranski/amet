#!/bin/sh

USERNAME=$1
PASSWORD=$2

# BUILD
docker build . -t dev --build-arg username=$USERNAME --build-arg password=$PASSWORD

# RUN
docker run --privileged -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD/dev-home:/home/$USERNAME \
  --hostname=$USERNAME-dev \
  --name=$USERNAME-dev \
  -p 3000:3000 \
  -p 8000-8100:8000-8100 \
  dev
