---
title: "Kubernetes notes"
date: 2017-10-10T11:53:31+03:00
draft: true
tag: ["kubernetes", "openshift"]
categories: ["kubernetes"]
topics: ["kubernetes"]
banner: "banners/kubernetes.png"
---

OpenShift minishift install - `brew cask install minishift`

Run - `minishift start`

Configure oc client - `minishift oc-env; eval $(minishift oc-env)`

Login to the cluster - `oc login -u system:admin`

Launch pod - `oc run sise --image=mhausenblas/simpleservice:0.5.0 --port=9876`

List pods - 

```oc get pods ; oc describe pod sise-3210265840-k705b | grep IP:
IP:                     172.17.0.3
```

SSH into cluster - `minishift ssh`

Get data from deployed service

```
curl 172.17.0.3:9876/info
{"host": "172.17.0.3:9876", "version": "0.5.0", "from": "172.17.0.1"}
```

Deploy pod - `oc create -f pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: twocontainers
spec:
  containers:
  - name: sise
    image: mhausenblas/simpleservice:0.5.0
    ports:
    - containerPort: 9876
```

Exec into container

```
exec twocontainers -c shell -i -t -- bash
[root@twocontainers /]# curl -s localhost:9876/info
{"host": "localhost:9876", "version": "0.5.0", "from": "127.0.0.1"}
```

Deploy constrained pod - `oc create -f constraint-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: constraintpod
spec:
  containers:
  - name: sise
    image: mhausenblas/simpleservice:0.5.0
    ports:
    - containerPort: 9876
    resources:
      limits:
        memory: "64Mi"
        cpu: "500m"
```

# Labels

Deploy pod with labels

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: labelex
  labels:
    env: development
spec:
  containers:
  - name: sise
    image: mhausenblas/simpleservice:0.5.0
    ports:
    - containerPort: 9876
```

List labels - `oc get pods --show-labels`

```
NAME           READY     STATUS    RESTARTS   AGE       LABELS
labelex        1/1       Running   0          6h        env=development
```

Label pod - `oc label pods labelex owner=acid`

List labels again - `oc get pods --show-labels`

```
NAME           READY     STATUS    RESTARTS   AGE       LABELS
labelex        1/1       Running   0          6h        env=development,owner=acid
```

Use label for filtering - list pods that match conditions - `oc get pods --selector owner=acid`

```
NAME      READY     STATUS    RESTARTS   AGE       LABELS
labelex   1/1       Running   0          6h        env=development,owner=acid
```


Option `--selector` can be abbreviated to `-l` - `oc get pods -l env=development`

Let's deploy pod to another environment - `oc create -f anotherpod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: labelexother
  labels:
    env: production
    owner: michael
spec:
  containers:
  - name: sise
    image: mhausenblas/simpleservice:0.5.0
    ports:
    - containerPort: 9876
```

List pods in two environments

```
oc get pods -l 'env in ('production','development')' --show-labels

NAME           READY     STATUS    RESTARTS   AGE       LABELS
labelex        1/1       Running   0          7h        env=development,owner=acid
labelexother   1/1       Running   0          6h        env=production,owner=michael
```


# Replication Controllers


