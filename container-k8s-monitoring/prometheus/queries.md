# Prometheus Queries

Prometheus UI: `http://localhost:9090`, reached via:

```bash
kubectl port-forward -n monitoring2 svc/monitoring-kube-prometheus-prometheus 9090:9090
```

> Release name is `monitoring`; namespace is `monitoring2` (see root README §4.1).

Screenshots for each query below are in `../screenshots/prometheus/`.

---

## 1. CPU usage per pod

```
sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod)
```

**Measures:** CPU cores consumed per pod, averaged over the last 5 minutes.

**Notes:** on this environment (Minikube, Docker driver), cAdvisor exposes this metric with an empty `container=""` label — only the pod-level cgroup aggregate is present, not a per-container breakdown. The usual `container!=""` filter (used to exclude the pause/infra container) was **removed**, since on this setup it excludes every row. Verified directly against the kubelet's cAdvisor endpoint before assuming a Prometheus config problem:

```bash
kubectl get --raw "/api/v1/nodes/minikube/proxy/metrics/cadvisor" | grep container_cpu_usage_seconds_total
```

Also note: this is a **counter**, so idle pods with no traffic correctly report `~0` — that is not a broken query. Confirmed by port-forwarding to a pod and generating load, then re-querying and seeing the value rise:

```bash
kubectl port-forward pod/nginx-deployment-77bfc996b4-lqmbz 8080:80 &
for i in $(seq 1 20000); do curl -s localhost:8080 > /dev/null; done
```

---

## 2. Memory usage per pod

```
sum(container_memory_working_set_bytes{namespace="default"}) by (pod)
```

**Measures:** working-set memory (bytes) per pod — the portion of memory the kernel would need to reclaim under pressure; closer to "real" usage than raw RSS.

**Notes:** same `container!=""` removal as Query 1, for the same reason. Unlike CPU, this is a **gauge** (an absolute snapshot), so it returns a nonzero value immediately regardless of load.

---

## 3. Pod info

```
kube_pod_info{namespace="default"}
```

**Measures:** metadata about running pods (node, pod IP, etc.) — sourced from **kube-state-metrics**, not cAdvisor. Used early on as a sanity check to confirm the general Prometheus → Kubernetes pipeline was working, isolating whether empty results elsewhere were namespace-related or exporter-specific.

---

## 4. Pod restart counts

```
kube_pod_container_status_restarts_total{namespace="default"}
```

**Measures:** cumulative container restarts per pod. Used in the failure simulation (Failure B — crash loop) to confirm restart counts were climbing.

---

## 5. Deployment replicas — desired vs. available

```
kube_deployment_spec_replicas{deployment="nginx-deployment"}
kube_deployment_status_replicas_available{deployment="nginx-deployment"}
```

**Measures:** desired replica count vs. currently available/healthy replicas. Used in the failure simulation (Failure A — bad image rollout) to show the gap opening up between desired and available replicas.

Related, used during that failure:

```
kube_deployment_status_replicas_unavailable{deployment="nginx-deployment"}
```

---

## 6. Node CPU usage %

```
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Measures:** percentage of CPU time not spent idle, per node.

**Notes:** sourced from **node-exporter**, a separate DaemonSet from kubelet/cAdvisor. Initially returned empty — traced to a node-exporter pod issue (checked with `kubectl get pods -n monitoring2 -l app.kubernetes.io/name=node-exporter` and `kubectl logs`), a known rough edge under the Minikube Docker driver where node-exporter's `/proc`/`/sys` mounts reflect the Minikube node container's view rather than the physical host's. Resolved; see root README §4.4.

---

## 7. Node memory usage %

```
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

**Measures:** percentage of node memory currently in use. Same node-exporter dependency and fix as Query 6.

---

## 8. Running pod count

```
sum(kube_pod_status_phase{phase="Running", namespace="default"})
```

**Measures:** count of pods currently in the `Running` phase. Used as a quick health check and as the source query for the Grafana "Pod Count" stat panel.