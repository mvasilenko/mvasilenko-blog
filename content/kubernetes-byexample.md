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

Deploy replication controller - `oc create -f rc.yaml`

'''yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rcex
spec:
  replicas: 1
  selector:
    app: sise
  template:
    metadata:
      name: somename
      labels:
        app: sise
    spec:
      containers:
      - name: sise
        image: mhausenblas/simpleservice:0.5.0
        ports:
        - containerPort: 9876
'''

List rc, scale it up or down

```
oc get rc

NAME      DESIRED   CURRENT   READY     AGE
rcex      1         1         1         7h

oc get pods --show-labels

NAME           READY     STATUS        RESTARTS   AGE       LABELS
rcex-jw9kq     1/1       Running       0          7h        app=sise


```

the supervised pod got a random name assigned (rcex-jw9kq)
the way the RC keeps track of its pods is via the label, here app=sise


Scale pod - `kubectl scale --replicas=3 rc/rcex`

# Replica Sets and Deployments

Replica sets - supports set-based selectors, they used in deployments.
Deployment - supervisor for pods and replica sets

Deploy deployment - `oc create -f d09.yaml`

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: sise-deploy
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: sise
    spec:
      containers:
      - name: sise
        image: mhausenblas/simpleservice:0.5.0
        ports:
        - containerPort: 9876
        env:
        - name: SIMPLE_SERVICE_VERSION
          value: "0.9"
```

List deployments, replica sets, pods

```bash
oc get deploy

NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
sise-deploy   2         2         2            2           5m

oc get rs

NAME                     DESIRED   CURRENT   READY     AGE
sise-deploy-2336895107   2         2         2         5m


oc get pods

NAME                           READY     STATUS    RESTARTS   AGE
sise-deploy-2336895107-78lrn   1/1       Running   0          6m
sise-deploy-2336895107-fl6pt   1/1       Running   0          6m
```


Deploy new version - `oc apply -f d10.yaml`

```yaml
-          value: "0.9"
+          value: "1.0"
```

Or you can edit existing deployment - `oc edit deploy/sise-deploy`
This will terminate current rs, and create new one.

Get deployment status - `oc rollout status deploy/sise-deploy`

Get deployment history - `oc rollout history deploy/sise-deploy`


# Services

Service - abstraction for pods with known virtual IP.
Mapping between this virtual IP and pods - `kube-proxy` job,
it's queries API server to learn new services

Let's deploy pod supervised by RC and service with it

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rcsise
spec:
  replicas: 1
  selector:
    app: sise
  template:
    metadata:
      name: somename
      labels:
        app: sise
    spec:
      containers:
      - name: sise
        image: mhausenblas/simpleservice:0.5.0
        ports:
        - containerPort: 9876
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: simpleservice
spec:
  ports:
    - port: 80
      targetPort: 9876
  selector:
    app: sise
```

List pods

```bash
oc get pods -l app=sise

NAME           READY     STATUS    RESTARTS   AGE
rcsise-3fcq7   1/1       Running   0          18s

oc describe pod rcsise-3fcq7

Name:           rcsise-3fcq7
Namespace:      myproject
Node:           localhost/192.168.64.3
Start Time:     Sat, 18 Nov 2017 23:45:08 +0200
Labels:         app=sise
                openshift.io/scc=restricted
Status:         Running
IP:             172.17.0.2
Created By:     ReplicationController/rcsise
Controlled By:  ReplicationController/rcsise
Containers:
  sise:
```

And list service

```
oc get svc
NAME            CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
simpleservice   172.30.216.99   <none>        80/TCP    2m

oc describe service simpleservice

Name:			simpleservice
Namespace:		myproject
Labels:			<none>
Annotations:		<none>
Selector:		app=sise
Type:			ClusterIP
IP:			172.30.216.99
Port:			<unset>	80/TCP
Endpoints:		172.17.0.2:9876
Session Affinity:	None
Events:			<none>
```

