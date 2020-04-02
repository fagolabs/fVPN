Hacked version Pritunl
# 1. Requirements 
 * Requirement: 3 Servers
    - Ubuntu 16.04 LTS xenial
    - Firewall enabled
    - Network Interfaces: 2 NICs/server
    
| Node | Public IP | Management IP (for MongoDB  Replicaset) |
| --- | --- | --- |
| Node01 | Public IP 1 | MGMT IP 1 |
| Node02 | Public IP 2 | MGMT IP 2 |
| Node03 | Public IP 3 | MGMT IP 3 |

 * Make sure your system is fully updated: 
```
sudo -i
apt-get update
apt-get dist-upgrade -y
```

 * If you are using iptables or ufw firewall, use the following commands to open some port so that Pritunl works properly :

| Direction | Source | Destination | Port/Port Range |
| --- | --- | --- | --- |
| Ingress | 0.0.0.0/0 | - | 80 |
| Ingress | 0.0.0.0/0 | - | 443 |
| Ingress | MGMT Subnet (e.g: 10.60.1.0/24) | - | 27017 |
| Ingress | 0.0.0.0/0 | - | 10000-20000 |
| Egress | - | 0.0.0.0/0 | 80 |
| Egress | - | 0.0.0.0/0 | 443 |
| Egress | - | MGMT Subnet (e.g: 10.60.1.0/24) | 27017 |
| Egress | - | 0.0.0.0/0 | 10000-20000 |

* Register a domain and add 3 A-Records, pointing domain to 3 public IPs belong to Pritunl Servers. E.g:

| Record Type | Name | Value |
| --- | --- | --- |
| A | vpn.fago-labs.club | Public IP 1 |
| A | vpn.fago-labs.club | Public IP 2 |
| A | vpn.fago-labs.club | Public IP 3 |

Or

| Record Type | Name | Value |
| --- | --- | --- |
| A | fago-labs.club | Public IP 1 |
| A | fago-labs.club | Public IP 2 |
| A | fago-labs.club | Public IP 3 |
| CNAME | vpn.fago-labs.club | fago-labs.club |



# 2. Installation

 * Clone source code from repository: 
```
sudo -i
cd /usr/src
git clone https://github.com/fagolabs/fVPN
```
 * Go to the folder cloned: 
```
cd fVPN/vpn-portal/pritunl
```
 * Run file install.sh with sudo privielege: 
```
bash install.sh
```


# 4. Post installation

- Get pritunl setup key:
```
python server.py setup-key
```
Sample output: `4e500b26f1df408fabc19c105544c501`

- Access pritunl on web browser: https://\<pritunl ip>

Paste pritunl setup-key got above & change mongoDB IP (default: 127.0.0.1)

- Wait till pritunl setup process to be successful.

- Generate pritunl default password:
```
python server.py default-password
```
Sample output:
```
 Getting default administrator password
Administrator default password:
  username: "pritunl"
  password: "aFrSG0AwZoLr"
```

Paste username and password to browser and getting started with pritunl.

* Note: you can get 2 default premium account from account.json file stored inside source code folder, just import it to MongoDB: 

```
mongoimport --db=pritunl --collection=administrators --file=account.json
```

### 6. Setup Let's Encrypt

- Login pritunl server: https://vpn.fago-labs.club. Click "Settings". On the popup, type: ```vpn.fago-labs.club``` under "Lets Encrypt Domain", then click "Save":

![settings](setup/letsencrypt.png)


# Features

1. full enterprise's features without remote subscription checking
2. dark mode/ light mode available
3. removed subscription status button
4. create new administrator account with enterprise subscription
5. ready with 2 accounts: pritunl and dev
