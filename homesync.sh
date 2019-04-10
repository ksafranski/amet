#!/bin/bash

# CONSTANTS
LOCKFILE=/tmp/homesync.lock

# DEFAULTS
loopSecs=0
pauseForParent=0
forceQuit=0
syncDir=""

# PROFESSIONAL HELP
showHelp() {
  echo "Usage: $0 -d sync_directory [options]"
  echo ""
  echo "  Available options:"
  echo ""
  echo "  -d <dir>   The directory to be synced"
  echo "  -h         Show this help"
  echo "  -l <secs>  Loop the sync this many seconds. 0 to disable. Default $loopSecs."
  echo "  -p         Pause exiting until previous PID exits"
  echo ""
  echo "  This script is concurrency-safe and will exit without taking action"
  echo "  if another instance is already running. Use the -p flag to prevent"
  echo "  the script from exiting until the previous process has exited."
  echo ""
}

# PARSE CLI OPTIONS
while getopts ':d:hl:p' OPT; do
  case "$OPT" in
    d) syncDir="$OPTARG" ;;
    h) showHelp; exit 0 ;;
    l) loopSecs="$OPTARG" ;;
    p) pauseForParent=1 ;;
    ?) showHelp; exit 1 ;;
  esac
done

# VERIFY THAT WE HAVE A SYNC DIR
if [ -z "$syncDir" ] || [ ! -d "$syncDir" ]; then
  echo "Cannot find sync dir: $syncDir"
  exit 2
fi

# MAKE SURE THE SYNC DIR ENDS IN A SLASH
strPos=$((${#syncDir}-1))
lastChar=${syncDir:$strPos:1}
[[ $lastChar != "/" ]] && syncDir+="/"

# CHECK FOR A PREVIOUSLY-STARTED PROCESS
if [ -f "/tmp/homesync.lock" ]; then
  pid=$(cat $LOCKFILE)
  if ! kill -0 $pid > /dev/null 2>&1; then
    if [ $pauseForParent -eq 0 ]; then
      echo ">>> [homesync:$$] Already running in PID $pid; exiting"
    else
      echo ">>> [homesync:$$] Already running in PID $pid; waiting..."
      wait $pid
    fi
    exit 0
  fi
fi

# WRITE CURRENT PID TO LOCKFILE
echo $$ > $LOCKFILE

# THIS IS HOW WE SYNC
running=0
runSync() {
  [ $running -eq 1 ] && return 0
  running=1
  echo ">>> [homesync:$$] Syncing $syncDir..."
  rsync -a "$syncDir" /sync

  if [ "$?" -ne 0 ]; then
    echo ">>> [homesync:$$] Failed to sync $syncDir"
    exit 3
  fi

  echo ">>> [homesync:$$] Done"
  running=0
}

# TERMINATE CLEANLY
trap 'loopSecs=0; forceQuit=1; runSync' term

# SYNC IT LIKE YOU MEAN IT
while true; do
  runSync
  [ $loopSecs -eq 0 ] && break
  sleep $loopSecs
  [ $forceQuit -eq 1 ] && exit 0
done

