---
title: "Linux optimization"
date: 2017-10-18T17:58:06+03:00
tag: ["kernel", "linux"]
categories: ["linux"]
topics: ["linux"]
draft: true
banner: "banners/linux.png"
---

# Unresponsive process under VM

```
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
   echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
```
