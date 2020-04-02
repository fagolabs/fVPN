#!/bin/bash

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
