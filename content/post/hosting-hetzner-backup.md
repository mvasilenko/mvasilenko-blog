---
title: "How to use free 100GB backup space at Hetzner"
date: 2017-09-22T17:53:31+03:00
tag: ["backup", "hetzner"]
categories: ["hosting"]
topics: ["backup"]
banner: "banners/hetzner.png"
#draft: true
---

Hetzner offers free 100GB backup space when you pay >30EUR monthly for the server.
It must be activated in you account @ root-server.de and can be accessed by sftp/scp/sshfs
after key generation

```
mkdir -p /srv/backup/backup
apt-get install sshfs
sshfs u012345@u012345.your-backup.de:/ /srv/backup # Enter password
mkdir /srv/backup/.ssh
# If you did not yet create a ssh keypair for your user, do this now
ssh-keygen
# Export the public key in RFC4716 format, hetzner requires that
ssh-keygen -e -f ~/.ssh/id_rsa.pub | grep -v "Comment:" > ~/.ssh/id_rsa_rfc.pub
cat ~/.ssh/id_rsa_rfc.pub > /srv/backup/.ssh/authorized_keys
chmod 700 /srv/backup/.ssh
chmod 600 /srv/backup/.ssh/authorized_keys
```

Now we can create image and mount it

```
dd if=/dev/zero of=/srv/backup/filesystem.img bs=1 seek=100G count=1
mkfs.ext4 /srv/backup/filesystem.img
cat >>/etc/fstab
u012345@u012345.your-backup.de:/ /srv/backup fuse.sshfs defaults,_netdev,noauto,allow_root 0 0
/srv/backup/filesystem.img /srv/backup/backup ext4 defaults,loop,noauto 0 0
^D
mount /srv/backup/backup
df -h
```


Now we can use rsync to backup

```
rsync -avz --exclude=tmp --exclude=sys --exclude=lost\+found --exclude=mnt --exclude=proc --exclude=dev --exclude=media --exclude=srv / /srv/backup/backup/
```

based on
https://www.blunix.org/howto-use-hetzner-backup-space-with-rsync/
https://blog.no-panic.at/projects/hactar-incremental-daily-backup/
