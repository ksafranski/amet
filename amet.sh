#!/bin/bash
set -e

getTimezone() {
  if [ -n "$TZ" ]; then
    echo $TZ
  elif [ -f /etc/timezone ]; then
    echo $(cat /etc/timezone)
  else
    echo $(ls -l /etc/localtime | awk '{print $NF}' | sed 's/.*zoneinfo\///')
  fi
}

username=$(whoami)
password=password
shell=bash
runArgs="-d"
portRangeArgs=""
forceRebuild=0
appPort=3000
sshPort=3022
mountHome=1
sshKeyPath=$HOME/.ssh/id_rsa.pub
timezone=$(getTimezone)

# HELP, I NEED SOMEBODY
showHelp() {
  echo "Usage: $(basename $0) ARGUMENTS"
  echo ""
  echo "  Available arguments:"
  echo ""
  echo "  -a <port>   The port that code-server should be exposed on. Defaults to $appPort."
  echo "  -h          Display this help, exit 0"
  echo "  -i          Launch the container interactively and show logs. Otherwise, the container"
  echo "              will run in daemon mode."
  echo "  -k <path>   The path to the public key used to authenticate over SSH, so that password"
  echo "              authentication is not necessary. Defaults to $sshKeyPath"
  echo "  -o <ranges> Opens the specified port ranges to the host machine. Ex: -o 8000-8100."
  echo "              Can be specified multiple times."
  echo "  -p <passwd> The password to set for the user and the code-server instance."
  echo "              Defaults to '$password'."
  echo "  -r <port>   The port that remote ssh connections can be established on."
  echo "              Defaults to $sshPort."
  echo "  -s <shell>  The shell to set for the user. Defaults to '$shell'."
  echo "  -t <zone>   The timezone to use. Defaults to '$timezone'."
  echo "  -u <user>   The user to create in the container. Defaults to '$username'."
  echo ""
}

# PARSE COMMAND LINE ARGS
while getopts ':a:hik:o:p:s:t:u:' OPT; do
  case "$OPT" in
    a) appPort="$OPTARG" ;;
    h) showHelp; exit 0 ;;
    i) runArgs="-it" ;;
    k) sshKeyPath="$OPTARG" ;;
    o) portRangeArgs+="-p $OPTARG:$OPTARG " ;;
    p) password="$OPTARG" ;;
    s) shell="$OPTARG" ;;
    t) timezone="$OPTARG" ;;
    u) username="$OPTARG" ;;
    ?) showHelp; exit 1 ;;
  esac
done

# BUILD
docker build . -t dev \
  --build-arg username=$username \
  --build-arg password=$password \
  --build-arg shell=$shell \
  --build-arg timezone="$timezone" \
  --build-arg lang=${LANG:-en_US.UTF-8}

# ENV VARS
[ -n "$timezone" ] && runArgs+=" -e TZ=$timezone"

# RUN
docker run --privileged $runArgs \
  -v $PWD/data:/data \
  --hostname=${username}-dev \
  --name=${username}-dev \
  -p ${appPort}:3000 \
  -p ${sshPort}:22 \
  $portRangeArgs \
  dev
