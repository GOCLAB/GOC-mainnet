#!/bin/bash

# to modify!!
BPNAME=<yourbpname>   # such as BPNAME=goclabgoclab
PRIVATE_KEY=<yourprivatekey>
BIN_DIR='<your programs dir>'      # such as BIN_DIR='/home/goclab/goc/build/programs'
NODE_HOST='<your nodeos --http-server-address>' # such as NODE_HOST='127.0.0.1:8888' or NODE_HOST='api.goclab.io:8080'



# default param
CLEOS="$BIN_DIR/cleos/cleos -u http://$NODE_HOST --wallet-url http://$WALLET_HOST"
PERMISSION=claimer
WALLETNAME=claim
WALLETDIR="./claim-wallet"
WALLET_HOST='127.0.0.1:4526'


# step 1: wait until 1 hour from last claim
last_claim_time=`$CLEOS get table gocio gocio producers -l 1000 | jq -r '.rows[] | select(.owner == "'$BPNAME'") | .last_claim_time'`
echo "last_claim_time = `expr ${last_claim_time}`"
now=`date +%s%N`
#seconds=`date -d $last_claim_time +%s`
diff=`expr $last_claim_time / 1000000 - $now / 1000000000 + 1 \* 3600 `
echo "wait for ${diff}s"
sleep $diff


# step 2: create new wallet and import key
mkdir -p $WALLETDIR
if [ -e $WALLETDIR/$WALLETNAME.wallet ]
    then
        rm -r $WALLETDIR/$WALLETNAME.wallet
fi
$BIN_DIR/keosd/keosd --http-server-address $WALLET_HOST -d $WALLETDIR & echo $! > $WALLETDIR/keosd.pid
sleep 0.5
$CLEOS wallet create -n $WALLETNAME --to-console
$CLEOS wallet import -n $WALLETNAME --private-key $PRIVATE_KEY

# step 3: claim rewards
$CLEOS push action gocio claimrewards "{\"owner\":\"$BPNAME\"}" -p $BPNAME@$PERMISSION
if [ $? -eq 0 ]; then
    echo 'claimed at ' `date`
else
    echo 'failed to claim at ' `date`
fi

# step 4: clean
pid=$(cat $WALLETDIR/keosd.pid)
echo $pid
kill $pid
rm $WALLETDIR/keosd.pid
rm $WALLETDIR/$WALLETNAME.wallet
history -c
history -w

