---
title: "PostgreSQL notes"
date: 2017-10-05T11:53:31+03:00
draft: true
tag: ["postgres", "db"]
categories: ["db"]
topics: ["postgresql"]
banner: "banners/postgres.png"
---

Some PostgreSQL notes

`\du` show roles


generate random number within 2..3 range with 2 decimal points

`select round( CAST(float8 (random()*2+2) as numeric), 2)`
