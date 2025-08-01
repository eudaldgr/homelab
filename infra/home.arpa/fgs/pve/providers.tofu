terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  alias               = "pve"
  for_each            = { for node in var.proxmox_nodes : node.name => node }
  pm_api_url          = "https://${each.value.host}:${each.value.port}/api2/json"
  pm_api_token_id     = each.value.username
  pm_api_token_secret = each.value.token
  pm_tls_insecure     = !each.value.tls
}