#!/bin/bash

# get the BP candidate account name and the keys
if [ -f ./bp_accounts.txt ]
    then
        rm ./bp_accounts.txt
fi

echo "# This txt list producer candidate accounts that will be created once GOC launch, please check" >> ./bp_accounts.txt
echo "# Format: producername-ownerkey-activekey(you can ingnore activekey if you like)" >> ./bp_accounts.txt
echo -e "# If you want to change or add your key, just modify your bp.ini in producer_info file, this document will be updated automatically\n" >> ./bp_accounts.txt

FILENAME="./producer-info/"
BPS="$(ls $FILENAME)"

for f in $BPS
do
    name="$(cat $FILENAME$f | grep "producer-name" | awk '{print $3}')"
    owner="$(cat $FILENAME$f | grep "Owner-key" | awk '{print $3}')"
    active="$(cat $FILENAME$f | grep "Active-key" | awk '{print $3}')"
    if [ -n "$(echo $active)" ]
        then
            echo $name-$owner-$active >> ./bp_accounts.txt
        else
            echo $name-$owner >> ./bp_accounts.txt
    fi
done

