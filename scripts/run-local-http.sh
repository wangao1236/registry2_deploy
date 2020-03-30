#!/bin/bash

function import() {
  PWD=$(pwd)
  RETURN=$PWD
  SCRIPTS_HOME=$PWD/scripts
  echo "import registry-config.sh"
  cd "$SCRIPTS_HOME" || exit
  . ./registry-config.sh
  cd "$RETURN" || exit
}

import

PWD=$(pwd)
CONFIG_HOME=$PWD/config
BLOB_HOME=$PWD/blobs

mkdir -p "$BLOB_HOME"

function stop() {
  docker ps -a | grep "registry" | awk '{print $1}' | xargs docker rm -f
}

function start() {
  docker run -d -v "$CONFIG_HOME/config.yml":/etc/docker/registry/config.yml \
    -v "$BLOB_HOME":/blobs \
    --net="host" \
    --restart=always \
    --name registry \
    registry:2
}

case $1 in
"stop")
  stop
  ;;
"start")
  start
  ;;
"restart")
  stop
  start
  ;;
*)
  stop
  start
  ;;
esac
