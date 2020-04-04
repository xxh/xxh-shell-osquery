#!/bin/bash

#
# Support arguments (this recommend but not required):
#   -f <file>               Execute file on host, print the result and exit
#   -c <command>            [Not recommended to use] Execute command on host, print the result and exit
#   -C <command in base64>  Execute command on host, print the result and exit
#   -v <level>              Verbose mode: 1 - verbose, 2 - super verbose
#   -e <NAME=B64> -e ...    Environement variables (B64 is base64 encoded string)
#   -H <HOME path>          HOME path. Will be $HOME on the host.
#   -X <XDG path>           XDG_* path (https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
#

while getopts f:c:v:e:H:X: option
do
case "${option}"
in
f) EXECUTE_FILE=${OPTARG};;
c) EXECUTE_COMMAND=${OPTARG};;
v) VERBOSE=${OPTARG};;
e) ENV+=("$OPTARG");;
H) HOMEPATH=${OPTARG};;
X) XDGPATH=${OPTARG};;
esac
done

if [[ $VERBOSE != '' ]]; then
  export XXH_VERBOSE=$VERBOSE
fi

if [[ $EXECUTE_COMMAND ]]; then
  if [[ $XXH_VERBOSE == '1' ]]; then
    echo Execute command: $EXECUTE_COMMAND
  fi

  echo 'osquery entrypoint does not support command execution. Feel free to add support: https://github.com/xxh/xxh-shell-osquery'
  exit 1

  EXECUTE_COMMAND=(-c "${EXECUTE_COMMAND}")
fi

if [[ $EXECUTE_FILE ]]; then
  echo 'osquery entrypoint does not support file execution. Feel free to add support: https://github.com/xxh/xxh-shell-osquery'
  exit 1

  EXECUTE_COMMAND=""
fi

for env in "${ENV[@]}"; do
  name="$( cut -d '=' -f 1 <<< "$env" )";
  val="$( cut -d '=' -f 2- <<< "$env" )";
  val=`echo $val | base64 -d`

  if [[ $XXH_VERBOSE == '1' ]]; then
    echo Environment variable "$env": name=$name, value=$val
  fi

  export $name="$val"
done

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $CURRENT_DIR
osqueryd=./usr/local/bin/osqueryd
# Check
if [[ ! -f .check-done ]]; then
  check_result=`$osqueryd --version 2>&1`
  if [[ $check_result != *"version "* ]]; then
    echo "Something went wrong while running entrypoint on host:"
    echo $check_result
  else
    echo $check_result > .check-done
  fi
fi

export XXH_HOME=`readlink -f $CURRENT_DIR/../../../..`

if [[ $HOMEPATH != '' ]]; then
  homerealpath=`readlink -f $HOMEPATH`
  if [[ -d $homerealpath ]]; then
    export HOME=$homerealpath
  else
    echo "Home path not found: $homerealpath"
    echo "Set HOME to $XXH_HOME"
    export HOME=$XXH_HOME
  fi
else
  export HOME=$XXH_HOME
fi

if [[ $XDGPATH != '' ]]; then
  xdgrealpath=`readlink -f $XDGPATH`
  if [[ ! -d $xdgrealpath ]]; then
    echo "XDG path not found: $xdgrealpath"
    echo "Set XDG path to $XXH_HOME"
    export XDGPATH=$XXH_HOME
  fi
else
  export XDGPATH=$XXH_HOME
fi

export XDG_CONFIG_HOME=$XDGPATH/.config
export XDG_DATA_HOME=$XDGPATH/.local/share
export XDG_CACHE_HOME=$XDGPATH/.cache

for pluginrc_file in $(find $CURRENT_DIR/../../../plugins/xxh-plugin-prerun-*/build -type f -name '*pluginrc.sh' -printf '%f\t%p\n' 2>/dev/null | sort -k1 | cut -f2); do
  if [[ -f $pluginrc_file ]]; then
    if [[ $XXH_VERBOSE == '1' ]]; then
      echo Load plugin $pluginrc_file
    fi
    #cd $(dirname $pluginrc_file)
    source $pluginrc_file
  fi
done

$osqueryd -S
