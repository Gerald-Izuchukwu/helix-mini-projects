# Kubernetes Storage Practical Assignment

## 1. Project Title
Kubernetes Storage Practical Assignment — Persistent Storage for a Bookstore Application

## 2. Objective
This project demonstrates practical understanding of Kubernetes storage
mechanisms by deploying a simple Bookstore application on Minikube and working
through progressively more durable forms of storage: ephemeral (`emptyDir`),
node-local (`hostPath`), manually provisioned PersistentVolumes/Claims, access
modes, reclaim policies, and dynamic provisioning via StorageClass. Each stage
is backed by working YAML manifests, command output, and screenshots, and the
project proves — not just states — that PVC-backed storage survives Pod
deletion while `emptyDir` does not.

## 3. Environment
```
Kubernetes: Minikube
Container Runtime: Docker
kubectl: <paste your `kubectl version --client` output>
OS: <your OS, e.g. Ubuntu 22.04>
```

## 4. Concepts Covered
```
- emptyDir
- hostPath
- PersistentVolume
- PersistentVolumeClaim
- Access Modes
- Reclaim Policies
- StorageClass
- Dynamic Provisioning
```

## 5. Architecture Diagram
```
Kubernetes Cluster
        │
        ▼
       Pod
        │
        ▼
       PVC
        │
        ▼
       PV
        │
        ▼
Storage Backend
```

Dynamic provisioning path:
```
PVC → StorageClass → Provisioner / CSI → PersistentVolume → Storage
```

## 6. Commands Used
```bash
kubectl get pods
kubectl get pv
kubectl get pvc
kubectl get storageclass
kubectl describe pv <name>
kubectl describe pvc <name>
kubectl describe storageclass <name>
kubectl exec <pod> -- sh -c "..."
kubectl exec <pod> -- cat <file>
kubectl delete pod <pod>
kubectl delete pvc <pvc>
minikube ssh
```

## 7. Screenshots
Located in `/screenshots`:
1. `minikube.png` — Minikube running (`kubectl get nodes`)
2. `emptydir.png` — emptyDir demonstration
3. `hostpath.png` — hostPath demonstration
4. `pv.png` — PV created
5. `pvc-bound.png` — PVC Bound
6. `persistent-data.png` — data surviving Pod deletion
7. `storageclass.png` — StorageClass details
8. `dynamic-provisioning.png` — dynamically provisioned PV

---

## Required Questions

**Q1. Difference between `emptyDir` and `hostPath`?**
`emptyDir` creates a brand-new, empty volume scoped to the Pod's lifetime — it's
deleted the moment the Pod is deleted. `hostPath` mounts an existing directory
from the node's own filesystem, which persists independently of any Pod, but is
tied to that one specific node.

**Q2. What happens to `emptyDir` data when a Pod is deleted?**
It's deleted permanently along with the Pod. Verified directly: after deleting
and recreating `emptydir-demo`, `/data/test.txt` no longer existed.

**Q3. Difference between a PV and a PVC?**
A PersistentVolume is the actual storage resource — either manually created by
an admin or dynamically provisioned by a StorageClass. A PersistentVolumeClaim
is a request for storage made by a user/Pod, specifying size and access mode.
Pods consume PVCs, never PVs directly.

**Q4. Describe the PV/PVC binding process.**
The binding controller watches for unbound PVCs and searches for a PV that
satisfies the request (capacity ≥ requested, matching access mode, matching
StorageClass — including an empty `storageClassName` matching only PVs with no
class). Once matched, the pair binds exclusively and moves to `Bound`. If no PV
qualifies and a StorageClass with a provisioner is specified, one is
dynamically created instead. Note: the granted capacity is the *PV's* full
capacity, not the PVC's requested amount — confirmed when `bookstore-pvc`
requested 500Mi but showed 1Gi once bound to a 1Gi PV.

**Q5. What does `ReadWriteOnce` mean?**
The volume can be mounted read-write by a single node at a time.

**Q6. What does `ReadOnlyMany` mean?**
The volume can be mounted read-only by many nodes simultaneously.

**Q7. What does `ReadWriteMany` mean?**
The volume can be mounted read-write by many nodes simultaneously.

**Q8. Why might `hostPath` be unsuitable for a multi-node production application?**
Data lives on one specific node's disk. If the Pod is rescheduled to another
node (which Kubernetes does routinely for scaling, upgrades, or failures), the
new Pod won't see the old data — it's a different filesystem entirely. This
breaks the assumption that storage should follow the workload.

**Q9. What is a StorageClass?**
A StorageClass defines *how* storage should be dynamically provisioned — which
provisioner/CSI driver to use, default reclaim policy, and volume binding mode —
so PVs don't need to be hand-created for every PVC.

**Q10. What is dynamic provisioning?**
Kubernetes automatically creating a PV on demand when a PVC references a
StorageClass, instead of requiring an admin to pre-create matching PVs.
Confirmed in Task 9: applying a PVC with `storageClassName: standard` produced
a new PV automatically, with no `pv.yaml` involved.

**Q11. Difference between `Retain` and `Delete` reclaim policies?**
`Retain` keeps the PV and its underlying data after the PVC is deleted — it
moves to `Released` and requires manual cleanup/reclaim. `Delete` automatically
destroys the underlying storage asset along with the PV.

**Q12. Why is `Recycle` generally not recommended for modern Kubernetes?**
It only performed a basic scrub (effectively `rm -rf` on the volume) rather
than truly recreating storage, which is fragile and unsafe for many backends.
It's deprecated in favor of dynamic provisioning.

**Q13. What happens to a PV when its PVC is deleted under the `Retain` policy?**
The PV is not deleted. It transitions to `Released` status, still holding its
data, but can't be bound to a new PVC until an admin manually clears the
claimRef and makes it `Available` again (or deletes it).

**Q14. Why is persistent storage important for databases?**
Databases hold state that must survive Pod restarts, rescheduling, and
crashes. Without persistent storage, every Pod restart would wipe all data —
completely unworkable for anything stateful.

**Q15. What is the role of a CSI driver?**
A CSI (Container Storage Interface) driver is a standardized plugin that lets
Kubernetes provision, attach, mount, and manage storage from a specific backend
(AWS EBS, GCE PD, Ceph, etc.) without that backend's logic being built into
Kubernetes core itself — it's how StorageClasses actually talk to real storage
systems.
