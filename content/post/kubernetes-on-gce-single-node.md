---
title: "Kubernetes on GCE notes"
date: 2017-10-12T11:53:31+03:00
draft: true
tag: ["kubernetes", "networking"]
categories: ["kubernetes"]
topics: ["kubernetes"]
banner: "banners/kubernetes.png"
---


KUBERNETES on GCE notes

https://github.com/kelseyhightower/kubeadm-single-node-cluster

```
gcloud compute instances create kubeadm-single-node-cluster \
  --can-ip-forward \
  --image-family ubuntu-1704 \
  --image-project ubuntu-os-cloud \
  --machine-type n1-standard-4 \
  --metadata kubernetes-version=stable-1.8 \
  --metadata-from-file startup-script=startup.sh \
  --tags kubeadm-single-node-cluster \
  --scopes cloud-platform,logging-write
```

Enable secure access to API server

```
gcloud compute firewall-rules create default-allow-kubeadm-single-node-cluster \
  --allow tcp:6443 \
  --target-tags kubeadm-single-node-cluster \
  --source-ranges 0.0.0.0/0
```

Fetch kubectl config

```
gcloud compute scp kubeadm-single-node-cluster:/etc/kubernetes/admin.conf \
  kubeadm-single-node-cluster.conf
```

`export KUBECONFIG=${PWD}/kubeadm-single-node-cluster.conf`


Get public IP address and set it in kubectl cluster config

```
kubectl config set-cluster kubernetes \
  --kubeconfig kubeadm-single-node-cluster.conf \
  --server https://$(gcloud compute instances describe kubeadm-single-node-cluster \
     --format='value(networkInterfaces.accessConfigs[0].natIP)'):6443
```

Check cluster status

`kubectl get nodes`


Deploy