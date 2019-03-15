#!/bin/bash

# get cleos path
read -p "Please input the local cleos executable path, such as ../../goc/build/programs/cleos/cleos : " cleospath
read -p "Please input the local nodeos http port, such as 8888 : " PORT
CLEOS="$cleospath -u http://127.0.0.1:$PORT"
$CLEOS get info > /dev/null
if [ $? != 0 ]
    then
        echo -e "\033[31m********** Error!! Could not get the data onchain. Please ensure the cleos path and port is correct and the local nodeos is running**********\033[0m"
        exit 1
fi

# system accounts
SYS_ACCOUNTS=( "gocio.bpay" "gocio.msig" "gocio.names" "gocio.ram" "gocio.ramfee" "gocio.saving" "gocio.stake" "gocio.token" "gocio.vpay" "gocio.gns" "gocio.gstake" "gocio.vs" )

# fund accounts
FUND_ACCOUNTS=( "goc.don" "goc.vol" "goc.exp" "goc.eco" )

# token allocated account
ALL_ACCOUNTS=( "freeaccount" "donator" "wallet" "chain" "manage" "volunteer" "contributor" "testnet" "audit" "earlypr" "browser" "resource" )


echo -e "\n"
echo "####################################################################################################"
echo "########################################     Validation     ########################################"
echo "####################################################################################################"

# check whether bc is supported
echo "1.1 + 1.2" | bc > /dev/null
if [ $? != 0 ]
    then
        echo "\033[31m**********The program 'bc' is currently not installed. Please install the package 'bc' before validation**********\033[0m"
        exit 2
fi

# check balance
bp_num=16
faccount=$((10000000 - 16*100 - $bp_num*10))
echo -e "\n\n----------------------------------     validating the balance     ----------------------------------"
declare -A act_blc
act_blc=(   [goc.don]="0"
            [goc.vol]="0"
            [goc.exp]="3437010000.0000"
            [goc.eco]="4000000000.0000"
            [donator]="1836200000.0000"
            [wallet]="80000000.0000"
            [chain]="80000000.0000"
            [manage]="3800000.0000"
            [volunteer]="5790000.0000"
            [contributor]="300000000.0000"
            [testnet]="100000000.0000"
            [audit]="6000000.0000"
            [earlypr]="31200000.0000"
            [browser]="10000000.0000"
            [freeaccount]="$faccount.0000"
            [resource]="95000000.0000"   )

pass1="true"
total_balance=0.0
for account in $(echo ${!act_blc[*]})
    do
        balance=$($CLEOS get account $account | grep liquid | awk '{print $2}')
        if [ -z "$(echo $balance)" ]
            then
                balance="0"
        fi
        total_balance=$(echo "$total_balance + $balance" | bc)
        if [ ${act_blc[$account]} != $balance ]
            then
                printf %.s* {1..100} && echo
                echo -e "\033[31m*************** Warning!!!!!!$account supposed balance: ${act_blc[$account]}, onchain balance: $balance *************** \033[0m"
                printf %.s* {1..100} && echo
                pass1="false"
            else
                echo "$account balance correct : $balance"
        fi
    done
echo "total balance of above accounts : $total_balance"

# check total token by using voters table
total_ram=$((16*10 + $bp_num*1 + 5000000))
total_staked=0
all_staked=$($CLEOS get table gocio gocio voters -l 100 | grep staked | cut -d ":" -f 2 | cut -d "," -f 1)
for stake in $all_staked
    do
        total_staked=$(echo "$total_staked + $stake" | bc)
    done
echo "total stake: $(($total_staked / 10000)), total buyram token: $total_ram"
total=$(echo "$total_staked / 10000 + $total_balance + $total_ram" | bc)
if [ $total == 10000000000.0000 ]
    then
        echo "total token validation method I correct : $total"
    else
        printf %.s* {1..100} && echo
        echo -e "\033[31m*************** Warning!!!!!!Supposed total balance: 10000000000.0000, method I onchain balance: $total *************** \033[0m"
        printf %.s* {1..100} && echo
        pass1="false"
fi

# check total token by adding system account balance
total_balance_system=0
for account in  ${SYS_ACCOUNTS[*]}
    do
        balance_system=$($CLEOS get account $account | grep liquid | awk '{print $2}')
        if [ -z $balance_system ]
            then
                balance_system="0"
        fi
        total_balance_system=$(echo "$total_balance_system + $balance_system" | bc)
    done
echo "total balance of system accounts : $total_balance_system"
total_=$(echo "$total_balance + $total_balance_system" | bc)
if [ $total_ == 10000000000.0000 ]
    then
        echo "total token validation method II correct : $total_"
    else
        printf %.s* {1..100} && echo
        echo -e "\033[31m*************** Warning!!!!!!Supposed total balance: 10000000000.0000, method II onchain balance: $total_ *************** \033[0m"
        printf %.s* {1..100} && echo
        pass1="false"
fi

# whether pass the balance validation
if [ $pass1 == "false" ]
    then
        echo -e "\033[31m*************** The balance validation did not pass, please send this result to goclab *************** \033[0m"
    else
        echo -e "\033[32m********************************** The balance validation passed *********************************** \033[0m"
