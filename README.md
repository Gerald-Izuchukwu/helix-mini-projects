# Kubernetes ConfigMaps & Secrets

Deploys an Nginx Pod that pulls its configuration from a ConfigMap
and a Secret instead of hard-coded values.

## Files
- `configmap.yaml` — non-sensitive app config (APP_NAME, APP_ENV, APP_PORT)
- `secret.yaml` — sensitive DB credentials (DB_USERNAME, DB_PASSWORD)
- `pod.yaml` — nginx:alpine Pod (`bookstore-pod`) injecting both as env vars

## Usage
\`\`\`bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pod.yaml

kubectl get pods
kubectl exec -it bookstore-pod -- env
\`\`\`

## Verification
Confirmed all five environment variables are present inside the
running container via `kubectl exec ... -- env`, with none hard-coded
in `pod.yaml` — all sourced via `configMapKeyRef` / `secretKeyRef`.