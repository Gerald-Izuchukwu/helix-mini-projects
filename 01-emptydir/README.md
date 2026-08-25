- `emptyDir` is a volume created fresh when a Pod is scheduled to a node, backed by
  the node's disk (or RAM if `medium: Memory`). It exists only as long as that Pod
  is running on that node.
- Useful for: scratch space, caching, sharing files between containers *in the same
  Pod*, sorting/merging work that doesn't need to survive a restart.
- Inappropriate for: anything that needs to survive Pod deletion/rescheduling —
  it's tied to the Pod's lifecycle, not the node's or the cluster's.
- What happened: the file was gone after recreation. Deleting the Pod deletes the
  `emptyDir` volume with it — a "recreated" Pod is a brand-new object with a brand-new
  empty volume, even with the same name/manifest.