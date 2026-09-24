| Access Mode | Meaning | Example Use Case |
|---|---|---|
| RWO (ReadWriteOnce) | Volume can be mounted read-write by **a single node** at a time (multiple Pods on that same node can still share it) | A single-instance database like MySQL/PostgreSQL |
| ROX (ReadOnlyMany) | Volume can be mounted read-only by **many nodes** simultaneously | Serving shared static assets/config to many replicas of a web app |
| RWX (ReadWriteMany) | Volume can be mounted read-write by **many nodes** simultaneously | Shared file storage for a CMS, or multiple Pods writing to the same log/upload directory |

**Does every backend support every access mode?** No. Support is defined by the
underlying storage technology, not Kubernetes itself. `hostPath` is effectively
node-local (RWO-ish, single node). AWS EBS supports RWO only. NFS, EFS, CephFS, and
similar network/shared file systems support RWX. A PVC request for RWX against EBS
will simply never bind — you have to pick a backend that actually implements the
mode you need.
