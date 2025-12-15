terraform {
  backend "s3" {
    bucket       = "e17n-homelab-tofu-state"
    key          = "infra/home.arpa/fgs/pve/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
