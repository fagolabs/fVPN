#!/bin/bash

# Basic
sudo apt install -y git bzr python-pip net-tools openvpn bridge-utils psmisc build-essential python-setuptools python-pip python-dev supervisor
pip install --upgrade pip

# Setup MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get --assume-yes install apt-transport-https
sudo apt-get update
sudo apt-get --assume-yes install mongodb-org
sed -i "s|bindIp: 127.0.0.1|bindIp: 0.0.0.0|g" /etc/mongod.conf
cat << EOF >> /etc/mongod.conf
replication:
  replSetName: "rs0"
EOF
sudo systemctl start mongod
sudo systemctl enable mongod
