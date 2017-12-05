---
title: "Linux command line snippets"
date: 2017-09-11T17:58:06+03:00
tag: ["bash", "linux"]
categories: ["bash"]
topics: ["bash"]
draft: false
banner: "banners/bash.png"
---

# copy ssh key on different port than 22

`ssh-copy-id "user@host -p 8129"`


# List apache httpd modules compiled in

`apache2ctl -M`


# Remove ubuntu ubuntu-release-upgrader-core, CPU hog

`apt-get remove ubuntu-release-upgrader-core`


# Change ens160 & ens192 to eth0 & eth1

Open `/etc/default/grub` and change line `GRUB_CMDLINE_LINUX=""` to `GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"`

```
for i in {1..6};do

ssh 192.168.1.4$i 'sudo sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/" /etc/default/grub;
sudo grub-mkconfig -o /boot/grub/grub.cfg;
sudo sed -i "s/ens160/eth0/g" /etc/network/interfaces';
done
```

Re-generate config `sudo grub-mkconfig -o /boot/grub/grub.cfg`

Edit network config

```
sed -i 's/ens160/eth0/g' /etc/network/interfaces
sed -i 's/ens192/eth1/g' /etc/network/interfaces
```

http://www.itzgeek.com/how-tos/mini-howtos/change-default-network-name-ens33-to-old-eth0-on-ubuntu-16-04.html

# apache nginx .htaccess

```
SetEnvIf X-Forwarded-For ^172\.26\.0\.17 let_me_in
Order allow,deny
allow from env=let_me_in
```


# Show http requests in tcpdump

`tcpdump -n -S -s 0 -A 'tcp dst port 80' | grep -B3 -A10 "GET /some-path"`

# Rsync over SSH

`rsync -avz -e "ssh" local-dir remote.host:/remote-dir`


# Git checkout locally deleted files

`git ls-files -d | xargs git checkout --`

# Grep string1 OR string2 in filename

`grep -E "string1|string2" filename`


# Generating self-signed SSL certificates

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=Oregon/L=Portland/O=IT/CN=sentry.local"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

* openssl - command itself
* req - use X.509 PKI certificate signing request (CSR) management, we want new certificate
* -x509 - the certificate will be self-signed
* -nodes - skip the option to secure our certificate with a passphrase
* -days 365 - certificate will be considered valid during 365 days
* -newkey rsa:2048 - we want to generate a new certificate and a new RSA key (2048 bits long) at the same time
* -keyout - filename for new generated private key
* -out - filename for new certificate

CN = FQDN or IP address

Adding self-signed certificate to nginx

# print last 2 random digits with awk
`cat file.txt |cut -d"|" -f1|sort -rn -k1|awk '{printf("%s 1.%.0f\n",$1,int(100*rand()))}'`



# VIM hotkeys

G o - move to the end of file, and insert new lines
1 G or gg - move to the begin of file
