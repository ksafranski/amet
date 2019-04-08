#!/bin/bash
set -e

getTimezone() {
  [ -n "$TZ" ] && echo $TZ
  [ -f /etc/timezone ] && echo $(cat /etc/timezone)
  echo $(ls -l /etc/localtime | awk '{print $NF}' | sed 's/.*zoneinfo\///')
}

username=$(whoami)
password=password
shell=bash
runArgs="-d"
portRangeArgs=""
volumeArgs=""
homeVolumes=()
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
  echo "  -f          Force a rebuild of the docker image, even if the tag already exists."
  echo "  -h          Display this help, exit 0"
  echo "  -i          Launch the container interactively and show logs. Otherwise, the container"
  echo "              will run in daemon mode."
  echo "  -k <path>   The path to the public key used to authenticate over SSH, so that password"
  echo "              authentication is not necessary. Defaults to $sshKeyPath"
  echo "  -m <dir>    Mount the given directory (relative to the host user's \$HOME) to the container"
  echo "              user's \$HOME as a docker volume. Useful to bring in dotfiles and folders like"
  echo "              .ssh or .vimrc. Can be specified multiple times." 
  echo "  -n          No persistence; disables mounting the home folder as a volume"
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
while getopts ':a:fikm:no:p:s:t:u:' OPT; do
  case "$OPT" in
    a) appPort="$OPTARG" ;;
    f) forceRebuild=1 ;;
    h) showHelp; exit 0 ;;
    i) runArgs="-it" ;;
    k) sshKeyPath="$OPTARG" ;;
    m) homeVolumes+=($OPTARG) ;;
    n) mountHome=0 ;;
    o) portRangeArgs+="-p $OPTARG:$OPTARG " ;;
    p) password="$OPTARG" ;;
    s) shell="$OPTARG" ;;
    t) timezone="$OPTARG" ;;
    u) username="$OPTARG" ;;
    ?) showHelp; exit 1 ;;
  esac
done

# PROCESS HOME VOLUMES INTO VOLUME ARGS
[ $mountHome -eq 1 ] && volumeArgs="-v $PWD/dev-home:/home/$username "
[ -f "$sshKeyPath" ] && volumeArgs+="-v $sshKeyPath:/etc/ssh/$username/authorized_keys "
for dir in "${homeVolumes[@]}"; do
  volumeArgs+="-v $HOME/$dir:/home/$username/$dir "
done

# BUILD
imageQuery=$(docker images -q dev 2>/dev/null)
if [[ $imageQuery == "" ]] || [ $forceRebuild -eq 1 ]; then
  docker build . -t dev \
    --build-arg username=$username \
    --build-arg password=$password \
    --build-arg shell=$shell \
    --build-arg timezone="$timezone" \
    --build-arg lang=${LANG:-en_US.UTF-8}
fi

# ENV VARS
[ -n "$timezone" ] && runArgs+=" -e TZ=$timezone"

# RUN
docker run --privileged $runArgs \
  $volumeArgs \
  --hostname=${username}-dev \
  --name=${username}-dev \
  -p ${appPort}:3000 \
  -p ${sshPort}:22 \
  $portRangeArgs \
  dev
