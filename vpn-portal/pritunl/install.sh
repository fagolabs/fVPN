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
sudo systemctl start mongod
sudo systemctl enable mongod

mongoimport --db=pritunl --collection=administrators --file=account.json

# Setup Go environment
wget https://dl.google.com/go/go1.12.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xf go1.12.1.linux-amd64.tar.gz
rm -f go1.12.1.linux-amd64.tar.gz

tee -a ~/.bashrc << EOF
export GOPATH=\$HOME/go
export PATH=/usr/local/go/bin:\$PATH
EOF
source ~/.bashrc

go get -u github.com/pritunl/pritunl-dns
go get -u github.com/pritunl/pritunl-web
ln -s ~/go/bin/pritunl-dns /usr/bin/pritunl-dns
ln -s ~/go/bin/pritunl-web /usr/bin/pritunl-web

# Set up pritunl
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
python setup.py build
pip install -r requirements.txt
python setup.py install
ln -s /usr/local/bin/pritunl /usr/bin/pritunl

# Config supervisor
cat << EOF > /etc/supervisor/conf.d/pritunl.conf
[program:pritunl]
directory=/usr/src/fVPN/vpn-portal/pritunl
command=/usr/bin/python /usr/src/fVPN/vpn-portal/pritunl/server.py start
autostart=true
autorestart=true
stderr_logfile=/var/log/pritunl.err.log
stdout_logfile=/var/log/pritunl.out.log
EOF
systemctl restart supervisor

# Increase files limited
sudo sh -c 'echo "* hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* soft nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root soft nofile 64000" >> /etc/security/limits.conf'
