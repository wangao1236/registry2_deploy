#!/bin/bash

function gen_passwd() {
  PWD=$(pwd)
  AUTH_HOME=$PWD/auth
  mkdir -p "$AUTH_HOME"
  docker run --entrypoint htpasswd registry -Bbn $1 $2 > "$AUTH_HOME/htpasswd"
}

function init() {
  PWD=$(pwd)
  RETURN=$PWD
  SCRIPTS_HOME=$PWD/scripts
  echo "import registry-config.sh"
  cd "$SCRIPTS_HOME" || exit
  . ./registry-config.sh
  cd "$RETURN" || exit
  gen_passwd $REGISTRY_USERNAME $REGISTRY_PASSWORD
}

init

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
    --name $REGISTRY_NAME \
    -v "$AUTH_HOME:/auth" \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
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
