---
title: "AWS S3"
date: 2017-09-12T17:53:31+03:00
tag: ["aws", "s3"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
---

AWS S3 - object based storage, file size is up to 5TB, total size in unlimited, files stored in buckets (folders). AWS S3 namespace is global,
so S3 bucket name must be unique globally. Each bucket has URL - `https://s3-eu-west-1.amazonaws.com/your-s3-bucket-name`
When you uploading file, upload must finish with 200 OK code.

Storage Tiers/Classes

* S3 designed to 99.999% availibility, AWS gives 99.9% availibility, and 11 9's durability. Data can survive the loss of 2 facilities concurrently.
* S3 IA (infrequent accessed) - for less frequent accessed data, cheaper, will charge retrival fee
* Reduced Reduncancy Store - 99.99% durability and 99.99% availibility of objects over given year.
* Glacier - very cheap, but used for archival only, it takes 3-5 hours to restore from Glacier

![S3 tieres comparison](/awscompare.png)

AWS supports versioning, encryption, tiered storage and lifecycle management, you can use ACLs and Bucket Policies to secure your data.

AWS S3 data consistency model:

* Read after Write consistency for PUTS of new Objects
* Eventual consistency for overwrite PUTS and DELETES (can take some time to propagate)

In other words, when you write new object to S3, you can immediately read it back, when you deleting or updating existing object,
it can take some time.

Object consist of:

* Key (name of the object)
* Value (the data or byte sequence)
* Version ID
* Metadata (last update time, for example)
* Subresources
  * Access Control Lists
  * Torrent (S3 supports bittorent protocol)

S3 charges for:

* storage
* requests
* storage management pricing (tags to track costs)
