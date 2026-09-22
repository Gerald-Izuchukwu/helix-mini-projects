# Docker Monitoring

Covers Part 1 (`docker stats`) and Part 2 (cAdvisor) of the lab.

## 1. Containers used

| Container | Image | Purpose | Limits |
|---|---|---|---|
| `nginx-monitor` | `nginx` | Generates network I/O via curl traffic | `--memory=256m` |
| `redis-monitor` | `redis` | Baseline low-usage container | `--memory=256m` |
| `postgres-monitor` | `postgres` | Generates disk I/O via `dd` | `--memory=512m` |
| `cpu-stress` | `alpine` | Generates sustained CPU load | `--cpus=0.5`, `--memory=128m` |

```bash
docker run -d --name nginx-monitor -p 8080:80 --memory=256m nginx
docker run -d --name redis-monitor --memory=256m redis
docker run -d --name postgres-monitor --memory=512m -e POSTGRES_PASSWORD=secret postgres
docker run -d --name cpu-stress --cpus=0.5 --memory=128m alpine sh -c "while true; do :; done"
```

A `--memory` limit was set on every container. Without one, `docker stats`'s `LIMIT` column falls back to the full host memory, which makes the `MEM %` figure meaningless.

## 2. Generating load

**Network I/O** (against `nginx-monitor`):

```bash
for i in $(seq 1 5000); do curl -s localhost:8080 > /dev/null; done
```

**Disk I/O** (against `postgres-monitor`):

```bash
docker exec postgres-monitor sh -c "dd if=/dev/zero of=/tmp/testfile bs=1M count=500 conv=fsync"
```

**CPU** — `cpu-stress` runs a busy loop continuously, so no extra step is needed.

## 3. `docker stats`

```bash
docker stats                       # live view, all containers
docker stats --no-stream           # single snapshot
docker stats nginx-monitor         # single container
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}"
```

Column mapping:

| Requirement | `docker stats` column |
|---|---|
| CPU usage | `CPU %` |
| Memory usage and limit | `MEM USAGE / LIMIT` |
| Memory usage % | `MEM %` |
| Network I/O | `NET I/O` |
| Block (disk) I/O | `BLOCK I/O` |
| Number of processes | `PIDS` |

Screenshots: `../screenshots/docker-stats/` — captured while `cpu-stress` and the curl loop were both active, so the CPU/network columns aren't flat.

## 4. cAdvisor

```bash
docker run -d --name=cadvisor \
  -p 8081:8080 \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:v0.49.1
```

> Mapped to host port `8081` (not the usual `8080`) because `nginx-monitor` was already bound to `8080`.

- Web UI: `http://localhost:8081` → `/containers/` → `/docker/` → click into a container for CPU, memory, network, and filesystem graphs.
- Raw Prometheus-format metrics: `http://localhost:8081/metrics`

Useful metric families to inspect directly:

```bash
curl -s localhost:8081/metrics | grep -E "^container_cpu_usage_seconds_total" | head
curl -s localhost:8081/metrics | grep -E "^container_memory_usage_bytes" | head
curl -s localhost:8081/metrics | grep -E "^container_network_receive_bytes_total" | head
curl -s localhost:8081/metrics | grep -E "^container_fs_(reads|writes)_bytes_total" | head
```

Screenshots: `../screenshots/cadvisor/` — `docker ps` showing the running container, the web UI, and the raw `/metrics` output.

## 5. Cleanup

Standalone containers and cAdvisor were removed after this part, to free resources before the Kubernetes work:

```bash
docker rm -f nginx-monitor redis-monitor postgres-monitor cpu-stress cadvisor
```