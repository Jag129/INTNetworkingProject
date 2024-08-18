#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
  echo "Correct usage: $0 <target-instance-ip>"
  exit 1
fi

# Define variables
TARGET_IP=$1
NEW_SSH_KEY="$HOME/.ssh/new_rsa"
NEW_PUB_KEY="${NEW_SSH_KEY}.pub"
OLD_SSH_KEY="$HOME/.ssh/id_rsa"

# Create a new SSH key pair
ssh-keygen -t rsa -b 4096 -f $NEW_SSH_KEY -N ""
chmod 600 $NEW_SSH_KEY

# Add the new public key to the authorized_keys on the target instance
NEW_PUB_CONTENT=$(cat $NEW_PUB_KEY)
ssh -i "$OLD_SSH_KEY" ubuntu@$TARGET_IP "echo '$NEW_PUB_CONTENT' >> ~/.ssh/authorized_keys"

# Test the new key to ensure it works
ssh -i "$NEW_SSH_KEY" ubuntu@$TARGET_IP 'exit'
if [ $? -ne 0 ]; then
  echo "Connection test with new key failed."
  exit 1
fi

# Remove the old public key from authorized_keys on the target instance
OLD_PUB_CONTENT=$(cat ${OLD_SSH_KEY}.pub)
ESCAPED_OLD_PUB=$(echo "$OLD_PUB_CONTENT" | sed 's/[\/&]/\\&/g')
ssh -i "$NEW_SSH_KEY" ubuntu@$TARGET_IP "sed -i '/$ESCAPED_OLD_PUB/d' ~/.ssh/authorized_keys"

# Confirm the old key no longer provides access
ssh -i "$OLD_SSH_KEY" ubuntu@$TARGET_IP 'exit'
if [ $? -eq 0 ]; then
  echo "Warning: Old key still valid; expected it to be removed."
  exit 1
fi

# Clean up old keys locally
rm -f $OLD_SSH_KEY ${OLD_SSH_KEY}.pub

# Rename new keys to replace old ones locally
mv $NEW_SSH_KEY $HOME/.ssh/id_rsa
mv $NEW_PUB_KEY $HOME/.ssh/id_rsa.pub

echo "SSH key rotation completed without issues."
