output "iam_user_names" {
  description = "Names of the created IAM users"
  value       = aws_iam_user.developer[*].name
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.arn
}