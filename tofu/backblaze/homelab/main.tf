terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source  = "registry.terraform.io/backblaze/b2"
      version = "0.13.0"
    }
  }
}

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

resource "b2_bucket" "this" {
  for_each = var.buckets

  bucket_name = each.value.bucket_name
  bucket_type = each.value.bucket_type

  # Keep only the latest version of each file.
  # Equivalent to B2 UI: "File Lifecycle: Keep only the last version".
  lifecycle_rules {
    file_name_prefix              = ""
    days_from_uploading_to_hiding = null
    days_from_hiding_to_deleting  = 1
  }
}

resource "b2_application_key" "this" {
  for_each = var.buckets

  key_name     = each.value.key_name
  capabilities = each.value.capabilities
  bucket_ids   = [b2_bucket.this[each.key].bucket_id]
}
