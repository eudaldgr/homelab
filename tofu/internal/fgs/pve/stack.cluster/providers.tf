terraform {
  required_version = ">= 1.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.113.0"
    }
  }

  backend "s3" {
    profile                     = "garage"
    bucket                      = "tofu"
    key                         = "internal/fgs/pve/stack.cluster.tfstate"
    region                      = "garage"
    use_path_style              = true
    use_lockfile                = true
    encrypt                     = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint

  ssh {
    agent    = true
    username = "root"
  }
}
