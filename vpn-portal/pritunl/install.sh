#!/bin/bash
sudo apt install -y git bzr python2 python-devel python-pip net-tools openvpn bridge-utils psmisc gcc-c++


wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list

sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod

tee -a ~/.bashrc << EOF
export GOPATH=\$HOME/go
export PATH=/usr/local/go/bin:\$PATH
EOF
source ~/.bashrc

go get -u github.com/pritunl/pritunl-dns
sudo ln -s ~/go/bin/pritunl-dns /usr/bin/pritunl-dns

python setup.py build
pip install -r requirements.txt
sudo python setup.py install

