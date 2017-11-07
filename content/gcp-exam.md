---
title: "GCP practice exam"
date: 2017-10-06T17:53:31+03:00
tag: ["gcp", "exam"]
categories: ["gcp"]
topics: ["gcp"]
banner: "banners/gcp.png"
draft: true
---

GCP practice exam

# Storage classes

https://cloud.google.com/storage/docs/storage-classes

*Multi-Regional Storage* - $0.0269 GB/month, 99,95% 
Storing data that is frequently accessed ("hot" objects) around the world, 
such as serving website content, streaming videos, or gaming and mobile applications.

*Regional Storage* - $0.02 GB/month, 99.9%, Lower cost per GB stored, 
Storing frequently accessed in the same region as your Google Cloud DataProc or Google Compute Engine instances that use it,
such as for data analytics.

*Nearline Storage* - $0.01 GB/month, 99.0%, Data retrieval costs, Higher per-operation costs, 30-day minimum storage duration, 
Data you do not expect to access frequently (i.e., no more than once per month). Ideal for back-up and serving long-tail multimedia content.

*Coldline Storage* - $0.007 GB/month, 99.0%, Data retrieval costs, Higher per-operation costs, 30-day minimum storage duration, 
Data you expect to access infrequently (i.e., no more than once per year). 
Typically this is for disaster recovery, or data that is archived and may or may not be needed at some future time.


Google Cloud Datastore is a highly scalable, fully managed NoSQL database

Cloud Bigtable is Google's NoSQL Big Data database service. 

Shared VPC
https://cloud.google.com/compute/docs/shared-vpc/


 
data in sync across Region 1 and Region 2 - Google Cloud Storage

Run current jobs from the current technical environment on Google Cloud Dataproc.

Evaluate and choose an automation framework for provisioning resources in the cloud.

pictures flow
Google Cloud Storage, Google Cloud Pub/Sub, Google Cloud Dataflow


security - use the on-premises scanners to conduct penetration testing on the cloud environments routing traffic over the public internet.


ssh access - Grant the operations engineers access to use Google Cloud Shell.

copy production vm - Create a snapshot of the root disk, create an image file in Google Cloud Storage from the snapshot,
and create a new virtual machine instance in the US-East region using the image file for the root disk.


update instances - Use managed instance groups with the “update-instances” command when starting a rolling update.
