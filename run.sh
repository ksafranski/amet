#!/bin/bash
set -e

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
mountHome=0

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
  echo "  -l          Locally mount ./dev-home to the user's home folder in the container"
  echo "  -m <dir>    Mount the given directory (relative to the host user's \$HOME) to the container"
  echo "              user's \$HOME as a docker volume. Useful to bring in dotfiles and folders like"
  echo "              .ssh or .vimrc. Can be specified multiple times." 
  echo "  -o <ranges> Opens the specified port ranges to the host machine. Ex: -o 8000-8100."
  echo "              Can be specified multiple times."
  echo "  -p <passwd> The password to set for the user and the code-server instance."
  echo "              Defaults to '$password'."
  echo "  -r <port>   The port that remote ssh connections can be established on." \
  echo "              Defaults to $sshPort." \
  echo "  -s <shell>  The shell to set for the user. Defaults to '$shell'."
  echo "  -u <user>   The user to create in the container. Defaults to '$username'."
  echo ""
}

# PARSE COMMAND LINE ARGS
while getopts ':a:film:o:p:s:u:' OPT; do
  case "$OPT" in
    a) appPort="$OPTARG" ;;
    f) forceRebuild=1 ;;
    h) showHelp; exit 0 ;;
    i) runArgs="-it" ;;
    l) mountHome=1 ;;
    m) homeVolumes+=($OPTARG) ;;
    o) portRangeArgs+="-p $OPTARG:$OPTARG " ;;
    p) password="$OPTARG" ;;
    s) shell="$OPTARG" ;;
    u) username="$OPTARG" ;;
    ?) showHelp; exit 1 ;;
  esac
done

# PROCESS HOME VOLUMES INTO VOLUME ARGS
[ $mountHome -eq 1 ] && volumeArgs="-v $PWD/dev-home:/home/$username"
for dir in "${homeVolumes[@]}"; do
  volumeArgs+="-v $HOME/$dir:/home/$username/$dir "
done

# BUILD
imageQuery=$(docker images -q dev 2>/dev/null)
if [[ $imageQuery == "" ]] || [ $forceRebuild -eq 1 ]; then
  docker build . -t dev \
    --build-arg username=$username \
    --build-arg password=$password \
    --build-arg shell=$shell
fi

# RUN
docker run --privileged $runArgs \
  $volumeArgs \
  --hostname=${username}-dev \
  --name=${username}-dev \
  -p ${appPort}:3000 \
  -p ${sshPort}:22 \
  $portRangeArgs \
  dev
