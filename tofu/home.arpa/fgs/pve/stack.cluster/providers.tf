terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  username = var.proxmox.username
  password = var.proxmox.password
  insecure = var.proxmox.insecure

  ssh {
    agent    = true
    username = "root"
  }
}
