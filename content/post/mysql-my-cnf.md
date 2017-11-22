---
title: "MySQL my.cnf"
date: 2017-10-05T11:53:31+03:00
draft: true
tag: ["mysql", "db", "tuning"]
categories: ["db"]
topics: ["mysql"]
banner: "banners/mysql.png"
---

http://www.mysqlperformanceblog.com/2006/09/29/what-to-tune-in-mysql-server-after-installation/

* key_buffer_size - important for MyISAM tables, used for index storage, recommended value - 30% RAM size, needs to be monitored,
watch out for Key_reads / Key_read_requests ratio, with optimal value < 0.01
* innodb_buffer_pool_size - important for InnoDB tables, used for index and data storage, 70-80% RAM size, needs to be monitored
* innodb_additional_mem_pool_size - used for InnoDB internal needs, 20MB is OK
* innodb_log_file_size - important for frequent writes, 64-512MB is OK, when changed, old file needs to be deleted before MySQL restart
* innodb_log_buffer_size - buffer flushes every second, so 8-16MB is OK
* innodb_flush_log_at_trx_commit - default value is 1, every UPDATE will wait for disk buffer sync, 2 = wait for OS cache, 0 - don't wait, fastest
* table_cache (table_open_cache) - cache MyISAM tables, good value = tables count x 10, Opened_tables value = tables opened without cache
* thread_cache - thread pool size, needs to be sufficient, for NOT creating thread on every connection
* query_cache_size - 32-512MB, important for applications without own cache, allocated at MySQL start

Good post with tuning examples

https://habrahabr.ru/post/262623/
