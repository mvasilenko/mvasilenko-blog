---
title: "Use multiple SSH keys at GitHub for work & private accounts"
date: 2018-02-12T17:53:31+03:00
tag: ["git", "development"]
categories: ["development"]
topics: ["development"]
banner: "banners/git.png"
draft: false
---

How to use two SSH keys, different for work and private
GitHub accounts


Edit `~/.ssh/config`

```shell script
#work account
Host github.com-work
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_rsa-work

#private account for GitHub user username
Host github.com-username
        HostName github.com
        User username
        IdentityFile ~/.ssh/username-github-key
```

add ssh key to ssh-agent

```shell script
ssh-add ~/.ssh/username-github-key
ssh-add  ~/.ssh/id_rsa_work
ssh-add -l
```

set remote origin in repo

```shell script
git remote set-url origin git@github.com-username:username/repo.git
```

