+++
date = "2017-08-31"
tags = ["hugo","netlify", "hosting", "blog"]
categories = ["blog"]
topics = ["blog"]
title = "Блог на github + hugo + netlify"
banner = "banners/hugo.png"
+++

### Платформа для блога

Платформа для блога - hugo (генератор статических сайтов) + github (хранение материалов блога) + netlify (хостинг).
Хостинг - бесплатен, SSL-сертификат от Letsencrypt на произвольное имя.
Тема - слегка модифицированная hugo icarus, взята с http://kencochrane.net

### Workflow

Написание нового поста, запускаем локально ```hugo server ``` смотрим как все выглядит в браузере  на ```localhost:1313```,
если устраивает, git add/commit в репозиторий на github, срабатывает hook, netlify обновляет сайт.
