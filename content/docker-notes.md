---
title: "Docker notes"
date: 2017-10-05T11:53:31+03:00
draft: true
tag: ["docker", "containers"]
categories: ["docker"]
topics: ["docker"]
banner: "banners/docker.png"
---

# Docker notes

Enable docker on ubuntu and add current user to docker group
```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
```

# docker machine

`docker-machine` - tool for provisioning and managing dockerized hosts

`docker-machine create -d virtualbox default` - create virtual host

`docker-machine env default` - outputs

```
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/home/ubuntu/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"
# Run this command to configure your shell:
# eval $(docker-machine env default)

```

ok, we've booted minimal docker box in virtualbox, we can ssh to it by 
`docker-machine ssh default` and run Docker hello world inside it by
`docker run --rm hello-world`


# DOCKER NETWORKING

`docker network ls` - list docker networks

`docker network inspect bridge` - describe bridge driver

`docker info | grep Network` - list docker network drivers: `Network: bridge host macvlan null overlay`

`docker run -dt ubuntu sleep infinity` - run container in sleep mode


# get ip address allocated for specific container

`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' 16966a7f487f`

# how to find out veth interface for specific container

get container id, then find out it's network namespace, get it's peer_ifindex value, and find out matching veth interface

```
$ sudo docker inspect --format='{{.NetworkSettings.SandboxKey}}' 16966a7f487f
/var/run/docker/netns/49d0bee36a5c
$ sudo nsenter --net=/var/run/docker/netns/49d0bee36a5c ethtool -S eth0
NIC statistics:
     peer_ifindex: 16
$ sudo ip link | grep 16
16: veth3733bc4@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP mode DEFAULT group default
```
or, in case where `SandboxID` and `SandboxKey` are empty

```
$ docker inspect --format='{{.State.Pid}}' 16966a7f487f
31315
ubuntu@vagrant:~$ sudo nsenter -t 31315 -n ethtool -S eth0
NIC statistics:
     peer_ifindex: 16
```

taken from https://github.com/moby/moby/issues/20224




http://securitynik.blogspot.cz/2016/12/docker-networking-internals-how-docker_16.html
