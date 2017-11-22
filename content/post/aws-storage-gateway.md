---
title: "AWS Storage Gateway"
date: 2017-09-15T17:53:31+03:00
tag: ["aws", "storage gateway"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
---

AWS Storage Gateway - virtual appliance, installed in your on-premise hypervisor (esxi or hyper-v).
Four types of storage gateway:

* file gateway (NFS) - for flat files, stored directly on S3
* volume gateway (iSCSI)
  * stored volumes - entire data stored locally, asynchronously backed up to S3
  * cached volumes - entire data stored on S3, frequently accessed is cached on site
* gateway virtual tape library (VTL)


File gateway (gateway-cached volumes)- files are stored as object in your S3 buckets, accessed through NFS, ownership, permissions and timestamps
are stored in S3 used-metadata objects associated with the files. Once the files are transferred to S3, they can be managed
as native S3 object, policies, lifecycle management, cross-region replication rules will apply directly to objects stored
in your bucket.

![file gateway diagram](/aws-file-gateway-diagram.png)

Volume gateway (gateway-stored volumes) - your application have access to disk volume, attached by iSCSI protocol. Data written can be asynchronously backed up
as snapshots of volumes, and stored in cloud as EBS snapshots. Snapshots are incremental backups that capture only changed blocks,
and they are also compressed.

![volume gateway diagram](/aws-volume-gateway-diagram.png)

Stored volumes - stores all data localy on your disks or SAN, anynchronously backing up the data to AWS EBS.

![stored volumes diagram](/aws-storage-gateway-stored-volume-diagram.png)

Cached volumes - retains frequently accessed data locally in your storage gateway, 

![cached volumes diagram](/aws-storage-gateway-cached-volume-diagram.png)

Tape gateway - used for backup, works with popular backup tools

![virtual tape volume diagram](/aws-storage-gateway-tape-volume-diagram.png)

Use Cases - from https://fizalihsan.github.io/technology/aws.html#aws-storage-gateway

Gateway-Cached volumes enable you to expand local storage hardware to S3, allowing you to store much more data without drastically increasing your storage hardware or changing your storage processes.

Gateway-Stored volumes provide seamless, asynchronous, and secure backup of your on-premises storage without new processes or hardware.

Gateway-VTLs enable you to keep your current tape backup software and processes while storing your data more cost-effectively and simply on the cloud.

