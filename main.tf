terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

resource "aws_iam_user" "developer" {
  count = 3
  name  = "developer${count.index + 1}"

  tags = {
    Environment = "Development"
    Owner       = "Gerald"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "padre_helix_cloudops_2026"

  tags = {
    Environment = "Development"
    Owner       = "Gerald"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}