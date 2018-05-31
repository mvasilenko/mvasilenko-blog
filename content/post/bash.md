---
title: "BASH tricks"
date: 2017-09-11T17:58:06+03:00
tag: ["bash", "linux"]
categories: ["bash"]
topics: ["bash"]
draft: false
banner: "banners/bash.png"
---


# check is variable is set

if [ -z ${REPO_PATH+x} ]; then REPO_PATH=$(pwd); fi

