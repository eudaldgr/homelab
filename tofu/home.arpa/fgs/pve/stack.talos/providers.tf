terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.109.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.10.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.5"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox.endpoint
  api_token = var.proxmox.api_token
  insecure  = var.proxmox.insecure

  ssh {
    agent    = true
    username = "root"
  }
}

provider "talos" {}
provider "local" {}
provider "external" {}
