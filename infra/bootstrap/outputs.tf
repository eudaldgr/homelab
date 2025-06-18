output "bucket_id" {
  value = b2_bucket.state.bucket_id
}

output "application_key_id" {
  value = b2_application_key.terraform_backend.application_key_id
}

output "application_key" {
  value     = b2_application_key.terraform_backend.application_key
  sensitive = true
}