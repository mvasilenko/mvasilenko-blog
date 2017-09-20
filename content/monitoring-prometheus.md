---
title: "Prometheus monitoring system"
date: 2017-09-20T17:53:31+03:00
tag: ["prometheus", "monitoring"]
categories: ["monitoring"]
topics: ["monitoring"]
banner: "banners/prometheus.png"
draft: false
---

https://prometheus.io/docs/introduction/getting_started/

Prometheus - open-source monitoring system, developed by SoundCloud, written in Go, consists of:

* the main Prometheus server which scrapes and stores time series data
* client libraries for instrumenting application code
* a push gateway for supporting short-lived jobs
* special-purpose exporters (for HAProxy, StatsD, Graphite, etc.)
* an alertmanager
* various support tools

![Prometheus architecture](/prometheus-architecture.svg)

[Download latest release](https://prometheus.io/download)

Extract it `tar zxvf prometheus-* ; cd prometheus-*` 

Config file - `prometheus.yml`, by default Prometheus will monitor itself.

Run `./prometheus --config.file=prometheus.yml`

Metrics can be viewed at `http://your.host.ip:9090`

Now we can add some targets:

```
# Fetch the client library code and compile example.
git clone https://github.com/prometheus/client_golang.git
cd client_golang/examples/random
go get -d
go build

# Start 3 example targets in separate terminals:
./random -listen-address=:8080 &
./random -listen-address=:8081 &
./random -listen-address=:8082 &

```

Now we have three targets at 8080, 8081, 8082 ports, which can be checked by running

`curl -s localhost:8081/metrics | head`

Add the job description to the end of `prometheus.yml`, check for indent

```
  - job_name:       'example-random'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
```

Restart prometheus with new config, and verify new metrics `rpc_durations_seconds` are available.

Graphing `avg(rate(rpc_durations_seconds_count[5m])) by (job, service)`
will plot per-second rate of example RPCs (rpc_durations_seconds_count) averaged over all instances
(but preserving the job and service dimensions) as measured over a window of 5 minutes.

### MONITORING THE HOST

Add [node_exporter](https://github.com/prometheus/node_exporter) - exporter for hardware and OS metrics exposed by *NIX kernels

```
cd
cd go
go get github.com/prometheus/node_exporter
cd ${GOPATH-$HOME/go}/src/github.com/prometheus/node_exporter
make
./node_exporter
```
By default it will listen port 9100. Config file

```
  - job_name: "node"
    static_configs:
      - targets: ['localhost:9100']
        labels:
          group: 'node'
```

### CUSTOM METRICS

To record the time series resulting from this expression into a new metric called `job_service:rpc_durations_seconds_count:avg_rate5m`,
create a file with the following recording rule and save it as `prometheus.rules`:

```
job_service:rpc_durations_seconds_count:avg_rate5m = avg(rate(rpc_durations_seconds_count[5m])) by (job, service)
```

Custom new metric rule taking data from node_exporter in :

```
instance:node_cpus:count = count(node_cpu{mode="idle"}) without (cpu,mode)
```

Update rules to new format by running `./promtool update rules prometheus.rules` it will generate rules in new format `prometheus.rules.yml`

```
groups:
- name: prometheus.rules
  rules:
  - record: job_service:rpc_durations_seconds_count:avg_rate5m
    expr: avg(rate(rpc_durations_seconds_count[5m])) BY (job, service)
  - record: instance:node_cpus:count
    expr: count(node_cpu{mode="idle"}) WITHOUT (cpu, mode)
```

                                                                    
Uncomment rules filename in `rule_files` section in config file `prometheus.yml` and restart prometheus

```
rule_files:
  - 'prometheus.rules.yml'
```

