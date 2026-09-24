# terraform-aws-basics

Basic Terraform project provisioning a small set of AWS resources: three IAM
users and a versioned S3 bucket.

## Resources created

- **IAM Users**: `developer1`, `developer2`, `developer3`
- **S3 Bucket**: globally unique name (base name + random hex suffix), with
  versioning enabled and tags:
  - `Environment = Development`
  - `Owner = Gerald`

## Provider

- `hashicorp/aws`, pinned to `~> 6.0`
- Region: `us-east-1` (default, overridable via `var.aws_region`)

## Files

| File | Purpose |
|---|---|
| `main.tf` | Terraform block + AWS provider config |
| `variables.tf` | Input variables (region, owner, bucket base name) |
| `outputs.tf` | Outputs (IAM user names, bucket name/ARN) |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

```

## Notes

- No AWS credentials are stored in this repo. Authentication is expected via
  the standard AWS credential chain (environment variables, `~/.aws/credentials`,
  or an assumed IAM role).
- State files, `.terraform/`, and `.tfvars` files are excluded via
  `.gitignore` and must never be committed.

## Cleanup

```bash
terraform destroy
```