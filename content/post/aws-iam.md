---
title: "AWS IAM"
date: 2017-09-12T14:53:31+03:00
tag: ["aws", "iam"]
categories: ["aws"]
topics: ["aws"]
banner: "banners/aws.png"
---

IAM (identity access management) is global service, not per-region. Billing data is stored in us-east-1 Virginia.
New users by default have NO permissions to access anything.

AWS IAM Policy

IAM policy - JSON file, AdministratorAccess policy looks like this:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
```

AWS roles describe the way one AWS service interacts with another


[AWS Security Best Practice white paper](https://d0.awsstatic.com/whitepapers/Security/AWS_Security_Best_Practices.pdf)


IAM account signin URL is different from the Root account signin URL.

PowerUserAccess policy provides full access to AWS services and resources, but does not allow management of Users and groups.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "organizations:DescribeOrganization",
            "Resource": "*"
        }
    ]
}
```

IAM have users, groups, roles. Organizational Units is NOT IAM component