terraform {
  backend "s3" {
    bucket = "tofu"
    key    = "tofu/hetzner/homelab/terraform.tfstate"
  }
}
