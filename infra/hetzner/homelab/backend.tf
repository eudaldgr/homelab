terraform {
  backend "s3" {
    bucket      = "e17n-homelab-tofu-state"
    key         = "infra/hetzner/homelab/terraform.tfstate"
    region      = "eu-west-3"
    encrypt     = true
    use_lockfile = true
  }
}