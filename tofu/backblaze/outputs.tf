output "bucket_ids" {
  description = "IDs dels buckets B2 creats."
  value = {
    for name, bucket in b2_bucket.this : name => bucket.bucket_id
  }
}

output "bucket_names" {
  description = "Noms dels buckets B2 creats."
  value = {
    for name, bucket in b2_bucket.this : name => bucket.bucket_name
  }
}

output "application_key_ids" {
  description = "Application key IDs per bucket."
  value = {
    for name, key in b2_application_key.this : name => key.application_key_id
  }
}

output "application_keys" {
  description = "Application key secrets per bucket."
  sensitive   = true
  value = {
    for name, key in b2_application_key.this : name => key.application_key
  }
}

output "bucket_s3_endpoints" {
  description = "Endpoint S3 compatible a usar per cada bucket."
  value = {
    for name, _ in b2_bucket.this : name => var.b2_endpoint
  }
}
