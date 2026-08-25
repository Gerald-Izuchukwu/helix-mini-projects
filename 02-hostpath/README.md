1. `hostPath` mounts a path from the **node's own filesystem** directly into the Pod.
2. The data is stored on the Minikube node's disk itself (you just confirmed this
   with `minikube ssh` + `ls`) — not managed by Kubernetes at all, just a bind mount.
3. If the Pod is rescheduled to a *different* node, the data isn't there — `hostPath`
   is local to one specific node, so the new Pod sees an empty (or nonexistent)
   directory on the new node.
4. In multi-node production clusters this breaks the assumption that storage follows
   the Pod: you get silent data loss/inconsistency on rescheduling, plus every node
   needs manual pre-provisioning of the path, and it opens security risk (containers
   touching arbitrary node filesystem paths).
5. Still useful for: single-node/edge deployments, DaemonSets that need to read
   node-level data (e.g. log collectors reading `/var/log`, monitoring agents reading
   `/proc` or Docker socket).