fi




# check authority
echo -e "\n\n---------------------------     validating system account authority     ----------------------------"
supposed_owner="1:1gocio@active"
supposed_active="1:1gocio@active"
gocio_supposed_owner="1:1gocio.prods@active"
gocio_supposed_active="1:1gocio.prods@active"
pass2="true"

for account in ${SYS_ACCOUNTS[*]}
    do
        account_owner=$($CLEOS get account ${account} | grep " owner " | awk '{print $2 $3 $4}' )
        account_active=$($CLEOS get account ${account} | grep " active " | awk '{print $2 $3 $4}' )
        if [[ $account_owner == $supposed_owner && $account_active == $supposed_active ]]
            then
                echo "$account authority correct : [$account_owner, $account_active]"
            else
                printf %.s* {1..100} && echo
                echo -e "\033[31m*************** Warning!!!!!!$account supposed authority: [$supposed_owner, $supposed_actives], onchain : [$account_owner, $account_active] *************** \033[0m"
                printf %.s* {1..100} && echo
                pass2="false"
        fi
    done

gocio_account_owner=$($CLEOS get account gocio | grep " owner " | awk '{print $2 $3 $4}' )
gocio_account_active=$($CLEOS get account gocio | grep " active " | awk '{print $2 $3 $4}' )
if [[ $gocio_account_owner == $gocio_supposed_owner && $gocio_account_active == $gocio_supposed_active ]]
    then
        echo "gocio authority correct : [$gocio_account_owner, $gocio_account_active]"
    else
        printf %.s* {1..100} && echo
        echo -e "\033[31m Warning!!!!!!gocio supposed authority: [$gocio_supposed_owner, $gocio_supposed_active], onchain : [$gocio_account_owner, $gocio_account_active] \033[0m"
        printf %.s* {1..100} && echo
        pass2="false"
fi

# check privilege
all_accounts=( ${SYS_ACCOUNTS[*]} ${FUND_ACCOUNTS[*]} ${ALL_ACCOUNTS[*]} "gocio" )
for account in ${all_accounts[*]}
    do
        privilege=$($CLEOS get account ${account} | grep privileged)
        if [[ $account == "gocio" || $account == "gocio.msig" ]]
            then
                if [ -z "$(echo $privilege)" ]
                    then
                        printf %.s* {1..100} && echo
                        echo -e "\033[31m******************** Warning!!!!!!$account supposed privileged, but onchain not ******************** \033[0m"
                        printf %.s* {1..100} && echo
                        pass2="false"
                    else
                        echo "$account privileged correct : $privilege"
                fi
            else
                if [ -n "$(echo $privilege)" ]
                    then
                        printf %.s* {1..100} && echo
                        echo -e "\033[31m************** Warning!!!!!!$account supposed no privileged, but onchain privileged ************** \033[0m"
                        printf %.s* {1..100} && echo
                        pass2="false"
                fi
        fi
    done

# whether pass the authority validation
if [ $pass2 == "false" ]
    then
        echo -e "\033[31m************* The authority validation did not pass, please send this result to goclab ************* \033[0m"
    else
        echo -e "\033[32m********************************* The authority validation passed ********************************* \033[0m"
fi



# check code hash
echo -e "\n\n--------------------------     validating system contract code hash     ---------------------------"

declare -A supposed_hash
supposed_hash=(     [gocio]="33f3b7c17f84e88aca528ebdb37bfa072fc086543298016c2e5db14beec30530"
                    [gocio.token]="e87d28ac3b68ad6f84b45be23799eb767c747f0e527078581febc30e2f434531"
                    [gocio.msig]="abe3fd766cd42ed25f6aade735118c18b46f59c3198c57a4f4ae04ec58ac0686"  )
pass3="true"

for account in $(echo ${!supposed_hash[*]})
    do
        hash=$($CLEOS get code $account | awk '{print $3}')
        if [ ${supposed_hash[$account]} != $hash ]
            then
                printf %.s* {1..100} && echo
                echo -e "\033[31m*************** Warning!!!!!!$account supposed hash : ${supposed_hash[$account]}, onchain : $hash *************** \033[0m"
                printf %.s* {1..100} && echo
                pass3="false"
            else
                echo "$account hash correct : $hash"
        fi
    done

# whether pass the authority validation
if [ $pass3 == "false" ]
    then
        echo -e "\033[31m************* The code hash validation did not pass, please send this result to goclab ************* \033[0m"
    else
        echo -e "\033[32m********************************* The code hash validation passed ********************************* \033[0m"
fi



# final validation result
if [[ $pass1 == "true" && $pass2 == "true" && $pass3 == "true" ]]
    then
        echo -e "\n\033[34m" && printf %.s* {1..100} && echo
        echo -e "******************* Congratulations!!! All the validation passed, let's go goc! ********************"
        printf %.s* {1..100} && echo -e "\033[0m\n"
    else
        echo -e "\n\033[31m" && printf %.s* {1..100} && echo
        echo -e "*************** Warning!!!!! Not all tests passed, please send this result to goclab ***************"
        printf %.s* {1..100} && echo -e "\033[0m\n"
fi

