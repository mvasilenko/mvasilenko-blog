---
title: "Docker notes"
date: 2017-10-05T11:53:31+03:00
draft: false
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

# How to continue exited container

```
docker start  `docker ps -q -l` # restart it in the background
docker attach `docker ps -q -l` # reattach the terminal & stdin
```

# Docker cleanup

list all exited containers - `docker ps -aq -f status=exited`
remove all stopped containers - `docker ps -aq --no-trunc | xargs docker rm`

`docker container prune` - remove stopped containers
`docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi` - remove unused images

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




# create network namespace

`sudo ip netns add test1` - create network namespace

`sudo ip netns exec test1 ip a` - execute command in namespace

`sudo ip link add veth-a type veth peer name veth-b` - create veth-a veth-b pair

`sudo ip link set veth-b netns test1` - change namespace for veth-b

`sudo ip netns exec test1 ip addr add 192.168.2.2/24 dev veth-b` - add ip address to veth-b

`sudo ip netns exec test1 ip l set veth-b up` - set link to up

now we can ping 192.168.2.2

please go to http://www.opencloudblog.com/?p=66 for more

list current network namespaces - no docker namespaces for running containers here

```
ls /var/run/netns
demo  test1
```

docker namespaces can be seen at /proc


```
$ docker inspect --format '{{.State.Pid}}' aa787d288d87
3963
$ sudo ls -l /proc/3963/ns/
lrwxrwxrwx 1 root root 0 Oct 24 15:46 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Oct 24 15:46 ipc -> ipc:[4026532614]
lrwxrwxrwx 1 root root 0 Oct 24 15:46 mnt -> mnt:[4026532612]
lrwxrwxrwx 1 root root 0 Oct 24 15:43 net -> net:[4026532617]
lrwxrwxrwx 1 root root 0 Oct 24 15:46 pid -> pid:[4026532615]
lrwxrwxrwx 1 root root 0 Oct 24 15:46 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Oct 24 15:46 uts -> uts:[4026532613]

```

now we can access container network namespace


```
sudo ln -s /proc/3963/ns/net /var/run/netns/3963
ip netns list - will show 3963
sudo ip netns exec 3963 ip a
```

`docker inspect --format '{{.NetworkSettings.IPAddress}}' test1` - get ip address by container name

docker installs iptables rules to redirect all needed traffic - this is what we see on docker host

```
$ sudo iptables -t nat -L -nv
Chain PREROUTING (policy ACCEPT 374K packets, 80M bytes)
 pkts bytes target     prot opt in     out     source               destination
46413 2414K DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT 374K packets, 80M bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 78762 packets, 4724K bytes)
 pkts bytes target     prot opt in     out     source               destination
    1    60 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT 78762 packets, 4724K bytes)
 pkts bytes target     prot opt in     out     source               destination
   84  5366 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
```

#

let's try


# misc links

http://securitynik.blogspot.cz/2016/12/docker-networking-internals-how-docker_16.html
