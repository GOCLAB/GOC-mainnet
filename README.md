# GOC主网相关资料

出块节点最低配置：2核8G内存，公网ip+3m以上带宽，300G以上SSD

主网Chain ID：4abcef3ea73a7cd42b2e39e247355048b684225d21d68aa303dd22712e8ca05d

GOC主网代码：https://github.com/GOCLAB/goc  【tag：mainnet-v1.0.0】

docker启动：https://github.com/GOCLAB/GOC-mainnet/tree/master/docker

支持GOC的eosjs:https://github.com/GOCLAB/eosjs    【branch：goc】

竞选GOC主网出块节点的BP技术信息位于producer-info文件下，各BP在p2p和api地址变动时需要对其信息进行相应更新

## 如何接入GOC主网

### 一、获取代码

```sh
cd ~    # 退出当前目录，进入主目录
git clone https://github.com/GOCLAB/goc.git
cd goc
git submodule update --init --recursive
git checkout mainnet-v1.0.0
sudo ./eosio_build.sh -s 'GOC'
sudo ./eosio_install.sh
```

### 二、导入BP账户

由于主网启动时将会根据[bp_accounts.txt](https://github.com/GOCLAB/GOC-mainnet/blob/master/bp_accounts.txt)候选节点账户名单为各位BPC创建GOC主网账户，因此各位节点只需在服务器中启动钱包服务并导入名单中公钥所对应的私钥即可，具体步骤如下：

```shell
~/goc/build/programs/keosd/keosd &  # 后台启动钱包服务
cd ~/goc/build/programs/cleos   # 进入cleos目录
./cleos wallet create --to-console    # 默认创建名为default的钱包，记录打印出来的钱包密码
./cleos wallet import       # 运行该命令后会提示输入私钥，即导入私钥到default钱包
```


### 三、注册出块BP

需boot节点恢复出块后才能进行

```shell
./cleos wallet create_key    # 创建一对公私钥作为producer key
./cleos -u http://api.goclab.io:8080 system regproducer <yourbpname> <your_producer_pub_key>
# yourbpname为你的BP账户名，your_producer_pub_key为上一条命令创建的公钥
```

注：若钱包15分钟未使用，会提示钱包被锁，需要用以下命令解锁钱包：
```shell
./cleos wallet unlock   # 根据提示输入上一步打印出来的钱包密码即可
```


### 四、准备配置文件

1、genesis.json

在~/goc/build/programs/nodeos文件夹下创建 *genesis.json* 文件，填入以下内容：

```json
{
  "initial_timestamp": "2019-01-01T00:00:00.000",
  "initial_key": "GOC5fpw5RaLW2QLuTjKzT4QVbkw65vSz7ctwwc6FGAqQ58dkxcMFa",
  "initial_configuration": {
    "max_block_net_usage": 1048576,
    "target_block_net_usage_pct": 1000,
    "max_transaction_net_usage": 524288,
    "base_per_transaction_net_usage": 12,
    "net_usage_leeway": 500,
    "context_free_discount_net_usage_num": 20,
    "context_free_discount_net_usage_den": 100,
    "max_block_cpu_usage": 300000,
    "target_block_cpu_usage_pct": 1000,
    "max_transaction_cpu_usage": 250000,
    "min_transaction_cpu_usage": 100,
    "max_transaction_lifetime": 3600,
    "deferred_trx_expiration_window": 600,
    "max_transaction_delay": 3888000,
    "max_inline_action_size": 4096,
    "max_inline_action_depth": 4,
    "max_authority_depth": 6
  }
}
```

genesis.json文件定义了初始链状态，所有节点必须从相同的初始状态开始

2、config.ini

将文件config里的[config.ini](https://github.com/GOCLAB/GOC-mainnet/blob/master/config/config.ini)复制到~/goc/build/programs/nodeos文件夹下


### 五、启动出块节点

准备好一切之后，便可启动出块节点，连接GOC主网：

```shell
cd ~/goc/build/programs/nodeos

./nodeos --genesis-json ./genesis.json --config-dir ~/goc/build/programs/nodeos --http-server-address 0.0.0.0:8888 --p2p-listen-endpoint 0.0.0.0:9876 --http-validate-host=false --producer-name <yourbpname> --signature-provider=<your_producer_pub_key>=KEY:<your_producer_private_key> --plugin eosio::http_plugin --plugin eosio::chain_api_plugin --plugin eosio::producer_plugin --plugin eosio::history_api_plugin
# yourbpname填入BP账户名; your_producer_pub_key、your_producer_private_key分别填入创建的producer key的公钥和私钥。
```

连接GOC主网，会先同步主网中已生产的块，等待一段时间同步完成后，每0.5s会收到出块节点产出的块，终端显示如下示例信息：
```
2018-09-29T10:47:23.478 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 9838cc2c992c2725... #40616 @ 2018-09-29T10:47:23.500 signed by gocio [trxs: 0, lib: 406028, conf: 0, latency: -21 ms]
2018-09-29T10:47:24.072 thread-0   producer_plugin.cpp:332       on_incoming_block    ] Received block 3624e2ab8697a1e1... #40617 @ 2018-09-29T10:47:24.000 signed by gocio [trxs: 0, lib: 406040, conf: 120, latency: 72 ms]
```


### 六、投票

再打开另一个命令行终端窗口，输入以下命令：

```shell
cd ~/goc/build/programs/cleos

./cleos system voteproducer prods 'yourbpname' 'yourbpname'
# yourbpname填入BP账户名

./cleos get schedule 
# 查看当前GOC主网出块节点
```
当GOC主网激活、nodeos同步到最新块，且得票数足够多BP账户出现在schedule中时，便可观察自己的节点是否正常出块