The magic behind redirecting traffic from port 80 to the pods handled by iptables, `minishift ssh`
and `iptables-save|grep simpleservice`

```
-A KUBE-SEP-DVOB42PEHF6XJKSN -s 172.17.0.2/32 -m comment --comment "myproject/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-DVOB42PEHF6XJKSN -p tcp -m comment --comment "myproject/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.2:9876
-A KUBE-SERVICES -d 172.30.216.99/32 -p tcp -m comment --comment "myproject/simpleservice: cluster IP" -m tcp --dport 80 -j KUBE-SVC-PLOTDLD225X3K5YY
-A KUBE-SVC-PLOTDLD225X3K5YY -m comment --comment "myproject/simpleservice:" -j KUBE-SEP-DVOB42PEHF6XJKSN
```

If we scale rc to 2 nodes, kube-proxy will add corresponding firewall rules, for balancing

```
sudo iptables-save|grep simpleser

-A KUBE-SEP-DVOB42PEHF6XJKSN -s 172.17.0.2/32 -m comment --comment "myproject/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-DVOB42PEHF6XJKSN -p tcp -m comment --comment "myproject/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.2:9876
-A KUBE-SEP-WQDO6OM23WV335JC -s 172.17.0.3/32 -m comment --comment "myproject/simpleservice:" -j KUBE-MARK-MASQ
-A KUBE-SEP-WQDO6OM23WV335JC -p tcp -m comment --comment "myproject/simpleservice:" -m tcp -j DNAT --to-destination 172.17.0.3:9876
-A KUBE-SERVICES -d 172.30.216.99/32 -p tcp -m comment --comment "myproject/simpleservice: cluster IP" -m tcp --dport 80 -j KUBE-SVC-PLOTDLD225X3K5YY
-A KUBE-SVC-PLOTDLD225X3K5YY -m comment --comment "myproject/simpleservice:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-DVOB42PEHF6XJKSN
-A KUBE-SVC-PLOTDLD225X3K5YY -m comment --comment "myproject/simpleservice:" -j KUBE-SEP-WQDO6OM23WV335JC
```

# Service discovery

Let's create some pods supervised by RC and service

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rcsise
spec:
  replicas: 2
  selector:
    app: sise
  template:
    metadata:
      name: somename
      labels:
        app: sise
    spec:
      containers:
      - name: sise
        image: mhausenblas/simpleservice:0.5.0
        ports:
        - containerPort: 9876
```

'''yaml
apiVersion: v1
kind: Service
metadata:
  name: thesvc
spec:
  ports:
    - port: 80
      targetPort: 9876
  selector:
    app: sise
```

Next, we want to connect to the `thesvc` service from within the cluster,
from another service, let's create jump pod for that.

'''yaml
apiVersion:   v1
kind:         Pod
metadata:
  name:       jumpod
spec:
  containers:
  - name:     shell
    image:    centos:7
    command:
      - "bin/bash"
      - "-c"
      - "sleep 10000"
'''

Exec into it and ping thesvc by `oc exec jumpod -c shell  -it -- ping -c1 thesvc`

```
PING thesvc.myproject.svc.cluster.local (172.30.160.167) 56(84) bytes of data.
```

Also you can try to access the service from the pod

```
oc exec jumpod -c shell  -it -- curl thesvc/info

{"host": "thesvc", "version": "0.5.0", "from": "172.17.0.4"}
```

# Namespaces

```
oc get ns

NAME              STATUS    AGE
default           Active    8h
kube-public       Active    8h
kube-system       Active    8h
myproject         Active    8h
openshift         Active    8h
openshift-infra   Active    8h
```

You can create namespace - `oc create -f ns.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: test
```

You can deploy pods with the same names in different namespaces, or hard-code namespace in yaml - 
`oc create -f pod-ns.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: podintest
  namespace: test
```

```bash
oc get pods --namespace=test

NAME        READY     STATUS    RESTARTS   AGE
podintest   1/1       Running   0          4s
```


