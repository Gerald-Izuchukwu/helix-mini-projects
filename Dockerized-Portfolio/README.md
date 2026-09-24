# 🐳 Dockerized Portfolio Website

A personal portfolio website containerized with Docker and served via Nginx.

---

## 1. Project Overview

This project packages a static HTML/CSS portfolio website into a Docker container using the lightweight **nginx:alpine** base image. The portfolio displays personal information, technical skills, featured projects, and contact details in a clean, responsive single-page layout.

The project demonstrates:
- Writing clean, semantic HTML/CSS for a portfolio
- Authoring a `Dockerfile` to containerize a static site
- Building and running a Docker image locally
- Managing the project with Git and pushing to GitHub

---

## 2. Project Structure

```
portfolio-website/
├── index.html       # Portfolio webpage
├── style.css        # Stylesheet
├── Dockerfile       # Container build instructions
└── README.md        # This file
```

---

## 4. Dockerfile

```dockerfile
# Use the official lightweight Nginx image on Alpine Linux
FROM nginx:alpine

# Copy portfolio files into Nginx's web root
COPY index.html /usr/share/nginx/html/index.html
COPY style.css  /usr/share/nginx/html/style.css

# Document that the container listens on port 80
EXPOSE 80

# Start Nginx in the foreground so the container stays alive
CMD ["nginx", "-g", "daemon off;"]
```

### Dockerfile Instruction Breakdown

| Instruction | Explanation |
|---|---|
| `FROM nginx:alpine` | Pulls the official Nginx image built on Alpine Linux — a minimal base that keeps the final image under 25 MB. |
| `COPY index.html ...` | Copies the HTML file from the local build context into the container's web root. |
| `COPY style.css ...` | Copies the CSS stylesheet alongside the HTML into the same directory. |
| `EXPOSE 80` | Declares that the container accepts HTTP traffic on port 80. Informational — used by Docker networking and documentation. |
| `CMD ["nginx", "-g", "daemon off;"]` | Launches Nginx in the foreground. The `daemon off` flag is required in Docker — without it, Nginx would background itself, Docker would see no foreground process, and the container would exit immediately. |

---

## 5. Build Instructions

From the project root directory (where the `Dockerfile` lives):

```bash
docker build -t dockerized-portfolio-website .
```

| Flag / Argument | Meaning |
|---|---|
| `-t dockerized-portfolio-website` | Tags the image with this name for easy reference |
| `.` | Uses the current directory as the build context |

Verify the image was created:

```bash
docker images | grep dockerized-portfolio-website
```

Expected output:
```
REPOSITORY                      TAG       IMAGE ID       CREATED          SIZE
dockerized-portfolio-website    latest    a1b2c3d4e5f6   2 minutes ago    23.5MB
```

---

## 6. Run Instructions

```bash
docker run -d -p 8080:80 --name portfolio dockerized-portfolio-website:latest
```

| Flag | Meaning |
|---|---|
| `-d` | Detached mode — runs the container in the background |
| `-p 8080:80` | Maps port **8080** on the host to port **80** inside the container |
| `--name portfolio` | Assigns a human-readable name to the running container |
| `dockerized-portfolio-website:latest` | Specifies the image and tag to run |

Verify the container is running:

```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE                          COMMAND                  CREATED        STATUS        PORTS                  NAMES
7f8e9d0c1b2a   dockerized-portfolio-website   "nginx -g 'daemon of…" 30 seconds ago Up 29 seconds 0.0.0.0:8080->80/tcp   portfolio
```

**Useful container management commands:**

```bash
docker stop portfolio      # Stop the container
docker start portfolio     # Start it again
docker rm portfolio        # Remove the container
docker rmi dockerized-portfolio-website  # Remove the image
```

---

## 7. Verification

### ✅ Docker Image Created Successfully

> **Screenshot:** Output of `docker images` showing `dockerized-portfolio-website` with its image ID, creation timestamp, and size (~23 MB).

---

### ✅ Running Container

> **Screenshot:** Output of `docker ps` confirming the container is `Up` with port mapping `0.0.0.0:8080->80/tcp` active and the name `portfolio`.

---

### ✅ Portfolio Website in the Browser

Open your browser and navigate to:

```
http://localhost:8080
```

> **Screenshot:** Browser showing `http://localhost:8080` with the portfolio fully rendered — including the hero section, skills grid, projects, and contact links.

---

## 8. Pushing to GitHub

```bash
# 1. Initialise a local Git repository
git init

# 2. Stage all project files
git add .

# 3. Commit with a descriptive message
git commit -m "feat: Adding Static and Dockerfiles"

# 4. Add your GitHub remote (replace <your-username>)
git remote add origin https://github.com/Gerald-Izuchukwu/dockerized-portfolio-website.git

# 5. Push to the main branch
git push -u origin main
```

