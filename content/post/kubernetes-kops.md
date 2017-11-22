---
title: "Kubernetes on AWS using KOPS"
date: 2017-10-13T11:53:31+03:00
draft: true
tag: ["kubernetes", "networking"]
categories: ["kubernetes"]
topics: ["kubernetes"]
banner: "banners/kubernetes.png"
---


# KUBERNETES on AWS using KOPS

https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/

# setup

choose aws cli profile

`export AWS_PROFILE=your_profile`

set env variables

```bash
# Must change: Your domain name that is hosted in AWS Route 53
export DOMAIN_NAME="xalab.tk"

# Friendly name to use as an alias for your cluster
export CLUSTER_ALIAS="k8s"

# Leave as-is: Full DNS name of you cluster
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"

# AWS availability zone where the cluster will be created
export CLUSTER_AWS_AZ="us-east-1a"
```

create aws route53 hosted zone

`aws route53 create-hosted-zone --name $DOMAIN_NAME --caller-reference 1`

set env variable
```
export DOMAIN_NAME_ZONE_ID=$(aws route53 list-hosted-zones | \
jq -r '.HostedZones[] |
select (.Name="'${DOMAIN_NAME}'.") |
 .Id' |
 sed 's/\/hostedzone\///')
```

create s3 bucket for storage

`aws s3 mb s3://storage.$DOMAIN_NAME`

`export KOPS_STATE_STORE=s3://storage.$DOMAIN_NAME`

create cluster

```
kops create cluster \
    --name=${CLUSTER_FULL_NAME} \
    --zones=${CLUSTER_AWS_AZ} \
    --master-size="t2.medium" \
    --node-size="t2.medium" \
    --node-count="2" \
    --dns-zone=${DOMAIN_NAME} \
    --ssh-public-key="~/.ssh/id_rsa.pub" \
    --kubernetes-version="1.7.6"

kops edit cluster ${CLUSTER_FULL_NAME}

kops update cluster k8s.xalab.tk --yes
```


```
kubectl config set-context ${CLUSTER_ALIAS} --cluster=${CLUSTER_FULL_NAME} \
        --user=${CLUSTER_FULL_NAME}

kubectl config use-context ${CLUSTER_ALIAS}
```

```
kubectl get nodes

NAME                            STATUS     ROLES     AGE       VERSION
ip-172-20-37-99.ec2.internal    NotReady   node      18s       v1.7.6
ip-172-20-38-32.ec2.internal    Ready      master    2m        v1.7.6
ip-172-20-46-100.ec2.internal   NotReady   node      18s       v1.7.6

kubectl get pods --namespace=kube-system

NAME                                                   READY     STATUS              RESTARTS   AGE
dns-controller-1829267247-kcmzn                        1/1       Running             0          2m
etcd-server-events-ip-172-20-38-32.ec2.internal        1/1       Running             0          1m
etcd-server-ip-172-20-38-32.ec2.internal               1/1       Running             0          1m
kube-apiserver-ip-172-20-38-32.ec2.internal            1/1       Running             0          1m
kube-controller-manager-ip-172-20-38-32.ec2.internal   1/1       Running             0          1m
kube-dns-1311260920-9rx48                              0/3       ContainerCreating   0          2s
kube-dns-1311260920-bd652                              0/3       ContainerCreating   0          2m
kube-dns-autoscaler-1818915203-hjq33                   1/1       Running             0          2m
kube-proxy-ip-172-20-38-32.ec2.internal                1/1       Running             0          1m
kube-scheduler-ip-172-20-38-32.ec2.internal            1/1       Running             0          1m
```

# change cluster configuration

`kops edit ig nodes`

# prepare node for maintenance

