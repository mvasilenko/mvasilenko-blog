---
title: "Flask notes and snippets"
date: 2017-11-03T17:58:06+03:00
tag: ["development", "python", "flask"]
categories: ["development"]
topics: ["python"]
draft: true
banner: "banners/python.png"
---

# UWSGI flask support

`index.uwsgi` file

```
# Import app
from index import app
# Initialize WSGI app object
application = app
```


`nginx.conf`

```
       location /colibri {
        include     uwsgi_params;
        uwsgi_pass  unix:/run/uwsgi/app/colibri/socket;
    }
```


`uwsgi.ini`

```
[uwsgi]
plugins = python3
chmod-socket    = 664
mount = /colibri=index.wsgi
; tell uWSGI to rewrite PATH_INFO and SCRIPT_NAME according to mount-points
manage-script-name = true
pidfile = /run/uwsgi/app/colibri/pid
socket = /run/uwsgi/app/colibri/socket
logto = /var/log/uwsgi/app/app.log

```

# Flask

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
