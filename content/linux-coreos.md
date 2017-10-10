---
title: "IP packet flow in CoreOS using Flannel"
date: 2017-10-10T11:53:31+03:00
draft: true
tag: ["linux", "kernel", "ip", "networking", "coreos", "flannel"]
categories: ["networking"]
topics: ["networking"]
#banner: "banners/linux.png"
---


CoreOS - lightweight linux distro, gentoo based, distributed key/value store (etcd) at the core, read-only root, writeable /etc.
All services runs in containers.



docker containers --on-top-of-the-> etcd + docker --on-top-of-the-> host

Flannel basics - one /24 per host machine, no docker port mapping, containers reach other through IP,
peer network configs are stored in etcd, packets encapsulated using UDP / VxLAN (RFC3448).
VxLAN header - 8 bytes, 24 bits used for VNI (just like 802.1q)


![IP packet flow between two CoseOs hosts](/coreos-ip-packet-flow-flannel.png)

Flannel creates flannelX interface - X = VNI number, assigns 10.1.RANDOM.0/16 address to that interface
Docker0 interface assignes 10.1.x.1/24 address, leaving .2 - .254 range for containers

