---
title: "AWS S3"
date: 2017-09-12T17:53:31+03:00
tag: ["aws", "s3"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
---

AWS S3 - object based storage, file size is from 0 bytes up to 5TB, total size in unlimited, files stored in buckets (folders). Default limit - 100 buckets per account.
AWS S3 namespace is global, so S3 bucket name must be unique globally. 

Each bucket has URL - `https://s3-eu-west-1.amazonaws.com/your-s3-bucket-name`
When you uploading file, upload must finish with 200 OK code. Buckets are private by default. Access requests logging can be configured, destination - another bucket.
Uploading file with size >5GB MUST be split in different chunks (amazon recommends start splitting for files with >100MB size), application must use multipart upload.


Storage Tiers/Classes

* S3 designed to 99.999% availibility, AWS gives 99.9% availibility, and 11 9's durability. Data can survive the loss of 2 facilities concurrently.
* S3 IA (infrequent accessed) - for less frequent accessed data, cheaper, will charge retrival fee
* Reduced Reduncancy Store (RRS) - 99.99% durability and 99.99% availibility of objects over given year, for easylibe reproducible data, like thumbnails
* Glacier - very cheap, but used for archival only, it takes 3-5 hours to restore from Glacier

![S3 storage classes comparison](/aws-s3-storage-classes-compare.png)

AWS supports versioning, encryption, tiered storage and lifecycle management, you can use ACLs and Bucket Policies to secure your data.
Versioning stores all versions of an object. You can enable versioning's MFA delete capability as additional security layer.
Versioning can be used with lifecycle management.

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
* data transfer
* transfer acceleration (CDN CloudFront)

S3 FAQ
https://aws.amazon.com/s3/faqs/

S3 bucket versioning can be enabled, and after that, it CANNOT be disabled, to disable, you must create new bucket and move content to it.
File stored with versions, deleted files last version stored as delete markers. To restore the file, just delete the delete marker, and file will be back.

Ñross-region for a bucket will apply ONLY to new files and new file versions.
If you delete specific object version or delete marker, this will not be replicated to other regions.
Deletion of object however will be replicated to other region.
AWS will allow to setup daisy chain replication, but will NOT replicate the replica.

detailed info http://docs.aws.amazon.com/AmazonS3/latest/dev/crr-what-is-isnot-replicated.html

Lifecycle rule - change from standard storage class to the Infrequent Access, then from S3-IA to Glacier.
S3-IA minumum object size is 128kb. Smaller objects will not be transitioned to the S3-IA.
Minimum storage duration is 30 days. Object must be stored at least 30 days to be transitioned to the S3-IA from standard storage class.

https://docs.aws.amazon.com/AmazonS3/latest/dev/lifecycle-transition-general-considerations.html


**S3 Encryption**

* in transit (SSL/TLS)
* at rest
  * server side encryption
    * S3 managed keys - SSE-S3 AES-256
    * AWS key management service, managed keys, separate permition for keys, keys usage logging SSE-KMS
    * customer provided keys - SSE-C
* client side encryption


**S3 transfer acceleration** - utilizes CloudFront edge location network to accelerate uploads to S3, instead of uploading directly to S3,
you can use distinct URL for uploading - yourbucketname.s3-accelerate.amazonaws.com. Speed need to be tested first.

