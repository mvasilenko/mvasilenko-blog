---
title: "Windows administration notes"
date: 2017-10-13T11:53:31+03:00
draft: true
tag: ["windows"]
categories: ["windows"]
topics: ["windows"]
#banner: "banners/linux.png"
---


WINDOWS administration notes

Quick fix for "trust relationship between this station and domain" fix

Unplug network, login using domain credentials, plug network, execute in power shell

`Reset-ComputerMachinePassword -Server SERVER-DC -Credential DOMAIN\user`
