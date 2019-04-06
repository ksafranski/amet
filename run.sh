#!/bin/bash

USERNAME=user
PASSWORD=password
SHELL=bash
RUN_ARGS="-d"
MOUNT_LOCAL=0
FORCE_REBUILD=0

# HELP, I NEED SOMEBODY
showHelp() {
  echo "Usage: $(basename $0) [-u username] [-p password] [-s shell] [-i] [-m] [-f]"
  echo ""
  echo "  Use -u, -p, and -s to set up your environment. In addition:"
  echo ""
  echo "  -i  Launch the container interactively and open the shell prompt."
  echo "      Otherwise, the container will run in daemon mode."
  echo "  -m  Mount the .ssh and .aws directories from the host as volumes in"
  echo "      the container. Note that modifying the contents of these inside"
  echo "      the container will persist back to the host."
  echo "  -f  Force a rebuild of the docker image, even if the tag already exists."
  echo ""
}

# PARSE COMMAND LINE ARGS
while getopts ':fhimp:s:u:' OPT; do
  case "$OPT" in
    h)
      showHelp
      exit 0
      ;;
    u)
      USERNAME="$OPTARG"
      ;;
    p)
      PASSWORD="$OPTARG"
      ;;
    s)
      SHELL="$OPTARG"
      ;;
    i)
      RUN_ARGS="-it"
      ;;
    m)
      MOUNT_LOCAL=1
      ;;
    f)
      FORCE_REBUILD=1
      ;;
    ?)
      showHelp
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# MOUNT LOCAL CONFIG FOLDERS
if [ $MOUNT_LOCAL -eq 1 ]; then
  [ -d "$HOME/.ssh" ] && RUN_ARGS="$RUN_ARGS -v $HOME/.ssh:/home/$USERNAME/.ssh"
  [ -d "$HOME/.aws" ] && RUN_ARGS="$RUN_ARGS -v $HOME/.aws:/home/$USERNAME/.aws"
fi

# BUILD
IMG_QUERY=$(docker images -q dev 2>/dev/null)
if [[ $IMG_QUERY == "" ]] || [ $FORCE_REBUILD -eq 1 ]; then
  docker build . -t dev --build-arg username=$USERNAME --build-arg password=$PASSWORD --build-arg shell=$SHELL
fi

# RUN
docker run --privileged $RUN_ARGS \
  -v $PWD/dev-home:/home/$USERNAME \
  --hostname=$USERNAME-dev \
  --name=$USERNAME-dev \
  -p 8000-8100:8000-8100 \
  -p 3000:3000 \
  dev /bin/$SHELL
