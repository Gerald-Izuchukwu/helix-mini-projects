# Principle of Least Privilege

## Definition
The Principle of Least Privilege (PoLP) means giving users, applications, or services only the permissions they need to perform their tasks — nothing more.

---

## Why It Matters

Applying least privilege helps to:

- Reduce security risks
- Prevent accidental changes
- Limit the impact of compromised accounts
- Improve access control and auditing

---

## Example

### Bad Practice
Giving a developer full `AdministratorAccess` when they only need access to Amazon S3.

### Good Practice
Granting only:
- `s3:GetObject`
- `s3:PutObject`

for a specific S3 bucket.

---

## How Least Privilege Was Applied

### 1. Created IAM Groups
Users were organized into groups based on responsibilities.

### 2. Assigned Specific Policies
Only required permissions were attached to each group.

### 3. Avoided Root Account Usage
The root account was not used for daily operations.

### 4. Limited Direct User Permissions
Permissions were managed mostly through groups instead of assigning excessive permissions directly to users.

### 5. Regular Permission Review
Permissions should be reviewed periodically to remove unnecessary access.

---

## Benefits

- Better security posture
- Easier permission management
- Reduced risk of privilege escalation
- Compliance with security best practices

---

## Conclusion

Least privilege is a core AWS security best practice that ensures users and services operate with only the minimum permissions necessary.