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


# openvswitch

```
sudo docker run -d --name container1 centos:7 bash -c "while true;do sleep 3600;done"
sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' container1
172.17.0.2
```

Install openvswitch, create bridge and veth pair

```
sudo apt-get install -y openvswitch-switch openvswitch-common
sudo ovs-vsctl add-br br-int

sudo ovs-vsctl show
23188809-b024-4951-b8c4-c34694b4c67c
    Bridge br-int
        Port br-int
            Interface br-int
                type: internal
    ovs_version: "2.5.2"

sudo ip link add veth0 type veth peer name veth1
```

Connect veth pair with dockre0 and ovs bridge br-int, set them up, connect veth0 with docker0,
veth1 with openvswitch br-int

```
sudo ovs-vsctl add-port br-int veth1
sudo brctl addif docker0 veth0
sudo ip link set veth1 up
sudo ip link set veth0 up
sudo brctl show
sudo ovs-vsctl show
```

Do the same on host2

```
sudo ovs-vsctl add-br br-int
sudo ip link add veth0 type veth peer name veth1
sudo ovs-vsctl add-port br-int veth1
sudo brctl addif docker0 veth0
sudo ip link set veth1 up
sudo ip link set veth0 up
sudo brctl show
sudo ovs-vsctl show
```

![openvswitch traffic flow](http://docker-k8s-lab.readthedocs.io/en/latest/_images/ovs-gre-docker.png)

# flannel networking

flannel runs an agent, flanneld, on each host and is responsible for allocating a subnet lease out of a preconfigured address space.
flannel uses etcd to store the network configuration, allocated subnets, and auxiliary data (such as host’s IP). 
The forwarding of packets is achieved using one of several strategies that are known as backends. 
The simplest backend is udp and uses a TUN device to encapsulate every IP fragment in a UDP packet, forming an overlay network. 

![flannel traffic flow](http://docker-k8s-lab.readthedocs.io/en/latest/_images/docker-flannel.png)

`wget https://github.com/coreos/flannel/releases/download/v0.6.2/flanneld-amd64 -O flanneld && chmod 755 flanneld`

create flannel config

```
cat > flannel-network-config.json <<EOF
{
    "Network": "10.0.0.0/8",
    "SubnetLen": 20,
    "SubnetMin": "10.10.0.0",
    "SubnetMax": "10.99.0.0",
    "Backend": {
        "Type": "vxlan",
        "VNI": 100,
        "Port": 8472
    }
}
EOF
```

at host1 - set flannel config `./etcdctl set /coreos.com/network/config < flannel-network-config.json`
at host2 - get flannel config `./etcdctl get /coreos.com/network/config | jq .`
start flannel at host1 - `nohup sudo ./flanneld -iface=192.168.205.10 &`

it will create new `flannel.100` interface

```
flannel.100 Link encap:Ethernet  HWaddr 82:53:2e:6a:a9:43
          inet addr:10.15.64.0  Bcast:0.0.0.0  Mask:255.0.0.0
```

now we need to restart docker

```
sudo service docker stop
sudo docker ps
source /run/flannel/subnet.env
sudo ifconfig docker0 ${FLANNEL_SUBNET}
sudo docker daemon --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} &
sudo docker network inspect bridge
```

now we can ping one container from another, on host2

```
sudo docker run -d --name test2  busybox sh -c "while true; do sleep 3600; done"
sudo docker exec test2 ifconfig
          inet addr:10.13.48.2  Bcast:0.0.0.0  Mask:255.255.240.0
```

on host1 we can ping google and container test2 @ host2 

```
sudo docker exec test1 ping google.com
sudo docker exec test1 ping 10.13.48.2
```

as we can see by tcpdump, ping is encapsulated in VXLAN
`sudo tcpdump -i enp0s8 -n not port 2380`


# Docker Calico networking


download calico binary

```
sudo wget -O /usr/local/bin/calicoctl https://github.com/projectcalico/calicoctl/releases/download/v1.6.1/calicoctl
sudo chmod +x /usr/local/bin/calicoctl
```

http://docker-k8s-lab.readthedocs.io/en/latest/docker/docker-etcd.html
