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

REGISTRY_NAME="registry"
REGISTRY_ADDR="my.registry.com"
REGISTRY_IP="192.168.1.68"
REGISTRY_USERNAME="test"
REGISTRY_PASSWORD="password"

echo "REGISTRY_NAME="$REGISTRY_NAME
echo "REGISTRY_ADDR="$REGISTRY_ADDR
echo "REGISTRY_IP="$REGISTRY_IP
echo -e "REGISTRY_USERNAME=\c"
echo -n $REGISTRY_USERNAME | base64
echo -e "REGISTRY_PASSWORD=\c"
echo -n $REGISTRY_PASSWORD | base64
```
- 修改上述各个变量为私有 registry 对应的值
- 依次为设置 `容器名称`、`域名`、`IP 地址`、`登陆用户名`、`登陆密码`

## 1. http 启动 registry
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

## 2. https 启动 registry
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

## 3. 修改主机

- 为了让各个节点可以访问到私有的 registry，需要修改 `/etc/hosts`、`/etc/docker/daemon.json` 等文件
- 在 `/etc/hosts` 中追加私有 registry 的 IP 到域名的映射
```shell script
192.168.1.68 my.registry.com
```
- 在 `/etc/docker/daemon.json` 中添加 `insecure-registries` 字段，值为 **${域名}:${监听端口}**
- `/etc/docker/daemon.json` 示例如下：
```shell script
{
    "insecure-registries": ["my.registry.com:5000"],
    "registry-mirrors": [
        "https://registry.docker-cn.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com",
        "https://pee6w651.mirror.aliyuncs.com"
    ]   
}
```
- 重启 docker 服务：
```shell script
sudo systemctl daemon-reload && sudo systemctl restart docker.service
```
- 登陆验证：
```shell script
sudo docker login my.registry.com:5000 -u test -p password
```