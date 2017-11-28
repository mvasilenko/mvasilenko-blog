---
title: "Kubernetes notes"
date: 2017-11-28T11:53:31+03:00
draft: false
tag: ["kubernetes", "architecture"]
categories: ["kubernetes"]
topics: ["kubernetes"]
banner: "banners/kubernetes.png"
---

the color is red

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

# Under the hood

https://github.com/jamiehannaford/what-happens-when-k8s

# Deployemnts

https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/

* **rolling update** - rollout new release to an existing deployment in serial fashion, pods incrementally updated one at time, if problems detected during rollout, it is possible to pause rollout and rollback deployment to previous state

* **canary deployment** - parallel deployment of a new release to the subset of users, reducing the impact if problems arise

* **blue-green deployment** - parallel deployment of a new release, when all traffic gets instantaneously rerouted to from the existing Deployment, by changing the selector of the associated LoadBalancer service. If problems are detected with the new release, all traffic can be rerouted back to the original Deployment by reverting back to the original selector of the LoadBalancer service.

# K8S on vmware

https://blog.inkubate.io/deploy-kubernetes-on-vsphere-with-kubo/
