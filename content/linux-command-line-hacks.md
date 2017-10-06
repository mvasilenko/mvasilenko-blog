---
title: "Linux command line snippets"
date: 2017-09-11T17:58:06+03:00
tag: ["bash", "linux"]
categories: ["bash"]
topics: ["bash"]
draft: true
banner: "banners/bash.png"
---

Git checkout locally deleted files

`git ls-files -d | xargs git checkout --`

grep string1 OR string2 in filename

`grep -E "string1|string2" filename`


Generating self-signed SSL certificates

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

