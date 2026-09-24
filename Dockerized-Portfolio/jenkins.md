# Jenkins CI Pipeline — Portfolio Website

## Overview

This project configures a Jenkins CI pipeline that automatically builds and runs a Dockerized static portfolio website whenever code is pushed to the `main` branch on GitHub. The pipeline is defined declaratively in a `Jenkinsfile` stored in the repository root, triggered via a GitHub webhook, and requires no manual intervention once configured.

**Repository:** https://github.com/Gerald-Izuchukwu/dockerized-portfolio-website
**Live app (after pipeline run):** `http://3.218.43.71:8081`
**Jenkins:** `http://3.218.43.71:8080`

---

## Tools Used

| Tool | Purpose |
|---|---|
| **Jenkins** (2.555.3) | CI/CD orchestration engine, running as a systemd service on Ubuntu EC2 |
| **Git plugin** | Checkout and SCM polling support |
| **Pipeline plugin** | Enables Declarative Pipeline syntax (`Jenkinsfile`) |
| **Docker Pipeline plugin** (`docker-workflow`) | Provides the `docker.build()` / `docker.image().run()` DSL used in the Jenkinsfile |
| **Docker Engine** | Builds the Nginx-based image and runs the container |
| **GitHub Webhooks** | Pushes a `POST` event to Jenkins on every `git push`, replacing manual "Build Now" clicks |
| **Nginx (Alpine)** | Base image serving the static HTML/CSS site inside the container |
| **AWS EC2 (Ubuntu)** | Host running both Jenkins and Docker |

---

## Pipeline Stages

The `Jenkinsfile` defines the following stages, executed in order:

1. **Checkout**
   Pulls the latest commit from the `main` branch of the GitHub repository using the configured SCM settings.

2. **Build**
   Runs `docker build` against the repository's `Dockerfile`, producing a tagged image (`portfolio-website:<BUILD_NUMBER>`). The Dockerfile copies `index.html` and `style.css` into an `nginx:alpine` base image.

3. **Install Dependencies**
   Included to satisfy the pipeline structure requirement. Since this is a static site with no package manager or external dependencies, this stage is a no-op with an explanatory message rather than a fabricated step.

4. **Run Application**
   Removes any previously running container (to prevent name conflicts on repeated builds), starts a new container mapping host port `8081` to container port `80`, waits briefly for startup, then verifies the app responds with a `curl` health check.

5. **Cleanup** *(extra credit stage)*
   Runs `docker image prune -f` to remove dangling/unused images after each build, keeping disk usage under control across repeated pipeline runs.

Post-build, the pipeline reports `Pipeline finished: SUCCESS` or `FAILURE` depending on outcome.

---

## Challenges Encountered & How They Were Resolved

### 1. Jenkins APT repository key rotation (`NO_PUBKEY` error)
**Problem:** The documented Jenkins install steps referenced the `jenkins.io-2023.key`, but Jenkins had rotated to a new signing key. `apt update` failed with `NO_PUBKEY 7198F4B714ABFC68`, and the key actually present in the keyring didn't match the key that signed the repo's `Release` file at all.
**Resolution:** Identified that Jenkins had published a newer `jenkins.io-2026.key` and switched to it, re-adding the APT source with the correct key. This resolved the signature mismatch entirely.

### 2. Java version incompatibility
**Problem:** After successfully installing the `jenkins` package, the service crash-looped immediately. `journalctl` revealed Jenkins was launching against Java 17, which was below the minimum supported version (Java 21) for this Jenkins release.
**Resolution:** Installed `openjdk-21-jre`, then found Jenkins was still resolving to Java 17 via `update-alternatives` due to both versions being installed. Removed Java 17 entirely (`apt remove openjdk-17-jre openjdk-17-jre-headless`) to eliminate ambiguity, forcing Java 21 as the sole default. Jenkins started successfully afterward.

