---
title: "OpenStack notes"
date: 2018-02-26T11:53:31+03:00
draft: true
tag: ["openstack", "vm"]
categories: ["cloud"]
topics: ["cloud","provisioning"]
banner: "banners/openstack.png"
---

## OpenStack notes

| credential    | env_v         | descr |
| ------------- |:-------------:| -----:|
Authentication URL | OS_AUTH_URL |This typically is the URL of where the Keystone service runs
Region (optional)  | OS_REGION_NAME | If you’re using a cloud with multiple regions, this would need to be specified.
Username  |  OS_USERNAME | The username you’re provided for the OpenStack API.
Password  |  OS_PASSWORD | The password you’re provided for the OpenStack API.
Tenant Name | OS_TENANT_NAME | This is the tenant you’re trying to access, usually it will be provided to you.


working openstack .env

```
export OS_USERNAME=USERNAME
export OS_PASSWORD=PASSWORD
export OS_TENANT_NAME=eu-de
export OS_PROJECT_NAME=eu-de
export OS_USER_DOMAIN_NAME=OTC-EU-DE-00000000001000026559
export OS_AUTH_URL=https://iam.eu-de.otc.t-systems.com:443/v3
export OS_PROJECT_DOMAIN_NAME=
export OS_IDENTITY_API_VERSION=3
export OS_VOLUME_API_VERSION=2
export OS_IMAGE_API_VERSION=2
export OS_ENDPOINT_TYPE=publicURL
export NOVA_ENDPOINT_TYPE=publicURL
export CINDER_ENDPOINT_TYPE=publicURL
```


remove port from router

`neutron port-list -f value|awk '{print $1}'|xargs -I % neutron port-update % --device_owner compute:None`

