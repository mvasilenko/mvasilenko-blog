---
title: "Kubernetes notes"
date: 2017-10-10T11:53:31+03:00
draft: true
tag: ["kubernetes", "networking"]
categories: ["kubernetes"]
topics: ["kubernetes"]
banner: "banners/kubernetes.png"
---


KUBERNETES CONCEPTS

Pod - container group, which can share

* network namespaces
* volumes
* underlying hardware

![Kubernetes architecture](https://cdn.yongbok.net/ruo91/architecture/k8s/v1.1/kubernetes_architecture.png)




* NETWORKING

http://101-lab-kubernetes.readthedocs.io/en/latest/getting-started/getting-started-kubernetes-networking.html

Kubernetes assumes that pods can communicate with other pods, regardless of which host they land on.
We give every pod its own IP address so you do not need to explicitly create links between pods and
you almost never need to deal with mapping container ports to host ports. NO DOCKER PORT MAPPING AGAIN.

* DOCKER NETWORKING MODEL

Default docker networking model - virtual bridge docker0, one veth (eth0 inside in the ontatiner) + one private /24 subnet per container.
Visibility is limited to the docker host machine.

* KUBERNETES NETWORKING MODEL

Requierements  

* no NAT between containers
* no NAT between containers and nodes
* IP that container seed is the same as everyone others see

To meet those requirements, overlay network is needed.

* KUBERNETES SERVICE

K8s service is a REST object, defines logical set of pods, and policy by which to access them.



```
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "my-service"
    },
    "spec": {
        "selector": {
            "app": "MyApp"
        },
        "ports": [
            {
                "protocol": "TCP",
                "port": 80,
                "targetPort": 9376
            }
        ]
    }
}
```