---

## 9. Challenges Encountered

### Challenge 1 — Container exiting immediately after start

**Problem:** Running `docker run` reported the container as started, but `docker ps` showed it had already exited.  
**Root cause:** By default, Nginx daemonizes itself (runs as a background process). Docker monitors the foreground process; when it sees nothing in the foreground, it terminates the container.  
**Resolution:** Added `daemon off;` to the `CMD` instruction — `CMD ["nginx", "-g", "daemon off;"]` — which keeps Nginx in the foreground and the container alive.

---

### Challenge 2 — Port conflict on the host machine

**Problem:** Using `-p 80:80` failed with `Bind for 0.0.0.0:80 failed: port is already allocated`.  
**Root cause:** A local Nginx or Apache instance was already using port 80 on the host.  
**Resolution:** Mapped to an unused host port instead: `-p 8080:80`. The container still serves on port 80 internally; only the host-side port changes. The site was then accessible at `http://localhost:8080`.

---

### Challenge 3 — CSS not loading; site rendered unstyled

**Problem:** After running the container, the HTML loaded but the page had no styles.  
**Root cause:** The initial `Dockerfile` only included `COPY index.html ...` — the `style.css` line was accidentally omitted.  
**Resolution:** Added the missing `COPY style.css /usr/share/nginx/html/style.css` instruction, rebuilt the image with `docker build`, stopped and removed the old container, and started a fresh one. Styles loaded correctly after the rebuild.

---

## 10. Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS3 |
| Web Server | Nginx (Alpine Linux) |
| Containerization | Docker |
| Version Control | Git / GitHub |

---


# CI/CD Pipeline – Portfolio Deployment

## Overview

This project implements a fully automated CI/CD pipeline that deploys a static portfolio website — served via **Nginx** inside a **Docker container** — to an **AWS EC2** instance whenever code is pushed to the `main` branch.

## How the Pipeline Works

The pipeline is powered by **GitHub Actions**, using the `appleboy/ssh-action` to securely SSH into the EC2 instance from the workflow runner. Once connected, the workflow:

1. Pulls the latest code from the repository
2. Rebuilds the Docker image from the `Dockerfile`
3. Stops and removes the old running container
4. Starts a fresh container on port 80

This ensures the live site always reflects the latest commit with **zero manual intervention**.

## Pipeline Flow

```
Developer → git push (main) → GitHub Repository
  → GitHub Actions Workflow
    → SSH into EC2 (appleboy/ssh-action)
      → git pull origin main
      → docker build -t portfolio-site .
      → docker stop/rm (old container)
      → docker run -d -p 80:80 portfolio-site
        → Website Live ✓
```

## Infrastructure Setup

The EC2 instance was provisioned entirely via the **AWS CLI** because the AWS Management Console UI was experiencing downtime at the time of setup — a valuable exercise in managing infrastructure from the terminal. The instance was launched with the following specs:

| Setting | Value |
|---|---|
| OS | Ubuntu 22.04 LTS |
| Instance Type | t2.micro (free tier) |
| Storage | 20 GB gp3 |
| Region | us-east-1 |
| Ports Open | 22 (SSH), 80 (HTTP) |

## Secrets Configuration

All sensitive connection details are stored as **GitHub Actions Secrets**, keeping credentials out of the codebase entirely.

| Secret | Purpose |
|---|---|
| `EC2_HOST` | Public IP of the EC2 instance |
| `EC2_USERNAME` | SSH login user (`ubuntu`) |
| `EC2_SSH_KEY` | Private key contents for SSH authentication |

## Challenges Encountered

### AWS Console Downtime
The AWS Management Console UI was unavailable during the setup window, so the entire infrastructure — Security Group creation, inbound rules, and instance launch — was handled through the AWS CLI.

### Key Pair Region Mismatch
When launching the EC2 instance in `us-east-1`, the following error occurred:

```
An error occurred (InvalidKeyPair.NotFound) when calling the RunInstances operation:
The key pair 'helix-assignment' does not exist
```

The key pair existed in AWS but had been created in a **different region**. This was resolved by extracting the public key from the local `.pem` file and importing it into `us-east-1`:

```bash
ssh-keygen -y -f ~/.ssh/helix-assignment.pem > ~/.ssh/helix-assignment.pub

aws ec2 import-key-pair \
  --key-name helix-assignment \
  --public-key-material fileb://~/.ssh/helix-assignment.pub \
  --region us-east-1
```

After importing, the instance launched successfully.

## Testing

The pipeline was validated by pushing a small change to `index.html`, which triggered the GitHub Actions workflow automatically. After the workflow completed successfully, the update was confirmed live on the server's public IP.
