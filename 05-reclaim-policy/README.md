- **Retain** — PV and its data are kept as-is after the PVC is deleted; it moves to
  `Released` and must be manually reclaimed (or deleted) by an admin before it can be
  reused. Nothing is auto-wiped.
- **Delete** — the underlying storage asset (e.g. the cloud disk) is deleted along
  with the PV when the PVC is deleted. This is the default for most dynamically
  provisioned StorageClasses.
- **Recycle** — deprecated: ran a basic `rm -rf` scrub of the volume so it could be
  reused. Removed in modern Kubernetes in favor of dynamic provisioning.
- **Why `Retain` matters:** it's a safety net against accidental data loss — if
  someone deletes a PVC by mistake (or a Deployment gets torn down), the actual data
  on disk isn't destroyed. An operator can manually inspect/recover it, or rebind it
  to a new PVC, before it's gone for good.