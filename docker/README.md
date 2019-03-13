# 使用docker启动 goc

## 环境准备

- 安装 docker
- 安装 docker-compose

## 文件准备

```
.
├── config
│   ├── config.ini
│   └── genesis.json
├── docker-compose.yaml
└── init.yaml
```

- config.ini 是节点配置文件，主要需要修改p2p节点地址和公私钥
- genesis.json 是初始文件
- docker-compose.yaml 是正常启动的配置文件
- init.yaml 是初次启动的配置文件
  
### yaml 文件说明

```
version: "3"

services:
  goc:
    image: goclab/goc:latest
    command: nodeos --data-dir /opt/goc/data --config-dir /opt/goc/config
    hostname: goc
    ports:
      - 8888:8888
      - 9876:9876
    volumes:
      - /data/goc/testnet/data:/opt/goc/data
      - /data/goc/testnet/config:/opt/goc/config
```

配置中 /data/goc/testnet 需要改成实际机器存放goc数据的路径，两个yaml文件都需要修改

## 运行指令

在目录下运行：

- 初次启动 docker-compose -f init.yaml up -d
- 停止服务 docker-compose down
- 停止后重启 docker-compose up -d