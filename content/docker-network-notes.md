---
title: "Docker network notes #1"
date: 2017-10-24T11:53:31+03:00
draft: false
tag: ["docker", "containers", "networking"]
categories: ["docker"]
topics: ["docker"]
banner: "banners/docker.png"
---


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

let's try to run nginx container named `demo` and map port 8080 to container port 80,
this will install iptables rules for those ports

```
sudo docker run -d -p 8080:80 --name demo nginx

sudo docker inspect --format {{.NetworkSettings.IPAddress}} demo
172.17.0.4

docker port demo
80/tcp -> 0.0.0.0:8080

sudo iptables -t nat -L -nv
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
46416 2414K DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 1 packets, 62 bytes)
 pkts bytes target     prot opt in     out     source               destination
    1    60 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT 1 packets, 62 bytes)
 pkts bytes target     prot opt in     out     source               destination
   84  5366 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0
    0     0 MASQUERADE  tcp  --  *      *       172.17.0.4           172.17.0.4           tcp dpt:80

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
    0     0 DNAT       tcp  --  !docker0 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8080 to:172.17.0.4:80

```

`docker network inspect bridge` - default docker0 configuration


Let's run two containers, create new `demo-bridge` network with type `bridge`,
connect two containers `test1` and `test2` to `demo-bridge` network, and test connectivity

```
docker run -d --name test1  busybox sh -c "while true;do sleep 3600;done"
docker run -d --name test2  busybox sh -c "while true;do sleep 3600;done"
docker network create -d bridge demo-bridge
docker network connect demo-bridge test1
docker exec test1 ip a|grep global
    inet 172.19.0.2/16 scope global eth1
docker exec -it test1 ping -c1 172.19.0.3
PING 172.19.0.3 (172.19.0.3): 56 data bytes
64 bytes from 172.19.0.3: seq=0 ttl=64 time=0.156 ms

```


# misc links

http://securitynik.blogspot.cz/2016/12/docker-networking-internals-how-docker_16.html
