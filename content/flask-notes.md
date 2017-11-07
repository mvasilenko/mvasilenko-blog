---
title: "Flask notes and snippets"
date: 2017-11-03T17:58:06+03:00
tag: ["development", "python", "flask"]
categories: ["development"]
topics: ["python"]
draft: true
banner: "banners/python.png"
---

```
mkdir app
mkdir app/static
mkdir app/templates
mkdir tmp
```

`app/__init__.py`

```
from flask import Flask

app = Flask(__name__)
from app import views
```
