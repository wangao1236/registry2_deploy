# registry2_deploy

- 简单介绍 docker registry 部署的相关知识
- 参考文献：https://github.com/docker/distribution/blob/master/docs/configuration.md

## 0. 配置文件

- 查看配置文件：
```shell script
cd registry2_deploy
cat scripts/registry-config.sh
```
- 配置文件内容如下：
```shell script
#!/bin/bash

REGISTRY_NAME="regsitry"
REGISTRY_ADDR="my.domain.com"
REGISTRY_IP="192.168.1.68"

echo "REGISTRY_NAME="$REGISTRY_NAME
echo "REGISTRY_ADDR="$REGISTRY_ADDR
echo "REGISTRY_IP="$REGISTRY_IP
```
- 修改上述各个变量为私有 registry 对应的值

## 1. 生成密钥

- 执行如下指令
```shell script
cd registry2_deploy
./scripts/gen-cert.sh
```

## 2. http 启动 registry
- 以 http 方式启动：
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh start
```
- 停止服务
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh stop
```
- 重启服务
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh restart
```

## 3. https 启动 registry
- 以 https 方式启动：
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh start
```
- 停止服务
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh stop
```
- 重启服务
```shell script
cd registry2_deploy
sudo ./scripts/run-local-http.sh restart
```