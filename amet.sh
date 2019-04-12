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

# DEFAULTS
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
syncFreq=900
fsEngine=aufs
customizer=""

# HELP, I NEED SOMEBODY
showHelp() {
  echo "Usage: $(basename $0) ARGUMENTS [-- docker run arguments]"
  echo ""
  echo "  Available arguments:"
  echo ""
  echo "  -a <port>   The port that code-server should be exposed on. Defaults to $appPort."
  echo "  -b <secs>   The frequency with which to back up the home folder, or 0 to disable."
  echo "              Defaults to $syncFreq."
  echo "  -c <script> A custom script file to be run as the target user during the docker build."
  echo "              This can be used to customize the docker container by installing packages"
  echo "              or config files without needing to modify the Dockerfile."
  echo "  -f <engine> The storage engine to use for docker-in-docker. 'aufs' is the most"
  echo "              efficient but can cause issues on some linux systems. Specify 'vfs'"
  echo "              if you get errors related to aufs. Defaults to $fsEngine."
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
  echo "  Any arguments included after the argument terminator (--) will be passed directly"
  echo "  to the docker run command."
  echo ""
}

# PARSE COMMAND LINE ARGS
while getopts ':a:b:c:f:hik:o:p:s:t:u:' OPT; do
  case "$OPT" in
    a) appPort="$OPTARG" ;;
    b) syncFreq="$OPTARG" ;;
    c) customizer="$OPTARG" ;;
    f) fsEngine="$OPTARG" ;;
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
shift $(($OPTIND-1))

# SET UP CUSTOMIZER
if [ -n "$customizer" ] && [ ! -f "$customizer" ]; then
  echo "File not found: $customizer"
  exit 2
elif [ -z "$customizer" ]; then
  # No customizer; use a blank script so the Dockerfile doesn't fail
  echo "#!/bin/bash\n" > ./.amet-customizer.sh
else
  # Customizer exists, copy it locally so Docker can see it
  cp "$customizer" ./.amet-customizer.sh
fi

# SET UP SSH KEY
if [ -f $sshKeyPath ]; then
  cp "$sshKeyPath" ./.amet-key.pub
else
  touch ./.amet-key.pub
fi

# BUILD
docker build . -t amet-${username} \
  --build-arg username=$username \
  --build-arg password=$password \
  --build-arg shell=$shell \
  --build-arg timezone="$timezone" \
  --build-arg lang=${LANG:-en_US.UTF-8} \
  --build-arg syncFreq=$syncFreq \
  --build-arg fsEngine=$fsEngine

# CLEANUP
[ -f ./.amet-key.pub ] && rm -f ./.amet-key.pub
[ -f ./.amet-customizer.sh ] && rm -f ./.amet-customizer.sh

# ENV VARS
[ -n "$timezone" ] && runArgs+=" -e TZ=$timezone"

# RUN
docker run --privileged $runArgs \
  -v $PWD/home-${username}:/sync \
  --hostname=amet-${username} \
  --name=amet-${username} \
  -p ${appPort}:3000 \
  -p ${sshPort}:22 \
  $portRangeArgs \
  $@ \
  amet-${username}
