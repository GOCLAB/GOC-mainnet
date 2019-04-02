#!/bin/bash

# to modify!!
BPNAME=<yourbpname>   # such as BPNAME=goclabgoclab
PUBKEY=<yournewkey>   # such as PUBKEY=GOC5UisWmrjVjgHp3tD2AvZbaehQiWjAwDgUnQLUGYBHtJ6JRAERP
CLEOS_DIR='<your cleos dir>'      # such as CLEOS_DIR='/home/goclab/goc/build/programs/cleos/cleos'
WALLET_HOST='<your keosd --http-server-address>' # such as WALLET_HOST='127.0.0.1:8900'



PERMISSION=claimer
CLEOS="$CLEOS_DIR -u http://api.goclab.io:8080 --wallet-url http://$WALLET_HOST"
set -x
$CLEOS set account permission $BPNAME $PERMISSION $PUBKEY
sleep 1
$CLEOS set action permission $BPNAME gocio claimrewards $PERMISSION

