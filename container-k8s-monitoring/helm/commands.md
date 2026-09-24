# Helm Verification

> Release name: `monitoring`. Namespace: **`monitoring2`** (not `monitoring` — see root README §4.1 for how this mismatch was found and confirmed).

## 1. Install

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring2 --create-namespace
```

## 2. List releases

```bash
helm list -n monitoring2
```

Confirms the release name, chart version, app version, and status (`deployed`).

## 3. Release status

```bash
helm status monitoring -n monitoring2
```

Shows the release's current status and a summary of resources/notes emitted by the chart.

## 4. Installed values

```bash
helm get values monitoring -n monitoring2
```

Since this was installed with chart defaults (no custom `values.yaml` or `--set` flags), this prints:

```
USER-SUPPLIED VALUES: null
```

To see the full computed configuration (defaults merged in), use `--all`:

```bash
helm get values monitoring -n monitoring2 --all
```

## 5. Rendered manifest

```bash
helm get manifest monitoring -n monitoring2
```

Prints every Kubernetes manifest the release generated. To get a quick inventory of what kinds of resources the chart created:

```bash
helm get manifest monitoring -n monitoring2 | grep "^kind:" | sort | uniq -c
```

Typical output includes counts of `Deployment`, `DaemonSet`, `Service`, `ServiceMonitor`, `PrometheusRule`, `ConfigMap`, `Secret`, `ClusterRole`, `ClusterRoleBinding`.

## 6. Cross-check against the live cluster

```bash
kubectl get all -n monitoring2 -l release=monitoring
kubectl get servicemonitors,prometheusrules -n monitoring2
kubectl get crd | grep monitoring.coreos.com
```

Confirms the resources Helm says it created (step 5) actually exist and are running in the cluster, and that the Prometheus Operator CRDs (`ServiceMonitor`, `PrometheusRule`, etc.) were installed.

## 7. ServiceMonitor inspection (used during troubleshooting)

```bash
kubectl get servicemonitor -n monitoring2 monitoring-kube-prometheus-kubelet -o yaml
```

Used to inspect the kubelet `ServiceMonitor`'s scrape config (path `/metrics/cadvisor`, relabelings) while diagnosing the empty-`container`-label issue — see root README §4.2. No metric-dropping `relabeling` rule was found there; the empty label turned out to be how cAdvisor itself reports on this environment, not a Prometheus-side filter.