### 3. Lost/forgotten Jenkins admin credentials after a plugin-triggered restart
**Problem:** After installing plugins and letting Jenkins restart, the login screen reappeared and the admin credentials set during initial setup were not recalled.
**Resolution:** Temporarily disabled security by setting `<useSecurity>false</useSecurity>` in `/var/lib/jenkins/config.xml` while Jenkins was stopped, restarted with security disabled to gain unauthenticated access, then re-enabled security under **Manage Jenkins → Security** and set fresh, recorded credentials.

### 4. GitHub webhook delivery failing ("failed to connect to host")
**Problem:** The webhook's first delivery attempt failed to connect, even though Jenkins itself was reachable in a browser.
**Resolution:** Confirmed the Security Group, `ufw`, and Jenkins bind address were all correctly configured (Jenkins was listening on `0.0.0.0:8080`). The delivery succeeded on a manual **Redeliver** from GitHub's webhook settings, suggesting the initial failure was a transient connectivity blip rather than a persistent misconfiguration.

### 5. Missing Docker installation
**Problem:** The Jenkinsfile referenced Docker Pipeline steps, but Docker Engine itself had not yet been installed on the EC2 host.
**Resolution:** Installed Docker CE via the official Docker APT repository, then added the `jenkins` system user to the `docker` group (`usermod -aG docker jenkins`) and restarted Jenkins so the group membership took effect — required for Jenkins to access `/var/run/docker.sock` without permission errors.

### 6. Built-in node marked offline due to low disk space on `/tmp`
**Problem:** Webhook deliveries were succeeding and Jenkins logs showed "Poked Github Pipeline," but no builds were being queued or run. Investigation revealed the Jenkins **Built-In Node** had been automatically marked offline because its disk-space monitor found `/tmp` — a small, separate `tmpfs` mount — under its 1 GiB free-space threshold (only ~450 MB total).
**Resolution:** Since `/tmp` is a `tmpfs` (RAM-backed) mount, it was resized live with `sudo mount -o remount,size=2G /tmp`, immediately clearing the threshold at no storage cost. Stale `winstone*.jar` temp files from previous Jenkins restarts were also cleaned up as part of the investigation.

### 7. Low overall system memory causing instability
**Problem:** The EC2 instance had only ~908 MB total RAM with close to zero free at times, a likely contributor to earlier crashes and restarts, and a risk for future Docker build stability.
**Resolution:** Added a 1 GB swap file (`fallocate` + `mkswap` + `swapon`, persisted via `/etc/fstab`) as a free, no-infrastructure-cost mitigation, giving the kernel headroom instead of hitting hard OOM conditions under memory pressure.

### 8. Pipeline builds failing with `MissingPropertyException: No such property: docker`
**Problem:** Even after Docker Engine was installed and the node was back online, builds consistently failed at the **Build** stage with a Groovy error indicating the `docker` global variable didn't exist in the pipeline script's binding.
**Resolution:** This indicated the **Docker Pipeline** plugin (distinct from the lower-level "Docker" and "Docker Commons" plugins) was not actually installed/active. Installing the correct plugin (`docker-workflow`) and restarting Jenkins resolved the error, and the `docker.build()` / `docker.image().run()` calls in the Jenkinsfile executed correctly from that point on.

### 9. Confirming automatic (webhook) triggering vs. manual builds
**Problem:** After all infrastructure issues were resolved, it was initially unclear whether builds were being triggered automatically by the webhook or only manually via "Build Now," since earlier failed builds (from the Docker plugin issue above) were easy to overlook in the build history.
**Resolution:** Cross-referenced Jenkins' `journalctl` logs (showing `Poked Github Pipeline` at the exact push timestamp) against the build history, and confirmed via the build's cause label ("Started by GitHub push by ...") that a plain `git push` — with no manual interaction — successfully triggered and completed a pipeline run end-to-end.

---

## Outcome

The pipeline now runs end-to-end on every push to `main`:
`GitHub push → Webhook → Jenkins auto-trigger → Checkout → Build → Install Dependencies → Run Application → Cleanup → SUCCESS`

The portfolio site is confirmed live and updating on each push at `http://3.218.43.71:8081`.