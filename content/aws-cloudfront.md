---
title: "AWS Cloudfront"
date: 2017-09-14T17:53:31+03:00
tag: ["aws", "cloudfront"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
draft: true
---

CloudFront is AWS CDN. Edge location - the location where content will be cached. Origin - S3 bucket, EC2 instance, Elastic Load Balancer or Route53.
Distribution - the name given the CDN which consists of a collection of the Edge Locations. Distribution can be web distibution or RTMP.
You can read and write to the edge locations. Objects are cached for the life of the TTL.
