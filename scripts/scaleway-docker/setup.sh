#!/bin/bash
# This script will ensure ansible is installed on the system,
# configure /etc/ansible/hosts if needed, ans launch the
# playbooks.

# Get current work directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if user-config and ansible hosts are present
if [ ! -f $DIR/user-config.cfg ]; then
    echo "user-config file not found!"
    exit 1
fi
if [ ! -f $DIR/ansible/hosts ]; then
    echo "Ansible hosts file not found!"
    exit 1
fi

# Read config file
echo "Reading config...." >&2
source $DIR/user-config.cfg

# Install ansible dependencies
apt-get install gcc g++ python-dev libffi-dev libssl-dev -y

# Install ansible using pip
wget https://bootstrap.pypa.io/get-pip.py -P /tmp
python /tmp/get-pip.py
pip install ansible

# Read ansible hosts and accept rsa keys
while read -r line; do
    [[ "$line" =~ ^#.*$ ]] && continue
    ssh-keyscan ${line} >> ~/.ssh/known_hosts
done < "$DIR/$ansible_hosts"

# Launch playbook
ansible-playbook $DIR/ansible/deploy.yml -i $DIR/ansible/hosts
