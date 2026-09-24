# AWS Web Server Deployment with VPC, EC2, Nginx and Security Best Practices

## Project Overview

This project demonstrates the deployment of a secure cloud-based web server on Amazon Web Services (AWS). The infrastructure was designed and deployed following networking and security best practices using AWS VPC, Public Subnets, Route Tables, Internet Gateway, Security Groups, EC2, and Nginx.

The objective was to create a web server that is publicly accessible while maintaining secure access controls and proper cloud networking configurations.

---

## Public Website URL

**Live Website:**

http://18.205.240.173

OR

http://padre.run.place

---

## Architecture

## Architecture Diagram

![Architecture Diagram](images/Helix_mini_project_arch_diagram.drawio.png)

### Components Used

- VPC (10.0.0.0/16)
- Public Subnet (10.0.1.0/24)
- Internet Gateway
- Route Table
- Security Group
- EC2 Instance (Ubuntu)
- Nginx Web Server
- Internet Users

### Architecture Diagram

> Insert Architecture Diagram Screenshot Here

```text
Internet Users
      |
Internet Gateway
      |
Route Table
      |
Public Subnet
      |
Security Group
      |
EC2 Instance
      |
Nginx Web Server
```

---

## AWS Resources Created

### VPC

| Property | Value |
|-----------|---------|
| Name | My-VPC |
| CIDR Block | 10.0.0.0/16 |

### Public Subnet

| Property | Value |
|-----------|---------|
| Name | Public-Subnet |
| CIDR Block | 10.0.1.0/24 |

### Internet Gateway

Attached to the custom VPC to provide internet access.

### Route Table

Configured with:

```text
Destination: 0.0.0.0/0
Target: Internet Gateway
```

Associated with the public subnet.

---

## EC2 Configuration

| Property | Value |
|-----------|---------|
| Operating System | Ubuntu Server |
| Public IP | Enabled |
| Instance Type | t2.micro / t3.micro |
| Web Server | Nginx |

---

## Security Configuration

### Security Group Rules

| Port | Protocol | Purpose | Source |
|--------|----------|----------|---------|
| 22 | TCP | SSH | My Public IP |
| 80 | TCP | HTTP | 0.0.0.0/0 |
| 443 | TCP | HTTPS | 0.0.0.0/0 |

### Security Best Practices Implemented

- Restricted SSH access to my IP address only.
- Allowed only required ports.
- Used IAM User instead of AWS Root Account.
- Followed least-privilege principles.
- Avoided opening unnecessary ports.

---

## Deployment Steps

### 1. Create VPC

Created a custom VPC:

```text
10.0.0.0/16
```

### 2. Create Public Subnet

Created a public subnet:

```text
10.0.1.0/24
```

### 3. Configure Internet Access

- Created Internet Gateway
- Attached Internet Gateway to VPC
- Created Route Table
- Added default route
- Associated Route Table with Public Subnet

### 4. Launch EC2 Instance

- Ubuntu Server
- Public IP enabled
- Attached Security Group

### 5. Connect via SSH

```bash
ssh -i my-key.pem ubuntu@18.205.240.173
```

### 6. Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 7. Deploy Custom Web Page

Created a custom HTML page and deployed it to:

```bash
/var/www/html/index.html
```

---

## Troubleshooting Log

### Issue 1: Unable to Connect via SSH

**Problem**

SSH connection failed.

**Cause**

Port 22 was not allowed in the Security Group.

**Solution**

Added an inbound SSH rule allowing access from my IP address.

---

### Issue 2: Website Not Accessible

**Problem**

The web page could not be reached through the browser.

**Cause**

Port 80 was not open in the Security Group.

**Solution**

Added an inbound HTTP rule for port 80.

---

### Issue 3: Nginx Service Not Running

**Problem**

The server was reachable, but the website did not load.

**Cause**

Nginx service was not running.

**Solution**

Started and enabled Nginx using:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

## Lessons Learned

Through this project, I gained hands-on experience with:

- AWS VPC Networking
- CIDR and Subnetting
- Internet Gateways
- Route Tables
- Security Groups
- EC2 Instance Deployment
- SSH Access Management
- Linux Administration
- Nginx Configuration
- AWS Security Best Practices
- Infrastructure Troubleshooting

---

## Screenshots

### VPC

> Insert Screenshot

### Subnet

> Insert Screenshot

### Internet Gateway

> Insert Screenshot

### Route Table

> Insert Screenshot

### Security Group

> Insert Screenshot

### EC2 Instance

> Insert Screenshot

### Nginx Running

> Insert Screenshot

### Website in Browser

> Insert Screenshot

---

## Author

**Gerald Ugwunna**

DevOps Engineer

Lagos, Nigeria

LinkedIn: <YOUR-LINKEDIN-URL>

GitHub: <YOUR-GITHUB-URL>
