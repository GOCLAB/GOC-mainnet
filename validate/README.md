# GOC主网验证脚本说明

## 环境准备

- 本地nodeos已启动且连接到主网
- 安装bc库

## 运行说明

```shell
git clone https://github.com/GOCLAB/GOC-mainnet.git
cd ./GOC-mainnet/validate
./validate.sh
```

运行后会提示输入本地cleos路径以及本地已连接主网的nodeos的http-server-address端口，例如可分别输入

```shell
../../goc/build/programs/cleos/cleos
8888
```

正确输入即可运行验证脚本，出现下图即为验证通过

![image-20190315142334112](/Users/cc/Library/Application Support/typora-user-images/image-20190315142334112.png)

## 验证内容

脚本主要验证主网以下内容：

- 基金账户及基金已分配账户的链上余额是否与预期一致
- token总量交叉验证
- 系统账户权限验证，包括privileged账户验证
- 系统合约hash验证