---
title: "Running mysql in docker with persistent volumes"
date: 2017-09-22T17:53:31+03:00
tag: ["docker", "mysql"]
categories: ["docker"]
topics: ["docker"]
#banner: "banners/aws.png"
draft: true
---

First things first, install docker itself

```
sudo apt-get install docker.io #Ubuntu/Debian
yum install docker # RedHat/CentOS
```

Then, run mysql container

```
docker run --name=mysql-test mysql
```

It will fail with such output, because we didn't pass root password as environment variable
(common way to pass credentials when running containers)

```
Status: Downloaded newer image for mysql:latest
error: database is uninitialized and password option is not specified
  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
```

Remove container, and try again

```
docker rm mysql-test
docker run --name=test-mysql --env="MYSQL_ROOT_PASSWORD=mypassword" mysql
[lot of output skipped]
2017-09-22T13:00:55.264313Z 0 [Note] mysqld: ready for connections.
Version: '5.7.19'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  MySQL Community Server (GPL)
```

OK, it's running, but console has stuck, to detach it, kill it from another terminal by 

```
docker stop mysql-test
docker rm mysql-test
```

And restart it with `--detach` flag, and volume `/opt/mysql-data` mounted from host for the mysql data directory


```
mkdir -p /opt/mysql-data
docker run --detach --name=mysql-test --env="MYSQL_ROOT_PASSWORD=mypassword" \
       --volume=/opt/mysql-data:/var/lib/mysql mysql
sleep 5s
# mysql container logs
docker logs mysql-test

# grab mysql container IP, 172.17.0.2 in my case and assign in to the MYSQL_IP variable
MYSQL_IP=`docker inspect -f "{{ .NetworkSettings.IPAddress }}" mysql-test`
# check host volumes mounted into container
docker inspect -f "{{ .Mounts }}" mysql-test
# or this way
docker inspect -f '{{ (index .Mounts 0).Source }}' mysql-test
# another way
docker inspect -f "{{ json .Mounts }}" mysql-test | jq
```

Next, we can install mysql client at the host and connect to the container

```
apt-get install mysql-client
mysql -uroot -pmypassword -h $MYSQL_IP -P 3306
[skip]
mysql>
```

OK, let's run our application in second container, which is linked to the first one

```
docker run --name python-test --link mysql-test:mysql python cat /etc/hosts
[skip]
172.17.0.2      mysql-test 8f73b4cfadce
```

Based on

https://severalnines.com/blog/mysql-docker-containers-understanding-basics
