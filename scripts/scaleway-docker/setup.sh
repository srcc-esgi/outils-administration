#!/bin/bash

# This script will ensure ansible is installed on the system,
# configure /etc/ansible/hosts if needed, ans launch the playbooks.

# Get current work directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if user-config and ansible hosts are present
if [ ! -f $DIR/user-config.cfg ]; then 
    echo "user-config file not found!"
    exit 1
elif [ ! -f $DIR/ansible/hosts ]; then
    echo "Ansible hosts file not found!"
    exit 1
fi

# Read config file
source $DIR/user-config.cfg

# Install ansible dependencies
apt-get install -qqy gcc g++ python-dev libffi-dev libssl-dev

# Install/upgrade pip and ansible
if command -v pip >/dev/null 2>&1; then
    if [ -f /tmp/get-pip.py ]; then rm /tmp/get-pip.py; fi;
    wget https://bootstrap.pypa.io/get-pip.py -P /tmp
    python /tmp/get-pip.py
else
    pip install --upgrade pip
elif command -v ansible >/dev/null 2>&1
    pip install ansible
else
    pip install --upgrade ansible
fi

# Read ansible hosts and accept rsa keys
ssh-keyscan -f "$DIR/ansible/hosts" >> ~/.ssh/known_hosts

# Launch playbook
ansible-playbook $DIR/ansible/deploy.yml -i $DIR/ansible/hosts
