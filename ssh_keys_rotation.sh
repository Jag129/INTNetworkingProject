#!/bin/bash

exkey="$HOME/.ssh/id_rsa"
newkey="$HOME/.ssh/id_new"
newpub="$newkey.pub"
input="$1"


# Check if correct number of arguments is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <private-instance-ip>"
    exit 1
fi

#Generate New Keys
ssh-keygen -t rsa -b 4096 -f $newkey -N ""

#ssh -i $exkey ubuntu@$input 'echo "$newpub" >> /home/ubuntu/.ssh/authorized_hosts'
#Append the current key
ssh -i $exkey ubuntu@$input 'cat >> $HOME/.ssh/authorized_hosts' < $newpub

#Delete old Key
local_key=$(cat /path/to/local/key.pub)

ssh -i $exkey ubuntu@$input "
    sed -i \"/$exkey/d\" ~/.ssh/authorized_keys
"







