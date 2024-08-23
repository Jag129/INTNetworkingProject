/'
#!/bin/bash

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
      ssh -i "$KEY_PATH" -o ProxyCommand="ssh -W %h:%p -i $KEY_PATH ubuntu@$bsto" ubuntu@$rem "$cmd"
      #ssh -t -i $KEY_PATH ubuntu@$bsto ssh -i $KEY_PATH ubuntu@$rem "$cmd"
      else
        exit 1
fi
'/
#!/bin/bash

# Assign arguments to variables
bsto="$1"
rem="$2"
cmd="$3"

# Check if KEY_PATH is set
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is expected."
    exit 5
fi

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    echo "Please provide bastion IP address."
    exit 5
fi

# Case 1: Connect directly to the public instance
if [ "$#" -eq 1 ]; then
    echo "Connecting directly to the public instance..."
    ssh -i "$KEY_PATH" ubuntu@$bsto

# Case 2: Connect to the private instance via the public instance
elif [ "$#" -eq 2 ]; then
    echo "Connecting to the private instance via the public instance..."
    ssh -i "$KEY_PATH" -o ProxyCommand="ssh -W %h:%p -i $KEY_PATH ubuntu@$bsto" ubuntu@$rem

# Case 3: Run a command on the private instance through the public instance
elif [ "$#" -eq 3 ]; then
    echo "Command accepted, running command on the private instance via the public instance..."
    ssh -i "$KEY_PATH" -o ProxyCommand="ssh -W %h:%p -i $KEY_PATH ubuntu@$bsto" ubuntu@$rem "$cmd"
else
    echo "Incorrect usage."
    exit 5
fi
