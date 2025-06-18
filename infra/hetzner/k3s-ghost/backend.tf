terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://s3.us-east-005.backblazeb2.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    region     = "us-east-1"
    bucket     = "e17n-homelab"
    key        = "infra/hetzner/k3s-ghost/terraform.tfstate"
  }
}