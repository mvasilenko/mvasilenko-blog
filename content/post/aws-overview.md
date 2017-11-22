---
title: "AWS High Level Overview"
date: 2017-09-11T17:58:06+03:00
tag: ["aws", "overview"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
---

### REGIONS and AVAILIBILIY ZONES

**Region** - distinct location within a geographic area designed to provide high availability to a specific geography. Each region is a separate geographic area.
Each region has multiple, isolated locations known as Availability Zones

An **Availability Zone (AZ)** is a distinct location within an AWS Region. Each Region comprises at least two AZs.

### COMPUTING (EC2)

https://cloudacademy.com/blog/aws-ami-hvm-vs-pv-paravirtual-amazon/
HVM (hardware virtual machine)- modern type of virtualization, recommended now,
PV (paravirtualization) -  older than HVM, you need a region-specific kernel object for each Linux instance for PV VM, .

##### AMI
To get ami id, you can search Amazon Marketplace https://aws.amazon.com/marketplace/
or use Ubuntu images catalog http://cloud-images.ubuntu.com/locator/ec2/


### NETWORK
A Virtual Private Cloud (VPC) is a virtual network dedicated to a single AWS account. It is logically isolated from other virtual networks in the AWS cloud,
providing compute resources with security and robust networking functionality. 

### DATABASE and STORAGE related services

##### RDS
Amazon RDS offers the following database engines: SQL, MySQL, MariaDB, PostgreSQL, Aurora, and Oracle

##### S3
S3 is object storage built to store and retrieve any amount of data from anywhere – web sites and mobile apps, corporate applications, and data from IoT sensors or devices.

##### Glacier
Glacier service - best choice for long term data archival.

##### DynamoDB
DynamoDB is AWS No-SQL database service.

##### DMS
AWS Database Migration Service (DMS) can migrate your data to and from most widely used commercial and open-source databases such as Oracle,
PostgreSQL, Microsoft SQL Server, Amazon Redshift, Amazon Aurora, Amazon DynamoDB, Amazon S3, MariaDB, and MySQL. 

##### EMR
Amazon EMR is a web service that makes it easy to process large amounts of data efficiently.

##### Storage Gateway
AWS Storage Gateway is a hybrid storage service that enables your on-premises applications to seamlessly use storage in the AWS Cloud.

##### Snowball
Snowball is a petabyte-scale data transport solution that uses secure appliances to transfer large amounts of data into and out of the AWS cloud.

### MONITORING
CloudWatch can be used to monitor the performance of your EC2 instances (including metrics such as CPU Utilization, Disk IO, etc.

**Trusted Advisor** - automated service that will scan your AWS environment with the goal of both improving security and reducing costs,
it will provide real time guidance to help you provision your resources following AWS best practices.

### *-as-a service

##### Lambda
Lambda is the AWS Function-as-a-Service (FaaS) offering that lets you run code without provisioning or managing servers.

##### Elastic Beanstalk

**Elastic Beanstalk vs CloudFormation**
Elastic Beanstalk automatically handles the deployment of your code -- from capacity provisioning, load balancing, auto-scaling to application health
monitoring -- based on the code you upload to it, whereas CloudFormation is an automated provisioning engine designed to deploy entire cloud environments via a JSON script.

https://stackoverflow.com/questions/14422151/what-is-the-difference-between-elastic-beanstalk-and-cloudformation-for-a-net-p

> They're actually pretty different. Elastic Beanstalk is intended to make developers' lives easier. CloudFormation is intended to make systems engineers' lives easier.

> Elastic Beanstalk is a PaaS-like layer ontop of AWS's IaaS services which abstracts away the underlying EC2 instances, Elastic Load Balancers, auto scaling groups, etc.
> This makes it a lot easier for developers, who don't want to be dealing with all the systems stuff, to get their application quickly deployed on AWS.
> It's very similar to other PaaS products such as Heroku, EngineYard, Google App Engine, etc. With Elastic Beanstalk, you don't need to understand how any of the underlying magic works.

> CloudFormation, on the other hand, doesn't automatically do anything. It's simply a way to define all the resources needed for deployment in a huge JSON file.
> So a CloudFormation template might actually create two ElasticBeanstalk environments (production and staging), a couple of ElasticCache clusters,
> a DynamoDB table, and then the proper DNS in Route53. I then upload this template to AWS, walk away, and 45 minutes later everything is ready and waiting.
> Since it's just a plain-text JSON file, I can stick it in my source control which provides a great way to version my application deployments.
> It also ensures that I have a repeatable, "known good" configuration that I can quickly deploy in a different region.

### Configuration Management

AWS OpsWorks is a configuration management service that uses Chef, an automation platform that treats server configurations as code. 


### Audit, Logging and Analysis
AWS **CloudTrail** is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account.
Good choice when you need to supply auditors with logs showing which Users provisioned given resources on your AWS infrastructure.

Amazon **QuickSight** is a fast, cloud-powered business analytics service that makes it easy to build visualizations, perform ad-hoc analysis, and quickly get business insights from your data.
This service can be used to aggregate your data from multiple data sources (S3, DynamoDB, RDS, etc.) and provide business intelligence based on this data.


### MISC
Amazon WorkSpaces is a fully managed, secure Desktop-as-a-Service (DaaS) solution that runs on AWS. 

Elastic Transcoder service can be used to convert its media files to formats that can be viewed on a variety of devices.

Amazon EFS (Elastic File System) provides simple, scalable file storage for use with Amazon EC2 instances.
It connects an on-premise software appliance (or virtual machine) with cloud based storage.
