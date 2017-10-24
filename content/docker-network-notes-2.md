---
title: "Docker network notes #2"
date: 2017-10-24T11:53:31+03:00
draft: true
tag: ["docker", "containers", "networking"]
categories: ["docker"]
topics: ["docker"]
banner: "banners/docker.png"
---


# Docker networking, overlay mode, two host etcd cluster

run at node 1

```
wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
tar zxf etcd-v3.0.12-linux-amd64.tar.gz && cd etcd-v3.0.12-linux-amd64

nohup ./etcd --name docker-node1 --initial-advertise-peer-urls http://192.168.205.10:2380 \
--listen-peer-urls http://192.168.205.10:2380 \
--listen-client-urls http://192.168.205.10:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.10:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&

```

run at node 2

```
wget https://github.com/coreos/etcd/releases/download/v3.0.12/etcd-v3.0.12-linux-amd64.tar.gz
tar zxvf etcd-v3.0.12-linux-amd64.tar.gz && cd etcd-v3.0.12-linux-amd64/

nohup ./etcd --name docker-node2 --initial-advertise-peer-urls http://192.168.205.11:2380 \
--listen-peer-urls http://192.168.205.11:2380 \
--listen-client-urls http://192.168.205.11:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://192.168.205.11:2379 \
--initial-cluster-token etcd-cluster \
--initial-cluster docker-node1=http://192.168.205.10:2380,docker-node2=http://192.168.205.11:2380 \
--initial-cluster-state new&

./etcdctl cluster-health
member 21eca106efe4caee is healthy: got healthy result from http://192.168.205.10:2379
member 8614974c83d1cc6d is healthy: got healthy result from http://192.168.205.11:2379
cluster is healthy
```

run at node 1

```
sudo service docker stop
sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.10:2379 --cluster-advertise=192.168.205.10:2375
```

run at node 2

```
sudo service docker stop
sudo /usr/bin/docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://192.168.205.11:2379 --cluster-advertise=192.168.205.11:2375
```

create overlay network `demo` on node 1

```
sudo docker network create -d overlay demo
sudo docker network inspect demo
```

it will appears on node 2 automatically

```
./etcdctl ls /docker
/docker/network
/docker/nodes

./etcdctl ls /docker/nodes
/docker/nodes/192.168.205.10:2375
/docker/nodes/192.168.205.11:2375

./etcdctl ls /docker/network/v1.0/network
/docker/network/v1.0/network/f42d026bda9cd139b713432889465f39c4f14028f5858a262c828693dca575f2
```

Let's run container on this network
```
sudo docker run -d --name test1 --net demo busybox sh -c "while true; do sleep 3600; done"
[snip]
2ab420dba65ad45ad3e8171940fb1a61696af55f90ea1630d95126e9abf33f20

```


http://docker-k8s-lab.readthedocs.io/en/latest/docker/docker-etcd.html
