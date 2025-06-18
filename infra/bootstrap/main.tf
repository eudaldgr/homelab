terraform {
  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

provider "b2" {
}

resource "b2_bucket" "state" {
  bucket_name = var.bucket_name
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

resource "b2_application_key" "terraform_backend" {
  key_name     = "e17n-terraform-backend"
  capabilities = [
    "listBuckets",
    "readBuckets",
    "listFiles",
    "readFiles",
    "writeFiles",
    "deleteFiles"
  ]
  bucket_id    = b2_bucket.state.bucket_id
}