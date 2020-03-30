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
CERT_HOME=$PWD/certs

mkdir -p "$BLOB_HOME"

function stop() {
    docker ps -a | grep "$REGISTRY_NAME" | awk '{print $1}' | xargs docker rm -f
}

function start() {
  docker run -d -v "$CONFIG_HOME/config.yml":/etc/docker/registry/config.yml \
    -v "$BLOB_HOME":/blobs \
    -v "$CERT_HOME":/certs \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server/server.pem \
    -e REGISTRY_HTTP_TLS_KEY=/certs/server/server-key.pem \
    --net="host" \
    --restart=always \
    --name $REGISTRY_NAME \
    registry:2
}


case $1 in
"stop")
  stop
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
