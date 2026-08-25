1. **Name** — e.g. `standard`
2. **Provisioner:** `k8s.io/minikube-hostpath`  ( on Minikube, typically `k8s.io/minikube-hostpath` which is a local
   dev-only provisioner; in real clusters this would be something like
   `ebs.csi.aws.com`, `pd.csi.storage.gke.io`, etc.)
3. **Reclaim policy** — the default policy new PVs get when created via this class
   (Minikube's default class is usually `Delete`)
4. **Volume binding mode** — `Immediate` (PV is provisioned as soon as the PVC is
   created) vs `WaitForFirstConsumer` (provisioning waits until a Pod actually needs
   the volume, so it can be placed with the right topology)
5. **Default StorageClass?** — check for the
   `storageclass.kubernetes.io/is-default-class: "true"` annotation in the output;
   this is why you didn't have to name a class in some earlier steps.