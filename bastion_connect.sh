#!/bin/bash
/'
# Assign arguments to variables
bsto="$1"
rem="$2"
cmd="$3"

# Check if KEY_PATH is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected."
    exit 5
fi

# Check if correct number of arguments is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <public-instance-ip> <private-instance-ip>"
    exit 1
fi

# Case 1: Connect to the private instance via the public instance
if [ "$#" -eq 2 ]; then
    echo "Connecting to the private instance via the public instance..."
    ssh -i "$KEY_PATH" -o ProxyCommand="ssh -W %h:%p -i $KEY_PATH ubuntu@$bsto" ubuntu@$rem
# Case 2: Connect directly to the public instance
elif [ "$#" -eq 1 ]; then
    echo "Connecting directly to the public instance..."
    ssh -i "$KEY_PATH" ubuntu@$bsto
fi
# case 3: run command in the private machine
if [ "$#" -eq 3 ]; then
  echo "Command accepted,"
      #ssh -i "$KEY_PATH" -o ProxyCommand="ssh -W %h:%p -i $KEY_PATH ubuntu@$bsto" ubuntu@$rem "$cmd"
      ssh -t -i $KEY_PATH ubuntu@$bsto ssh -i $KEY_PATH ubuntu@$rem $cmd
      else
        exit 1
fi
'
#!/bin/bash

#KEY_PATH=/home/omer/omerNetworkingPTJkeypair.pem
KEY_PATH_2=/home/ubuntu/.ssh/id_rsa

# Check if KEY_PATH environment variable is set
if [ -z "$KEY_PATH" ]; then
  echo "KEY_PATH env var is expected"
  exit 5
fi

# Check the number of arguments
if [ "$#" -lt 1 ]; then
  echo "Please provide bastion IP address"
  exit 5
fi

# Assign variables
BASTION_IP=$1
PRIVATE_IP=$2
COMMAND=$3

scp_to_public_instance() {
  if [ -z "$3" ]; then
    echo "Usage: $0 <public-instance-ip> <local-file-path> <remote-file-path>"
    exit 5
  fi
  LOCAL_FILE=$2
  REMOTE_FILE=$3
  scp -i "$KEY_PATH" "$LOCAL_FILE" ubuntu@$PUBLIC_IP:"$REMOTE_FILE"
}
#scp -i ~/Downloads/guy_networking_project_keypair.pem /home/guy/Downloads/guy_networking_project_keypair.pem ubuntu@16.171.60.136:/home/ubuntu


# If only bastion IP is provided, connect to the bastion host
if [ -z "$PRIVATE_IP" ]; then
  ssh -i "$KEY_PATH" ubuntu@"$BASTION_IP"
else
  # If both bastion IP and private IP are provided, connect to the private host through the bastion host
  if [ -z "$COMMAND" ]; then
    ssh -t -i "$KEY_PATH" ubuntu@"$BASTION_IP" "ssh -i $KEY_PATH_2 ubuntu@$PRIVATE_IP"
  else
    ssh -t -i "$KEY_PATH" ubuntu@"$BASTION_IP" "ssh -i $KEY_PATH_2 ubuntu@$PRIVATE_IP '$COMMAND'"
  fi
fi

#