# Grafana Dashboard — "Kubernetes Workload Monitoring"

Grafana UI: `http://localhost:3000` (user `admin`), reached via:

```bash
kubectl port-forward -n monitoring2 svc/monitoring-grafana 3000:80
kubectl get secret -n monitoring2 monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d; echo
```

Data source: the pre-provisioned **Prometheus** data source shipped by `kube-prometheus-stack` — no manual data source setup needed.

Dashboard export (JSON) saved alongside this file: `kubernetes-workload-monitoring.json`.
Screenshots: `../screenshots/grafana/`.

---

## Panels

### 1. CPU Usage — Time series

```
sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod)
```

- Unit: set explicitly to a higher **decimal precision** (e.g. 3–4 decimals) rather than `Auto`, since idle-pod values are sub-1 and were rounding to `0` on screen.
- Alternative: multiply the query by `1000` and label the unit as millicores (`m`) to match `kubectl top` conventions and avoid tiny decimals altogether.
- See root README §4.3 for why idle pods legitimately read close to 0.

### 2. Memory Usage — Time series

```
sum(container_memory_working_set_bytes{namespace="default"}) by (pod)
```

- Unit: **Bytes (IEC)**, so Grafana auto-scales to KiB/MiB as appropriate.

### 3. Pod Count — Stat

```
sum(kube_pod_status_phase{phase="Running", namespace="default"})
```

- Displays current count of `Running` pods as a single big number. Useful at-a-glance health indicator.

### 4. Pod Restarts — Time series

```
sum(kube_pod_container_status_restarts_total{namespace="default"}) by (pod)
```

- Used during the failure simulation to watch restart counts climb for the `crashy` deployment (Failure B).

### 5. Deployment Replicas — Time series

Two queries on the same panel:

```
kube_deployment_spec_replicas{deployment="nginx-deployment"}       # Desired
kube_deployment_status_replicas_available{deployment="nginx-deployment"}  # Available
```

- Legend labeled "Desired" / "Available" so the gap is readable at a glance.
- Used during the failure simulation to visualize the desired-vs-available gap opening during the bad-image rollout (Failure A).

### 6. Node Resource Usage — Time series

```
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

- Both queries on one panel (CPU % and Memory % per node), unit set to **Percent (0-100)**.
- Depends on node-exporter; see root README §4.4 for the fix required to get this panel populated on Minikube/Docker driver.

---

## Notes

- Dashboard saved via **Dashboards → New → New dashboard → Add visualization** for each panel, then **Share → Export → Save to file** for the JSON backup.
- All panels use the auto-refresh default (no manual refresh needed) so the dashboard stays live while load-generation commands run in a terminal alongside it.