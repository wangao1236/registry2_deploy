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
CERT_HOME=$PWD/certs

echo "generate CA & cert & key"
mkdir -p "$CERT_HOME"
cd "$CERT_HOME" || exit

rm -rf *

mkdir -p server
mkdir -p client

cat >ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "registry": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

cat >ca-csr.json <<EOF
{
  "CN": "registry",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "WangAo",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca -

#----------------------- client

echo "generate client cert"

cd client || exit

cat >client-csr.json <<EOF
{
  "CN": "client",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "WangAo",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=../ca.pem -ca-key=../ca-key.pem -config=../ca-config.json -profile=registry client-csr.json | cfssljson -bare client

cd ..

#----------------------- server

echo "generate server cert"

cd server || exit

cat >server-csr.json <<EOF
{
  "CN": "server",
  "hosts": [
    "localhost",
    "127.0.0.1",
    "$REGISTRY_IP",
    "$REGISTRY_ADDR"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Beijing",
      "L": "Beijing",
      "O": "WangAo",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=../ca.pem -ca-key=../ca-key.pem -config=../ca-config.json -profile=registry server-csr.json | cfssljson -bare server

cd ..
