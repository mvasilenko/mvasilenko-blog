---
title: "Simple examples of using aws cli"
date: 2017-09-27T17:53:31+03:00
tag: ["aws", "cli"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
draft: yes
---

Some simple examples of using AWS cli interfaces

List AMIs (images) owned by my account, and delete image with given id

```
aws ec2 describe-images --owners self --query Images[].ImageId[] --output=text
aws ec2 deregister-image  --image-id ami-6058xxxx
```


List snapshots owned by my account, and delete snapshot with given id

```
aws ec2 describe-snapshots --owner-ids self --query Snapshots[].SnapshotId[] --output=text
aws ec2 delete-snapshot --snapshot-id snap-0a96c5ae0dxxxxxx
```

List my S3 buckets, remove some of them

```
aws s3 ls
aws s3api list-buckets --query Buckets[].Name[] --output=text
```


List EC2 running instances

```
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --filters Name=instance-state-name,Values=running --output text
name_tag=mongodb
aws ec2 describe-instances --filter "Name=tag-key,Values=Name" "Name=tag-value,Values=*$name_tag*" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value[],NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress]" --output text
```

