Hacked version Pritunl
# before install 
 * requirement: 
    + Ubuntu 18.04 LTS bionic
    + Firewall enabled
 * make sure your system is fully updated: 
```
    $ sudo apt update
    $ sudo apt upgrade
```

 * If you are using ufw firewall, use the following commands to open some port so that Pritunl works properly :
```
    $ sudo ufw allow http
    $ sudo ufw allow https
    $ sudo ufw allow 10447/udp
    $ sudo ufw reload
```

# installation

 * clone source code from repository: 
```
    $ git clone https://github.com/fagolabs/fVPN
```
 * go to the folder cloned: 
```
    $ cd ./fVPN/vpn-portal/pritunl
```
 * run file install.sh with sudo privielege: 
```
    $ sudo bash install.sh
```


# post installation

- Get pritunl setup key:
```
    $ python server.py setup-key
```
Sample output: `4e500b26f1df408fabc19c105544c501`

- Access pritunl on web browser: https://\<pritunl ip>

Paste pritunl setup-key got above & change mongoDB IP (default: 127.0.0.1)

- Wait till pritunl setup process to be successful.

- Generate pritunl default password:
```
    $ python server.py default-password
```
Sample output:
```
 Getting default administrator password
Administrator default password:
  username: "pritunl"
  password: "aFrSG0AwZoLr"
```

Paste username and password to browser and getting started with pritunl.

# feature

1. full enterprise's features without remote subscription checking
2. dark mode/ light mode available
3. removed subscription status button
4. create new administrator account with enterprise subscription



