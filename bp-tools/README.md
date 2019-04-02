# BP自动claimrewards脚本说明


## 环境准备

- 本地keosd钱包及可执行cleos
- 安装jq库
- BP账户自定义权限claimer私钥或active权限私钥（不推荐）


## 一、新建一对key作为claimer公钥

```shell
./cleos create key --to-console
```


## 二、配置自定义权限claimer

claimrewards动作需要BP账户授权才能进行，因此为了确保BP账户的财产安全，需要自定义一个claimer权限，并将其与claimrewards动作绑定，这样该权限就只能用来claimrewards，而无法进行转账等动作，也就是说可以通过权限分离保证BP账户的安全。

claimer权限的配置可通过脚本`setclaimer.sh`实现，具体步骤如下：

```shell
cd 
git clone https://github.com/GOCLAB/GOC-mainnet.git
cd ./GOC-mainnet/bp-tools
vim ./setclaimer.sh
# 将setclaimer.sh中的<yourbpname>和<yournewkey>分别替换成你的BP账户名及新创建的claimer公钥
# <your cleos dir>替换为可执行cleos路径，<your keosd --http-server-address>替换为本地keosd钱包服务的http-server-address
./setclaimer.sh  # 执行前请确保keosd已解锁钱包中包含BP账户的active或owner权限的私钥。若没有则需先导入
```


## 三、配置claim.sh

```shell
vim ./claim.sh
# 将claim.sh中的<yourbpname>和<yourprivatekey>分别替换成你的BP账户名及新创建的claimer公钥所对应的私钥
# <your programs dir>替换为本地build/programs路径，<your keosd --http-server-address>替换为本地keosd钱包服务的http-server-address
# <your nodeos --http-server-address>替换为本地nodeos节点的http-server-address，若无本地节点，可替换为api.goclab.io:8080
./claim.sh # 检查能否正确执行
```


## 四、配置定时执行

```shell
crontab -e
```
在文件中添加下行并保存即可

`15 * * * * ~/GOC-mainnet/bp-tools/claim.sh > ~/GOC-mainnet/bp-tools/claim.log 2>&1`

claim.sh将会在每小时的15分执行一次，执行结果将会保存在~/GOC-mainnet/bp-tools/claim.log中
