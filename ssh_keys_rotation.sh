<<ci
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


ci
#!/bin/bash

# Ensure correct usage
if [ $# -ne 1 ]; then
  echo "Usage: $0 <private-instance-ip>"
  exit 1
fi

# Variables
PRIVATE_IP=$1
NEW_KEY_PATH="$HOME/.ssh/id_rsa_new"
PUBLIC_KEY_PATH="$NEW_KEY_PATH.pub"
OLD_KEY_PATH="$HOME/.ssh/id_rsa"

# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -f $NEW_KEY_PATH -N ""
chmod 600 $NEW_KEY_PATH

# Copy the new public key to the authorized_keys on the private instance
NEW_PUBLIC_KEY=$(cat $PUBLIC_KEY_PATH)
ssh -i "$OLD_KEY_PATH" ubuntu@$PRIVATE_IP "echo '$NEW_PUBLIC_KEY' >> ~/.ssh/authorized_keys"

# Verify the new key works
ssh -i "$NEW_KEY_PATH" ubuntu@$PRIVATE_IP 'exit'
if [ $? -ne 0 ]; then
  echo "Failed to connect to the private instance using the new key."
  exit 1
fi

# Remove the old key from authorized_keys on the private instance
OLD_PUBLIC_KEY=$(cat $OLD_KEY_PATH.pub)
ESCAPED_OLD_KEY=$(echo "$OLD_PUBLIC_KEY" | sed 's/[\/&]/\\&/g')
ssh -i "$NEW_KEY_PATH" ubuntu@$PRIVATE_IP "sed -i '/$ESCAPED_OLD_KEY/d' ~/.ssh/authorized_keys"
#ssh -i "$NEW_KEY_PATH" ubuntu@$PRIVATE_IP "grep -v '$OLD_PUBLIC_KEY' ~/.ssh/authorized_keys > ~/.ssh/authorized_keys.tmp && mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys"

# Verify the old key no longer works
ssh -i "$OLD_KEY_PATH" ubuntu@$PRIVATE_IP 'exit'
if [ $? -eq 0 ]; then
  echo "Old key is still valid, which shouldn't be the case."
  exit 1
fi

# Remove old key from the public instance
rm -f $OLD_KEY_PATH $OLD_KEY_PATH.pub

# Replace the old key with the new key locally
mv $NEW_KEY_PATH $HOME/.ssh/id_rsa
mv $PUBLIC_KEY_PATH $HOME/.ssh/id_rsa.pub

echo "SSH key rotation completed successfully."