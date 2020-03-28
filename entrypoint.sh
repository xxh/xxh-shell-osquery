#!/bin/bash

while getopts f:c:v:e: option
do
case "${option}"
in
f) EXECUTE_FILE=${OPTARG};;
c) EXECUTE_COMMAND=${OPTARG};;
v) VERBOSE=${OPTARG};;
e) ENV+=("$OPTARG");;
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
export XDG_CONFIG_HOME=$XXH_HOME/.config
$osqueryd -S
