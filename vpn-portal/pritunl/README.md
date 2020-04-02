# 1. Requirements 
 * Requirement: 3 Servers
    - Ubuntu 16.04 LTS xenial
    - Firewall enabled
    - Network Interfaces: 2 NICs/server. Exp:
    
| Node | Public IP | Management IP (for MongoDB  Replicaset) | MongoDB hostname |
| --- | --- | --- | --- |
| Node01 | Public IP 1 | 10.60.1.30 | mongodb0 |
| Node02 | Public IP 2 | 10.60.1.32 | mongodb1 |
| Node03 | Public IP 3 | 10.60.1.37 | mongodb2 |

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



# 2. Installation MongoDB
## 2.1 Install MongoDB

Repeat the following steps on all nodes:
 
 * Set mongodb hostname (notes: change mongodb IPs first):

```
export MONGODB0=10.60.1.30
export MONGODB1=10.60.1.32
export MONGODB2=10.60.1.37

cat << EOF >> /etc/hosts
${MONGODB0}  mongodb0  
${MONGODB1}  mongodb1
${MONGODB2}  mongodb2
EOF
```

 * Clone source code from repository: 

```
sudo su
cd /usr/src
git clone https://github.com/fagolabs/fVPN
```
 * Go to the folder cloned: 

```
cd /usr/src/fVPN/vpn-portal/pritunl
```

 * Install MongoDB: 

```
sudo su
chmod +x install_mongodb.sh && bash install_mongodb.sh
```

## 2.2 Inject Pritunl Premium account

- On the 1st mongodb node (mongodb0):

```
cd /usr/src/fVPN/vpn-portal/pritunl
sudo su
mongoimport --db=pritunl --collection=administrators --file=account.json
```

## 2.3 Setup Replica Set 

- On the 1st mongodb node (mongodb0), setup replica set for mongodb:

```
sudo su
mongo
```

- On the mongodb shell (in mongodb0 node), setup replicaset:

```
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "mongodb0:27017" },
      { _id: 1, host: "mongodb1:27017" },
      { _id: 2, host: "mongodb2:27017" }
   ]
})
```

Wait for few seconds, then check status of replica set:

```
rs.conf()
rs.status()
```

Ensure that this node to be the PRIMARY node in replica set and replica set has 1 PRIMARY (mongodb0) + 2 SECONDARY (mongodb1, mongodb2).

# 3. Setup Pritunl 

Execure the following commands on all nodes:
 
```
cd /usr/src/fVPN/vpn-portal/pritunl
sudo su
chmod +x install_pritunl.sh && bash install_pritunl.sh
```

# 4. Post installation

## 4.1 Setup the 1st server

- SSH to the 1st Pritunl server and go to setup folder:

```
cd /usr/src/fVPN/vpn-portal/pritunl
```

- Get pritunl setup key:
```
python server.py setup-key
```
Sample output: `4e500b26f1df408fabc19c105544c501`

- Access pritunl on web browser: ```https://<Public IP of the 1st pritunl server>```

- Paste pritunl setup-key got above & change mongoDB connection string to: ```mongodb://mongodb0:27017,mongodb1:27017,mongodb2:27017/pritunl```

- Wait till pritunl setup process to be successful.

- Reset pritunl password:
```
python server.py reset-password
```

Sample output:
```
 Getting default administrator password
Administrator default password:
  username: "pritunl"
  password: "aFrSG0AwZoLr"
```

Paste username and password to browser and getting started with pritunl.

## 4.2 Setup the 2 remaining servers

Repeat the following steps for each of remaining servers:

- SSH to pritunl server and go to setup folder:

```
cd /usr/src/fVPN/vpn-portal/pritunl
```

- Get pritunl setup key:
```
python server.py setup-key
```
Sample output: `4e500b26f1df408fabc19c105544c501`

- Access pritunl on web browser: ```https://<Public IP of the 2nd/3rd pritunl server>```

- Paste pritunl setup-key got above & change mongoDB connection string to: ```mongodb://mongodb0:27017,mongodb1:27017,mongodb2:27017/pritunl```

- Wait till pritunl setup process to be successful.

# 5. Setup Let's Encrypt

- Login pritunl server: https://vpn.fago-labs.club. Click "Settings". On the popup, type: ```vpn.fago-labs.club``` under "Lets Encrypt Domain", then click "Save":

![settings](setup/letsencrypt.png)

- Wait till pritunl setup Let's Encrypt certificates successfully. Result should be like below:

![settings](setup/letsencrypt2.png)


# Features

1. full enterprise's features without remote subscription checking
2. dark mode/ light mode available
3. removed subscription status button
4. create new administrator account with enterprise subscription
5. ready with 2 accounts: pritunl and dev
