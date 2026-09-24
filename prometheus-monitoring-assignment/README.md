# Prometheus Configuration, Exporters & PromQL — Monitoring Assignment

## 1. Overview

This project sets up a small Prometheus monitoring stack on a local machine, using Node Exporter to expose host-level metrics and Prometheus to scrape and query them.

## 2. What is `prometheus.yml`?

`prometheus.yml` is Prometheus's main configuration file. It tells Prometheus **what** to monitor, **how often** to check it, and **how to label** the data it collects. Without it, Prometheus has no targets to scrape and nothing to store. It's the entry point that turns Prometheus from an idle binary into an actual monitoring system.

## 3. Configuration Explanation

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["localhost:9100"]
```

- **`global`** — settings that apply to every job unless a job explicitly overrides them.
- **`scrape_interval`** — how often Prometheus polls each target for fresh metrics. Set to `15s` here, meaning every target is scraped every 15 seconds.
- **`scrape_configs`** — the list of jobs Prometheus should run. Each entry describes one group of targets to scrape.
- **`job_name`** — a logical name for a group of targets. This name is attached as a label (`job="node-exporter"`) to every metric that job scrapes, which is what makes it possible to filter metrics by job later in PromQL.
- **`static_configs`** — a fixed (non-service-discovered) list of targets for a job. Fine for a small local setup like this; in production this is usually replaced with dynamic service discovery.
- **`targets`** — the actual `host:port` endpoints Prometheus scrapes for that job. Prometheus expects a `/metrics` HTTP endpoint at each target.

## 4. Exporter Explanation

**Node Exporter** is a lightweight agent that runs on a host and exposes hardware and OS-level metrics — CPU, memory, disk, filesystem, network — in the text format Prometheus expects, on `localhost:9100/metrics`.

It's used in this assignment because Prometheus itself has no built-in visibility into the machine it's running on. Prometheus only knows how to scrape and store metrics that are already exposed somewhere; Node Exporter's job is to translate raw OS/kernel stats into that scrapeable format so Prometheus has something to actually monitor.

## 5. PromQL Queries

| # | Query | What it shows |
|---|-------|----------------|
| 1 | `up{job="node-exporter"}` | Whether the Node Exporter target is currently reachable and being scraped successfully — `1` means up, `0` means the scrape is failing. |
| 2 | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` | Approximate overall CPU utilization (%) over the last 5 minutes, derived from idle time. |
| 3 | `node_memory_MemAvailable_bytes` | The amount of memory (in bytes) currently available to processes on the machine. |
| 4 | `node_filesystem_avail_bytes{mountpoint="/"}` | Free disk space (in bytes) on the root filesystem. |
| 5 | `node_filesystem_avail_bytes{fstype="ext4"}` | Same free-space metric, filtered using the `fstype` label — demonstrates label-based filtering in PromQL. |



## 6. Screenshots

- **Node Exporter metrics endpoint** — `screenshots/node-exporter.png`
  Shows `localhost:9100/metrics` returning live metrics.

- **Prometheus Targets page** — `screenshots/targets.png`
  Shows both the `prometheus` and `node-exporter` jobs in `UP` state at `localhost:9090/targets`.

- **PromQL query result** — `screenshots/promql.png`
  Shows a successful query (e.g. `up{job="node-exporter"}`) executed in the Prometheus graph/table UI.

## 7. Repository Structure

```
prometheus-monitoring-assignment/
│
├── prometheus.yml
├── README.md
└── screenshots/
    ├── node-exporter.png
    ├── targets.png
    └── promql.png
```

## 8. How to Run This Locally

```bash
# 1. Run Node Exporter
./node_exporter &

# 2. Run Prometheus with this config
./prometheus --config.file=./prometheus.yml

# 3. Confirm targets
open http://localhost:9090/targets

# 4. Run PromQL queries
open http://localhost:9090/graph
```