```
kubectl run test-deployment --image=nginx --replicas=8
kubectl get pods -o wide

NAME                               READY     STATUS    RESTARTS   AGE       IP           NODE
test-deployment-1791490673-53hnr   1/1       Running   0          17s       100.96.1.5   ip-172-20-46-100.ec2.internal
test-deployment-1791490673-7kr6b   1/1       Running   0          17s       100.96.2.4   ip-172-20-37-99.ec2.internal
test-deployment-1791490673-84htv   1/1       Running   0          17s       100.96.2.3   ip-172-20-37-99.ec2.internal
test-deployment-1791490673-cph26   1/1       Running   0          17s       100.96.2.5   ip-172-20-37-99.ec2.internal
test-deployment-1791490673-cq92m   1/1       Running   0          17s       100.96.1.6   ip-172-20-46-100.ec2.internal
test-deployment-1791490673-f3rfn   1/1       Running   0          17s       100.96.1.7   ip-172-20-46-100.ec2.internal
test-deployment-1791490673-pr9f6   1/1       Running   0          17s       100.96.1.4   ip-172-20-46-100.ec2.internal
test-deployment-1791490673-q9bxg   1/1       Running   0          17s       100.96.2.6   ip-172-20-37-99.ec2.internal
```

drain the node

```
kubectl drain ip-172-20-46-100.ec2.internal

node "ip-172-20-46-100.ec2.internal" cordoned
error: pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): kube-proxy-ip-172-20-46-100.ec2.internal

kubectl drain ip-172-20-46-100.ec2.internal --force

node "ip-172-20-46-100.ec2.internal" already cordoned
WARNING: Deleting pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet: kube-proxy-ip-172-20-46-100.ec2.internal
pod "kube-dns-autoscaler-1818915203-hjq33" evicted
pod "test-deployment-1791490673-cq92m" evicted
pod "test-deployment-1791490673-f3rfn" evicted
pod "test-deployment-1791490673-pr9f6" evicted
pod "test-deployment-1791490673-53hnr" evicted
pod "kube-dns-1311260920-9rx48" evicted
node "ip-172-20-46-100.ec2.internal" drained
```

# install dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml

kubectl proxy &

kubectl -n kube-system get secret|grep dashboard

kubernetes-dashboard-token-p1frp         kubernetes.io/service-account-token   3         17m

kubectl -n kube-system describe secret kubernetes-dashboard-token-p1frp
Name:         kubernetes-dashboard-token-p1frp
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=kubernetes-dashboard
              kubernetes.io/service-account.uid=e92738e4-cd43-11e7-8eaf-0af77b7d5876

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1046 bytes
namespace:  11 bytes
token: xxxx
```

now login to following url using token xxxx

`http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`


# Login to kuberbetes dashboard

```
kubectl -n kube-system get secret|grep deploy

deployment-controller-token-3q62k        kubernetes.io/service-account-token   3         2d

kubectl -n kube-system describe secret deployment-controller-token-3q62k

Name:         deployment-controller-token-3q62k
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=deployment-controller
              kubernetes.io/service-account.uid=94898f69-cd3e-11e7-9877-0a8b69352f64

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1046 bytes
namespace:  11 bytes
token:      xx
```

# get dns zone id

get dns zone id

```
aws route53 list-hosted-zones | \
jq -r '.HostedZones[] | \
select (.Name="'${DOMAIN_NAME}'.") | \
 .Id' | \
 sed 's/\/hostedzone\///'

# change dns records

```
aws route53 change-resource-record-sets \
    --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} \
    --change-batch file://dns-record-single.json
```

dns-record-single.json itself

```json
{
  "Comment": "Create/Update a CNAME record for a standalone Deployment",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "site.yourdomain",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "x.x.x.x"
          }
        ]
      }
    }
  ]
}
```

# create deployment and service

deployment yaml file - deploy image from docker hub

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: your-app
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: your-app
    spec:
      containers:
        - name: your-app
          image: docker-login/your-app:latest
          ports:
            - containerPort: 80
```

service yaml file - create LoadBalancer in the cloud


```yaml
apiVersion: v1
kind: Service
metadata:
  name: your-app-svc
  labels:
    app: your-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: your-app
```
