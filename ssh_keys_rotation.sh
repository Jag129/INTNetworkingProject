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
scp -i $exkey $newpub "ubuntu@$input:/home/ubuntu/"
#Append the current key
ssh -i $exkey ubuntu@$input "cat ~/.ssh/id_new.pub>> $HOME/.ssh/authorized_hosts"

#Delete old Key
local=$(cat $exkey.pub)

ssh -i $exkey ubuntu@$input "
    sed -i \"/$exkey/d\" ~/.ssh/authorized_keys
"







