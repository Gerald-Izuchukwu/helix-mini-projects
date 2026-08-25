**Why did the file survive after the Pod was deleted?**


**Why:** the data never lived in the Pod. It lived in the `hostPath` directory backing
`bookstore-pv`, and the PV exists independently of any Pod's lifecycle. Deleting the
Pod only tears down the Pod object; the PVC (still Bound) and PV (still holding the
data on disk) are untouched. When you recreate the Pod and it re-mounts the same PVC,
it's reconnecting to the exact same underlying storage — not creating new storage
like `emptyDir` does.