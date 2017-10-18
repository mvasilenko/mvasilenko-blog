---
title: "AWS Lambda"
date: 2017-09-15T17:53:31+03:00
tag: ["aws", "serverless", "lambda"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
draft: true
---

Lambda - AWS service that runs your code on top of the underlying Amazon cloud infrastructure,
abstracting you from the resource provisioning, monitoring and scaling. Event driven.
Maximum execution time is 300sec, maximum deployment package size is 50MB, non-persistent scratch area
available for your code to use - 500MB.

Lambda is stateless, persistent data must be stored at DynamoDB or RDS. Lambda writes logs to CloudWatch.


# Static site hosting

`aws s3 sync s3://wildrydes-us-east-1/WebApplication/1_StaticWebHosting/website s3://YOUR_BUCKET_NAME --region YOUR_BUCKET_REGION`