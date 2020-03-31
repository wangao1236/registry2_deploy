#!/bin/bash

function gen_passwd() {
  PWD=$(pwd)
  AUTH_HOME=$PWD/auth
  mkdir -p "$AUTH_HOME"
  docker run --entrypoint htpasswd registry:2 -Bbn $1 $2 > "$AUTH_HOME/htpasswd"
}

function init() {
  PWD=$(pwd)
  RETURN=$PWD
  SCRIPTS_HOME=$PWD/scripts
  echo "generate tls cert & key"
  bash "$SCRIPTS_HOME/gen-cert.sh"
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
