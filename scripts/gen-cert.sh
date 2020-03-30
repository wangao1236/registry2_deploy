#!/bin/bash

PWD=$(pwd)

CERT_HOME=$PWD/certs

mkdir -p $CERT_HOME

cd $CERT_HOME



cat >ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "tke": {
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
  "CN": "tke",
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

cat >admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [
    "localhost",
    "127.0.0.1",
    "10.0.2.15",
    "192.168.1.67",
    "master1",
    "node1"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shenzhen",
      "L": "Guangdong",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=../ca.pem -ca-key=../ca-key.pem -config=../ca-config.json -profile=tke admin-csr.json | cfssljson -bare admin

cd ..

#----------------------- tke

echo "generate tke cert"

cd tke

cat >tke-csr.json <<EOF
{
  "CN": "tke",
  "hosts": [
    "127.0.0.1",
    "10.0.2.15",
    "192.168.1.67",
    "localhost",
    "master1",
    "node1",
    "tke-apiserver",
    "tke-controller-manager",
    "tke-console",
    "tke-project",
    "tke-auth",
    "tke-webshell",
    "tke-monitor",
    "api.tke.com",
    "dev.api.tke.com",
    "stage.api.tke.com",
    "console.tke.com",
    "dev.console.tke.com",
    "stage.console.tke.com",
    "www.tke.com",
    "dev.www.tke.com",
    "stage.www.tke.com",
    "auth.tke.com",
    "dev.auth.tke.com",
    "stage.auth.tke.com",
    "project.tke.com",
    "dev.project.tke.com",
    "stage.project.tke.com",
    "monitor.tke.com",
    "dev.monitor.tke.com",
    "stage.monitor.tke.com",
    "webshell.tke.com",
    "dev.webshell.tke.com",
    "stage.webshell.tke.com"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shenzhen",
      "L": "Guangdong",
      "O": "Tencent",
      "OU": "System"
    }
  ]
}
EOF

cfssl gencert -ca=../ca.pem -ca-key=../ca-key.pem -config=../ca-config.json -profile=tke tke-csr.json | cfssljson -bare tke

cd ..
