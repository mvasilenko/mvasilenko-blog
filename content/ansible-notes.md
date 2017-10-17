---
title: "Ansible notes"
date: 2017-09-15T17:53:31+03:00
tag: ["provisioning", "config management", "ansible"]
categories: ["config management"]
topics: ["ansible"]
banner: "banners/ansible.png"
draft: true
---

Ansible check for failed step during executing playbook - 
`when: result|failed` checks if the registered variable `(result)` contains a failed status.

```yaml
- name: Check that our config is valid
  command: apache2ctl configtest
  register: result
  ignore_errors: True

- name: Rolling back - Restoring old default virtualhost
  command: a2ensite 000-default
  when: result|failed
```

`when: result.rc != 0` or `when: result|failed` or `when: result.failed == True` will do the same


Restart apache with ansible

`ansible -i hosts -m service -a 'name=apache2 state=restarted' host1.example.org`


