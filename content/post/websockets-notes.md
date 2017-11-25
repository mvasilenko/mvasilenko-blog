---
title: "WebSocket notes"
date: 2017-11-15T11:53:31+03:00
draft: false
tag: ["websockets", "html5"]
categories: ["protocols"]
topics: ["standarts"]
banner: "banners/websockets.png"
---


Websockets are upgraded HTML connections

Client sends 


```
GET /mychat HTTP/1.1
Host: server.example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==
Sec-WebSocket-Protocol: chat
Sec-WebSocket-Version: 13
Origin: http://example.com
```


Server replies:


```
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=
Sec-WebSocket-Protocol: chat
```

and keeps connection alive


# Apache support

The new version 2.4 of Apache HTTP Server has a module called mod_proxy_wstunnel which is a websocket proxy.

http://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html

	
You need to enable mod_proxy and mod_proxy_wstunnel modules and
add `ProxyPass /wss2/ ws://YOUR_DOMAIN:WS_PORT/` in `httpd.conf` file.


Use secured scheme w/o port number url in JS call (e.g. `var ws = new WebSocket("wss://YOUR_DOMAIN/wss2/NNN")`;


