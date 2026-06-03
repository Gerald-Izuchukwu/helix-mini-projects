# EC2 Provisioning Assignment

## Objective

This assignment demonstrates the process of launching and configuring an Ubuntu EC2 instance on AWS, connecting via SSH, installing and configuring Nginx, creating a custom web page, and documenting the entire deployment process.

---

## Prerequisites

* AWS Account
* SSH Client (OpenSSH, Git Bash, WSL, or Terminal)
* Internet Connection

---

## Step 1: Launch an EC2 Instance

1. Log in to the AWS Management Console.
2. Navigate to **EC2 Dashboard**.
3. Click **Launch Instance**.
4. Configure the instance:

   * Name: `ec2-provisioning-assignment`
   * AMI: Ubuntu Server
   * Instance Type: `t2.micro`
5. Create a new Key Pair and download the `.pem` file.
6. Create a Security Group with:

   * SSH (Port 22) from `0.0.0.0/0`
7. Launch the instance.

---

## Step 2: Connect via SSH

Set appropriate permissions on the key:

```bash
chmod 400 my-key.pem
```

Connect to the instance:

```bash
ssh -i my-key.pem ubuntu@<PUBLIC_IP>
```

Successful login confirms SSH connectivity.

---

## Step 3: Gather Server Information

Run the following commands:

```bash
whoami
hostname
pwd
uptime
free -h
df -h
```

The outputs are documented in `server-information.md`.

---

## Step 4: Update the Server

Update package lists and upgrade installed packages:

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Step 5: Install Nginx

Install Nginx:

```bash
sudo apt install nginx -y
```

Start and enable Nginx:

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Verify service status:

```bash
sudo systemctl status nginx
```

---

## Step 6: Allow HTTP Access

Modify the Security Group to allow inbound HTTP traffic:

| Type | Protocol | Port |
| ---- | -------- | ---- |
| HTTP | TCP      | 80   |

Source:

```text
0.0.0.0/0
```

---

## Step 7: Verify Nginx Installation

Open the instance public IP in a browser:

```text
http://<PUBLIC_IP>
```

The default Nginx welcome page should be displayed.

---

## Step 8: Create a Custom Web Page

Navigate to the Nginx web root:

```bash
cd /var/www/html
```

Replace the default page:

```bash
sudo nano server.html
```


Save the file and refresh the browser.

---

## Verification

The custom web page was successfully displayed using the EC2 instance public IP address.

---

## Screenshots Included

* Running EC2 Instance
* Security Group Configuration
* Successful SSH Connection
* Nginx Welcome Page
* Custom Web Page

Directory Structure:

```text
ec2-provisioning-assignment/
│
├── README.md
├── server-information.md
├── screenshots/
│   ├── instance-running.png
│   ├── security-group.png
│   ├── ssh-login.png
│   ├── nginx-homepage.png
│   └── custom-webpage.png
```

## Conclusion

An Ubuntu EC2 instance was successfully provisioned, secured with SSH access, configured with Nginx, and deployed with a custom HTML webpage accessible via a web browser.
