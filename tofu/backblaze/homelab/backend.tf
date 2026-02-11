terraform {
  backend "s3" {
    bucket = "tofu"
    key    = "tofu/backblaze/homelab/terraform.tfstate"
  }
}
