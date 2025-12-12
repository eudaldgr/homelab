output "s3_bucket_name" {
  description = "Nom del bucket S3 creat"
  value       = aws_s3_bucket.tofu_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.tofu_state.arn
}

output "aws_region" {
  description = "Regió AWS utilitzada"
  value       = var.aws_region
}

# Configuració exemple per al backend amb S3 native locking
output "backend_config" {
  description = "Configuració per usar al backend dels altres mòduls"
  value = {
    bucket      = aws_s3_bucket.tofu_state.bucket
    region      = var.aws_region
    encrypt     = true
    use_lockfile = true
  }
}