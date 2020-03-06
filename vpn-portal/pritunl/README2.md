Hacked version Pritunl

# installation

sudo apt install -y install git bzr python2 python-devel python-pip net-tools openvpn bridge-utils psmisc gcc-c++

wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod


wget https://dl.google.com/go/go1.12.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xf go1.12.1.linux-amd64.tar.gz
tee -a ~/.bashrc << EOF
export GOPATH=\$HOME/go
export PATH=/usr/local/go/bin:\$PATH
EOF
source ~/.bashrc
go get -u github.com/pritunl/pritunl-dns
go get -u github.com/pritunl/pritunl-web
sudo ln -s ~/go/bin/pritunl-dns /usr/bin/pritunl-dns
sudo ln -s ~/go/bin/pritunl-web /usr/bin/pritunl-web



git clone https://github.com/fagolabs/fVPN.git
cd ./fVPN/vpn-portal/pritunl 
python setup.py build
pip install -r requirements.txt
sudo python setup.py install

mongoimport --db=pritunl --collection=administrators --file=account.json


# run server
sudo python server.py

# feature
1. full enterprise's features without remote subscription checking
2. dark mode/ light mode available
3. removed subscription status button
4. create new administrator account with enterprise subscription
5. ready with 2 account: pritunl and dev